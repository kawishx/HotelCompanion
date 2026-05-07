//
//  DiningOrderService.swift
//  HotelCompanion
//
//  File: Core/Firebase/Firestore/Dining/DiningOrderService.swift
//

import Foundation

protocol DiningOrderServicing {
    func fetchCurrentUserOrders() async throws -> [DiningOrderRecord]
    func createFoodOrder(
        venueName: String,
        items: [DiningOrderItem],
        deliveryType: DiningDeliveryType,
        roomNumber: String?,
        specialInstructions: String?
    ) async throws -> DiningOrderRecord
    func updateOrderStatus(
        _ order: DiningOrderRecord,
        status: DiningOrderStatus
    ) async throws -> DiningOrderRecord
}

enum DiningOrderServiceError: LocalizedError {
    case emptyCart
    case roomNumberRequired

    var errorDescription: String? {
        switch self {
        case .emptyCart:
            return "Add at least one dining item before placing an order."
        case .roomNumberRequired:
            return "Add a room number for room service delivery before placing your order."
        }
    }
}

final class DiningOrderService: DiningOrderServicing {
    static let shared = DiningOrderService()

    private let remoteStore: FirestoreRemoteStoring
    private let sessionCoordinator: FirebaseSessionCoordinating
    private let hotelContextResolver: HotelContextResolving
    private let dateProvider: DateProviding
    private var fallbackOrdersByUserID: [String: [DiningOrderRecord]] = [:]

    init(
        remoteStore: FirestoreRemoteStoring = FirestoreRemoteStore.shared,
        sessionCoordinator: FirebaseSessionCoordinating = FirebaseSessionCoordinator.shared,
        hotelContextResolver: HotelContextResolving = HotelContextResolver.shared,
        dateProvider: DateProviding = SystemDateProvider()
    ) {
        self.remoteStore = remoteStore
        self.sessionCoordinator = sessionCoordinator
        self.hotelContextResolver = hotelContextResolver
        self.dateProvider = dateProvider
    }

    func fetchCurrentUserOrders() async throws -> [DiningOrderRecord] {
        let session = resolvedSession()

        if shouldUseFallback(for: session) {
            return fallbackOrders(for: session)
        }

        do {
            return try await remoteStore.fetchCollectionGroup(
                subcollection: .diningOrders,
                filters: [.equalTo(field: FirestoreDocumentField.guestUserID, value: session.id)],
                orderBy: FirestoreDocumentField.createdAt,
                descending: true,
                limit: nil
            )
        } catch let error as FirestoreRemoteStoreError where error == .unavailable {
            return fallbackOrders(for: session)
        }
    }

    func createFoodOrder(
        venueName: String,
        items: [DiningOrderItem],
        deliveryType: DiningDeliveryType,
        roomNumber: String?,
        specialInstructions: String?
    ) async throws -> DiningOrderRecord {
        guard !items.isEmpty else {
            throw DiningOrderServiceError.emptyCart
        }

        let session = resolvedSession()
        let hotelContext = await hotelContextResolver.resolveCurrentHotelContext()
        let resolvedRoomNumber = resolvedRoomNumber(
            inputRoomNumber: roomNumber,
            stayRoomNumber: hotelContext.stay?.room.roomNumber,
            deliveryType: deliveryType
        )

        if deliveryType == .roomService, resolvedRoomNumber == nil {
            throw DiningOrderServiceError.roomNumberRequired
        }

        let subtotalMinorUnits = items.reduce(0) { $0 + ($1.unitPrice.amountMinorUnits * $1.quantity) }
        let taxMinorUnits = Int((Double(subtotalMinorUnits) * 0.10).rounded())
        let totalMinorUnits = subtotalMinorUnits + taxMinorUnits
        let currencyCode = items.first?.unitPrice.currencyCode ?? "LKR"
        let now = dateProvider.now

        let order = DiningOrderRecord(
            id: UUID().uuidString,
            hotelID: hotelContext.hotelID,
            guestUserID: session.id,
            guest: sessionCoordinator.guestSnapshot(for: session),
            stayID: hotelContext.stay?.id,
            venueName: venueName,
            deliveryType: deliveryType,
            deliveryLocationLabel: deliveryLabel(for: deliveryType, roomNumber: resolvedRoomNumber),
            roomNumber: resolvedRoomNumber,
            items: items,
            specialInstructions: normalizedInstructions(specialInstructions),
            status: .pending,
            subtotalAmount: MoneyAmount(currencyCode: currencyCode, amountMinorUnits: subtotalMinorUnits),
            taxAmount: MoneyAmount(currencyCode: currencyCode, amountMinorUnits: taxMinorUnits),
            totalAmount: MoneyAmount(currencyCode: currencyCode, amountMinorUnits: totalMinorUnits),
            requestedFor: nil,
            createdAt: now,
            updatedAt: now,
            fulfilledAt: nil
        )

        if shouldUseFallback(for: session) {
            return storeFallback(order, for: session)
        }

        let data = try FirestoreDateCoding.preparedDiningOrderData(from: order)
        do {
            try await remoteStore.setDocument(
                at: FirestorePath.hotelSubcollectionDocument(
                    hotelID: order.hotelID,
                    subcollection: .diningOrders,
                    documentID: order.id
                ),
                data: data,
                merge: false
            )

            return order
        } catch let error as FirestoreRemoteStoreError where error == .unavailable {
            return storeFallback(order, for: session)
        }
    }

