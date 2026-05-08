//
//  DiningViewModel.swift
//  HotelCompanion
//
//  File: Features/Dining/ViewModels/DiningViewModel.swift
//

import Combine
import Foundation

struct DiningMenuItem: Identifiable, Hashable {
    let id: String
    let venueName: String
    let name: String
    let description: String
    let price: MoneyAmount
}

struct DiningCartItem: Identifiable, Hashable {
    let id: String
    let menuItem: DiningMenuItem
    var quantity: Int

    var lineTotalMinorUnits: Int {
        menuItem.price.amountMinorUnits * quantity
    }
}

@MainActor
final class DiningViewModel: ObservableObject {
    @Published private(set) var menuItems: [DiningMenuItem]
    @Published private(set) var currentOrders: [DiningOrderRecord] = []
    @Published private(set) var cartItems: [DiningCartItem] = []
    @Published var deliveryType: DiningDeliveryType = .roomService
    @Published var roomNumber = ""
    @Published var orderNotes = ""
    @Published private(set) var isLoading = false
    @Published private(set) var isSubmitting = false
    @Published private(set) var activeOrderID: String?
    @Published private(set) var errorMessage: String?
    @Published private(set) var successMessage: String?

    private let diningOrderService: DiningOrderServicing

    init(diningOrderService: DiningOrderServicing? = nil) {
        self.diningOrderService = diningOrderService ?? DiningOrderService.shared
        self.menuItems = [
            DiningMenuItem(
                id: "menu-club-sandwich",
                venueName: "In-Room Dining",
                name: "Club Sandwich",
                description: "Grilled chicken, egg, crisp lettuce, and herb fries.",
                price: MoneyAmount(currencyCode: "LKR", amountMinorUnits: 4200)
            ),
            DiningMenuItem(
                id: "menu-seafood-bisque",
                venueName: "Lagoon Grill",
                name: "Seafood Bisque",
                description: "Rich coastal bisque finished with cinnamon crème.",
                price: MoneyAmount(currencyCode: "LKR", amountMinorUnits: 3600)
            ),
            DiningMenuItem(
                id: "menu-iced-tea",
                venueName: "The Verandah",
                name: "Ceylon Iced Tea",
                description: "Single-estate tea with citrus and palm syrup.",
                price: MoneyAmount(currencyCode: "LKR", amountMinorUnits: 950)
            )
        ]
    }

    var subtotalAmount: MoneyAmount {
        let subtotal = cartItems.reduce(0) { $0 + $1.lineTotalMinorUnits }
        let currencyCode = cartItems.first?.menuItem.price.currencyCode ?? "LKR"
        return MoneyAmount(currencyCode: currencyCode, amountMinorUnits: subtotal)
    }

    var estimatedTaxAmount: MoneyAmount {
        let tax = Int((Double(subtotalAmount.amountMinorUnits) * 0.10).rounded())
        return MoneyAmount(currencyCode: subtotalAmount.currencyCode, amountMinorUnits: tax)
    }

    var totalAmount: MoneyAmount {
        MoneyAmount(
            currencyCode: subtotalAmount.currencyCode,
            amountMinorUnits: subtotalAmount.amountMinorUnits + estimatedTaxAmount.amountMinorUnits
        )
    }

    var cartItemCount: Int {
        cartItems.reduce(0) { $0 + $1.quantity }
    }

    var canPlaceOrder: Bool {
        !cartItems.isEmpty && !isSubmitting
    }

    var shouldShowRoomNumberField: Bool {
        deliveryType == .roomService
    }

    var activeOrders: [DiningOrderRecord] {
        currentOrders.filter { $0.status != .delivered && $0.status != .cancelled }
    }

    var isEmpty: Bool {
        !isLoading && currentOrders.isEmpty && errorMessage == nil
    }

