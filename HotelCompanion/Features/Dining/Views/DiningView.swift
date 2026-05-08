//
//  DiningView.swift
//  HotelCompanion
//
//  File: Features/Dining/Views/DiningView.swift
//

import SwiftUI

@MainActor
struct DiningView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @StateObject private var viewModel: DiningViewModel

    init(viewModel: DiningViewModel? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel ?? DiningViewModel())
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.large) {
                SectionCard(
                    title: "Dining",
                    subtitle: "Place food orders, review your cart, and track delivery updates"
                ) {
                    VStack(alignment: .leading, spacing: AppSpacing.medium) {
                        Text("Use Firestore-backed dining orders to coordinate room service and hotel food delivery in one place.")
                            .font(AppTypography.body)
                            .foregroundStyle(AppColors.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)

                        HStack(spacing: AppSpacing.medium) {
                            diningSummaryPill(title: "In Cart", value: "\(viewModel.cartItemCount)")
                            diningSummaryPill(title: "Active Orders", value: "\(viewModel.activeOrders.count)")
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("Dining summary")
                        .accessibilityValue("\(viewModel.cartItemCount) items in cart, \(viewModel.activeOrders.count) active orders")

                        if let successMessage = viewModel.successMessage {
                            Text(successMessage)
                                .font(AppTypography.footnote)
                                .foregroundStyle(AppColors.brandBrown)
                                .fixedSize(horizontal: false, vertical: true)
                                .accessibilityLabel("Success. \(successMessage)")
                        }

                        if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                                .font(AppTypography.footnote)
                                .foregroundStyle(.red.opacity(0.85))
                                .fixedSize(horizontal: false, vertical: true)
                                .accessibilityLabel("Error. \(errorMessage)")
                        }
                    }
                }

                SectionCard(title: "Menu Highlights", subtitle: "Curated favorites from the hotel kitchens") {
                    VStack(alignment: .leading, spacing: AppSpacing.large) {
                        ForEach(viewModel.menuItems) { menuItem in
                            VStack(alignment: .leading, spacing: AppSpacing.small) {
                                Text(menuItem.name)
                                    .font(AppTypography.headline)
                                    .foregroundStyle(AppColors.primaryText)

                                Text(menuItem.description)
                                    .font(AppTypography.body)
                                    .foregroundStyle(AppColors.secondaryText)
                                    .fixedSize(horizontal: false, vertical: true)

                                Text("\(menuItem.venueName) • \(viewModel.formatCurrency(menuItem.price))")
                                    .font(AppTypography.footnote)
                                    .foregroundStyle(AppColors.secondaryText)
                                    .accessibilityLabel("Venue and price")
                                    .accessibilityValue("\(menuItem.venueName), \(viewModel.formatCurrency(menuItem.price))")

                                Button {
                                    viewModel.clearMessages()
                                    viewModel.addToCart(menuItem)
                                } label: {
                                    HStack(spacing: AppSpacing.small) {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.headline)

                                        Text("Add to Cart")
                                            .font(AppTypography.bodyEmphasized)
                                    }
                                    .foregroundStyle(AppColors.brandBrown)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .frame(minHeight: AppSpacing.minimumTouchTarget)
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel("Add \(menuItem.name) to cart")
                                .accessibilityHint("Adds this item to your current dining order")
                            }
                            .accessibilityElement(children: .combine)
                        }
                    }
                }

                CartSummaryView(viewModel: viewModel)

                PrimaryButton(
                    title: viewModel.isSubmitting ? "Placing Order..." : "Place Order",
                    systemImage: "bag.fill.badge.plus"
                ) {
                    Task {
                        _ = await viewModel.placeOrder()
                    }
                }
                .disabled(!viewModel.canPlaceOrder)
                .opacity(viewModel.canPlaceOrder ? 1 : 0.6)
                .accessibilityLabel("Place dining order")
                .accessibilityValue("\(viewModel.cartItemCount) items, total \(viewModel.formatCurrency(viewModel.totalAmount))")

                FoodOrderTrackingView(viewModel: viewModel)
            }
            .padding(.horizontal, AppSpacing.screenPadding)
            .padding(.vertical, AppSpacing.large)
        }
        .background(AppColors.backgroundCream.ignoresSafeArea())
        .navigationTitle("Dining")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            Task {
                await viewModel.loadOrders()
            }
        }
        .refreshable {
            await viewModel.loadOrders()
        }
    }
}

private extension DiningView {
    func diningSummaryPill(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
            Text(title)
                .font(AppTypography.footnote)
                .foregroundStyle(AppColors.secondaryText)

            Text(value)
                .font(AppTypography.headline)
                .foregroundStyle(AppColors.primaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppSpacing.medium)
        .background(AppColors.surfaceCream)
        .overlay(
            RoundedRectangle(cornerRadius: AppSpacing.buttonCornerRadius, style: .continuous)
                .stroke(AppColors.border, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.buttonCornerRadius, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
        .accessibilityValue(value)
    }
}

#Preview {
    NavigationStack {
        DiningView()
    }
}
