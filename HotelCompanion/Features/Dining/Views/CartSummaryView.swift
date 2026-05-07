//
//  CartSummaryView.swift
//  HotelCompanion
//
//  File: Features/Dining/Views/CartSummaryView.swift
//

import SwiftUI

struct CartSummaryView: View {
    @ObservedObject var viewModel: DiningViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.large) {
            SectionCard(title: "Cart Summary", subtitle: "Review your order before sending it to the hotel") {
                VStack(alignment: .leading, spacing: AppSpacing.large) {
                    if viewModel.cartItems.isEmpty {
                        Text("Your cart is empty. Add a few dining items to continue.")
                            .font(AppTypography.body)
                            .foregroundStyle(AppColors.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)
                    } else {
                        ForEach(viewModel.cartItems) { cartItem in
                            VStack(alignment: .leading, spacing: AppSpacing.small) {
                                Text(cartItem.menuItem.name)
                                    .font(AppTypography.headline)
                                    .foregroundStyle(AppColors.primaryText)

                                Text("\(cartItem.quantity) item\(cartItem.quantity == 1 ? "" : "s") • \(viewModel.formatCurrency(cartItem.menuItem.price)) each")
                                    .font(AppTypography.body)
                                    .foregroundStyle(AppColors.secondaryText)

                                HStack(spacing: AppSpacing.medium) {
                                    Button {
                                        viewModel.decrementCartItem(cartItem)
                                    } label: {
                                        Text("Reduce")
                                            .font(AppTypography.bodyEmphasized)
                                            .foregroundStyle(AppColors.brandBrown)
                                    }
                                    .buttonStyle(.plain)
                                    .accessibilityLabel("Reduce quantity of \(cartItem.menuItem.name)")

                                    Button {
                                        viewModel.removeFromCart(cartItem)
                                    } label: {
                                        Text("Remove")
                                            .font(AppTypography.bodyEmphasized)
                                            .foregroundStyle(.red.opacity(0.85))
                                    }
                                    .buttonStyle(.plain)
                                    .accessibilityLabel("Remove \(cartItem.menuItem.name) from cart")
                                }
                                .frame(minHeight: AppSpacing.minimumTouchTarget)
                            }
                            .accessibilityElement(children: .combine)
                        }

                        Divider()

                        summaryRow(title: "Subtotal", value: viewModel.formatCurrency(viewModel.subtotalAmount))
                        summaryRow(title: "Estimated Tax", value: viewModel.formatCurrency(viewModel.estimatedTaxAmount))
                        summaryRow(title: "Total", value: viewModel.formatCurrency(viewModel.totalAmount))

                        VStack(alignment: .leading, spacing: AppSpacing.small) {
                            Text("Delivery Type")
                                .font(AppTypography.headline)
                                .foregroundStyle(AppColors.primaryText)

                            Picker("Delivery Type", selection: $viewModel.deliveryType) {
                                Text("Room Service").tag(DiningDeliveryType.roomService)
                                Text("Restaurant Pickup").tag(DiningDeliveryType.restaurantPickup)
                                Text("Poolside Delivery").tag(DiningDeliveryType.poolsideDelivery)
                            }
                            .pickerStyle(.segmented)
                            .accessibilityLabel("Dining delivery type")
                        }

                        if viewModel.shouldShowRoomNumberField {
                            VStack(alignment: .leading, spacing: AppSpacing.small) {
                                Text("Room Number")
                                    .font(AppTypography.headline)
                                    .foregroundStyle(AppColors.primaryText)

                                TextField("e.g. 508", text: $viewModel.roomNumber)
                                    .textFieldStyle(AppTextFieldStyle())
                                    .accessibilityLabel("Delivery room number")

                                Text("Leave this blank if you want to use the room assigned to your active stay.")
                                    .font(AppTypography.footnote)
                                    .foregroundStyle(AppColors.secondaryText)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }

                        VStack(alignment: .leading, spacing: AppSpacing.small) {
                            Text("Notes")
                                .font(AppTypography.headline)
                                .foregroundStyle(AppColors.primaryText)

                            TextField("Optional dietary or delivery notes", text: $viewModel.orderNotes, axis: .vertical)
                                .lineLimit(2...4)
                                .textFieldStyle(AppTextFieldStyle())
                                .accessibilityLabel("Order notes")
                        }
                    }
                }
            }
        }
    }
}

private extension CartSummaryView {
    func summaryRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.secondaryText)

            Spacer()

            Text(value)
                .font(AppTypography.bodyEmphasized)
                .foregroundStyle(AppColors.primaryText)
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    CartSummaryView(viewModel: DiningViewModel())
        .padding()
        .background(AppColors.backgroundCream)
}