    func loadOrders() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            currentOrders = try await diningOrderService.fetchCurrentUserOrders()
                .sorted { ($0.createdAt ?? .distantPast) > ($1.createdAt ?? .distantPast) }
        } catch {
            currentOrders = []
            errorMessage = error.localizedDescription
        }
    }

    func addToCart(_ menuItem: DiningMenuItem) {
        if let index = cartItems.firstIndex(where: { $0.menuItem.id == menuItem.id }) {
            cartItems[index].quantity += 1
        } else {
            cartItems.append(
                DiningCartItem(
                    id: menuItem.id,
                    menuItem: menuItem,
                    quantity: 1
                )
            )
        }
    }

    func removeFromCart(_ cartItem: DiningCartItem) {
        cartItems.removeAll { $0.id == cartItem.id }
    }

    func decrementCartItem(_ cartItem: DiningCartItem) {
        guard let index = cartItems.firstIndex(where: { $0.id == cartItem.id }) else { return }

        if cartItems[index].quantity > 1 {
            cartItems[index].quantity -= 1
        } else {
            cartItems.remove(at: index)
        }
    }

    @discardableResult
    func placeOrder() async -> Bool {
        isSubmitting = true
        errorMessage = nil
        successMessage = nil
        defer { isSubmitting = false }

        do {
            let order = try await diningOrderService.createFoodOrder(
                venueName: resolvedVenueName(),
                items: firestoreItems(),
                deliveryType: deliveryType,
                roomNumber: roomNumber,
                specialInstructions: orderNotes
            )

            currentOrders.insert(order, at: 0)
            cartItems.removeAll()
            orderNotes = ""
            roomNumber = shouldShowRoomNumberField ? (order.roomNumber ?? roomNumber) : ""
            successMessage = "Your dining order is confirmed and currently \(displayTitle(for: order.status).lowercased())."
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func updateOrderStatus(_ order: DiningOrderRecord, status: DiningOrderStatus) async {
        activeOrderID = order.id
        errorMessage = nil
        successMessage = nil
        defer { activeOrderID = nil }

        do {
            let updatedOrder = try await diningOrderService.updateOrderStatus(order, status: status)
            currentOrders.removeAll { $0.id == updatedOrder.id }
            currentOrders.append(updatedOrder)
            currentOrders.sort { ($0.createdAt ?? .distantPast) > ($1.createdAt ?? .distantPast) }
            successMessage = "Order status updated to \(displayTitle(for: status))."
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func displayTitle(for deliveryType: DiningDeliveryType) -> String {
        switch deliveryType {
        case .roomService:
            return "Room Service"
        case .restaurantPickup:
            return "Restaurant Pickup"
        case .poolsideDelivery:
            return "Poolside Delivery"
        }
    }

    func displayTitle(for status: DiningOrderStatus) -> String {
        switch status {
        case .pending:
            return "Pending"
        case .accepted:
            return "Accepted"
        case .preparing:
            return "Preparing"
        case .ready:
            return "Ready"
        case .outForDelivery:
            return "Out for Delivery"
        case .delivered:
            return "Delivered"
        case .cancelled:
            return "Cancelled"
        }
    }

    func formatCurrency(_ amount: MoneyAmount) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = amount.currencyCode
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2

        let decimalAmount = Double(amount.amountMinorUnits) / 100
        return formatter.string(from: NSNumber(value: decimalAmount)) ?? "\(amount.currencyCode) \(decimalAmount)"
    }

    func formattedCreatedAt(for order: DiningOrderRecord) -> String {
        guard let createdAt = order.createdAt else {
            return "Pending sync"
        }

        return createdAt.formatted(date: .abbreviated, time: .shortened)
    }

    func orderItemsSummary(for order: DiningOrderRecord) -> String {
        order.items
            .map { "\($0.quantity)x \($0.name)" }
            .joined(separator: ", ")
    }

    func nextStatus(for order: DiningOrderRecord) -> DiningOrderStatus? {
        switch order.status {
        case .pending:
            return .accepted
        case .accepted:
            return .preparing
        case .preparing:
            return .outForDelivery
        case .outForDelivery:
            return .delivered
        case .ready:
            return .delivered
        case .delivered, .cancelled:
            return nil
        }
    }

    func actionTitle(for order: DiningOrderRecord) -> String? {
        switch order.status {
        case .pending:
            return "Accept Order"
        case .accepted:
            return "Mark Preparing"
        case .preparing:
            return "Mark Out for Delivery"
        case .ready:
            return "Mark Delivered"
        case .outForDelivery:
            return "Mark Delivered"
        case .delivered, .cancelled:
            return nil
        }
    }

    func actionSystemImage(for order: DiningOrderRecord) -> String? {
        switch order.status {
        case .pending:
            return "checkmark.circle"
        case .accepted:
            return "fork.knife.circle"
        case .preparing:
            return "figure.walk.arrival"
        case .ready, .outForDelivery:
            return "bag.badge.checkmark"
        case .delivered, .cancelled:
            return nil
        }
    }

    func clearMessages() {
        errorMessage = nil
        successMessage = nil
    }

    private func resolvedVenueName() -> String {
        cartItems.first?.menuItem.venueName ?? "In-Room Dining"
    }

    private func firestoreItems() -> [DiningOrderItem] {
        cartItems.map { cartItem in
            DiningOrderItem(
                id: cartItem.id,
                menuItemID: cartItem.menuItem.id,
                name: cartItem.menuItem.name,
                quantity: cartItem.quantity,
                unitPrice: cartItem.menuItem.price,
                notes: nil
            )
        }
    }
}