    func updateOrderStatus(
        _ order: DiningOrderRecord,
        status: DiningOrderStatus
    ) async throws -> DiningOrderRecord {
        let updatedOrder = DiningOrderRecord(
            id: order.id,
            hotelID: order.hotelID,
            guestUserID: order.guestUserID,
            guest: order.guest,
            stayID: order.stayID,
            venueName: order.venueName,
            deliveryType: order.deliveryType,
            deliveryLocationLabel: order.deliveryLocationLabel,
            roomNumber: order.roomNumber,
            items: order.items,
            specialInstructions: order.specialInstructions,
            status: status,
            subtotalAmount: order.subtotalAmount,
            taxAmount: order.taxAmount,
            totalAmount: order.totalAmount,
            requestedFor: order.requestedFor,
            createdAt: order.createdAt,
            updatedAt: dateProvider.now,
            fulfilledAt: status == .delivered ? dateProvider.now : order.fulfilledAt
        )

        let session = resolvedSession()

        if shouldUseFallback(for: session) {
            return storeFallback(updatedOrder, for: session)
        }

        let data = try FirestoreDateCoding.preparedDiningOrderData(from: updatedOrder)
        do {
            try await remoteStore.setDocument(
                at: FirestorePath.hotelSubcollectionDocument(
                    hotelID: updatedOrder.hotelID,
                    subcollection: .diningOrders,
                    documentID: updatedOrder.id
                ),
                data: data,
                merge: true
            )

            return updatedOrder
        } catch let error as FirestoreRemoteStoreError where error == .unavailable {
            return storeFallback(updatedOrder, for: session)
        }
    }
}

private extension DiningOrderService {
    func resolvedSession() -> UserSession {
        sessionCoordinator.resolvedSession()
    }

    func shouldUseFallback(for session: UserSession) -> Bool {
        sessionCoordinator.canUseFallback(for: session) || !remoteStore.isAvailable()
    }

    func fallbackOrders(for session: UserSession) -> [DiningOrderRecord] {
        if let existing = fallbackOrdersByUserID[session.id] {
            return existing.sorted { ($0.createdAt ?? .distantPast) > ($1.createdAt ?? .distantPast) }
        }

        let seeded = sampleOrders(for: session)
        fallbackOrdersByUserID[session.id] = seeded
        return seeded.sorted { ($0.createdAt ?? .distantPast) > ($1.createdAt ?? .distantPast) }
    }

    func storeFallback(_ order: DiningOrderRecord, for session: UserSession) -> DiningOrderRecord {
        var orders = fallbackOrders(for: session).filter { $0.id != order.id }
        orders.append(order)
        fallbackOrdersByUserID[session.id] = orders
        return order
    }

    func sampleOrders(for session: UserSession) -> [DiningOrderRecord] {
        let now = Date()

        return [
            DiningOrderRecord(
                id: "dining-order-sample-001",
                hotelID: "cinnamon-thiya",
                guestUserID: session.id,
                guest: GuestSnapshot(
                    userID: session.id,
                    fullName: session.displayName ?? "Kawish Jayawardena",
                    email: session.email,
                    phoneNumber: nil
                ),
                stayID: "stay-sample-cinnamon-thiya-001",
                venueName: "In-Room Dining",
                deliveryType: .roomService,
                deliveryLocationLabel: "Room 508",
                roomNumber: "508",
                items: [
                    DiningOrderItem(
                        id: "item-club-sandwich",
                        menuItemID: "menu-club-sandwich",
                        name: "Club Sandwich",
                        quantity: 1,
                        unitPrice: MoneyAmount(currencyCode: "LKR", amountMinorUnits: 4200),
                        notes: nil
                    ),
                    DiningOrderItem(
                        id: "item-iced-tea",
                        menuItemID: "menu-iced-tea",
                        name: "Ceylon Iced Tea",
                        quantity: 2,
                        unitPrice: MoneyAmount(currencyCode: "LKR", amountMinorUnits: 950),
                        notes: nil
                    )
                ],
                specialInstructions: "Please avoid mayonnaise.",
                status: .preparing,
                subtotalAmount: MoneyAmount(currencyCode: "LKR", amountMinorUnits: 6100),
                taxAmount: MoneyAmount(currencyCode: "LKR", amountMinorUnits: 610),
                totalAmount: MoneyAmount(currencyCode: "LKR", amountMinorUnits: 6710),
                requestedFor: nil,
                createdAt: Calendar.current.date(byAdding: .minute, value: -18, to: now),
                updatedAt: Calendar.current.date(byAdding: .minute, value: -10, to: now),
                fulfilledAt: nil
            ),
            DiningOrderRecord(
                id: "dining-order-sample-002",
                hotelID: "cinnamon-thiya",
                guestUserID: session.id,
                guest: GuestSnapshot(
                    userID: session.id,
                    fullName: session.displayName ?? "Kawish Jayawardena",
                    email: session.email,
                    phoneNumber: nil
                ),
                stayID: "stay-sample-cinnamon-thiya-001",
                venueName: "Lagoon Grill",
                deliveryType: .restaurantPickup,
                deliveryLocationLabel: "Restaurant Pickup Counter",
                roomNumber: nil,
                items: [
                    DiningOrderItem(
                        id: "item-seafood-bisque",
                        menuItemID: "menu-seafood-bisque",
                        name: "Seafood Bisque",
                        quantity: 1,
                        unitPrice: MoneyAmount(currencyCode: "LKR", amountMinorUnits: 3600),
                        notes: nil
                    )
                ],
                specialInstructions: nil,
                status: .ready,
                subtotalAmount: MoneyAmount(currencyCode: "LKR", amountMinorUnits: 3600),
                taxAmount: MoneyAmount(currencyCode: "LKR", amountMinorUnits: 360),
                totalAmount: MoneyAmount(currencyCode: "LKR", amountMinorUnits: 3960),
                requestedFor: nil,
                createdAt: Calendar.current.date(byAdding: .hour, value: -2, to: now),
                updatedAt: Calendar.current.date(byAdding: .minute, value: -55, to: now),
                fulfilledAt: nil
            )
        ]
    }

    func normalizedRoomNumber(_ roomNumber: String?) -> String? {
        let trimmed = roomNumber?.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed?.isEmpty == true ? nil : trimmed
    }

    func resolvedRoomNumber(
        inputRoomNumber: String?,
        stayRoomNumber: String?,
        deliveryType: DiningDeliveryType
    ) -> String? {
        guard deliveryType == .roomService else {
            return nil
        }

        return normalizedRoomNumber(inputRoomNumber) ?? normalizedRoomNumber(stayRoomNumber)
    }

    func normalizedInstructions(_ value: String?) -> String? {
        let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed?.isEmpty == true ? nil : trimmed
    }

    func deliveryLabel(for deliveryType: DiningDeliveryType, roomNumber: String?) -> String {
        switch deliveryType {
        case .roomService:
            return normalizedRoomNumber(roomNumber).map { "Room \($0)" } ?? "Guest Room"
        case .restaurantPickup:
            return "Restaurant Pickup Counter"
        case .poolsideDelivery:
            return "Poolside Lounger Delivery"
        }
    }
}
