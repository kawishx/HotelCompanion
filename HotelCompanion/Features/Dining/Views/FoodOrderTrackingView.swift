//
//  FoodOrderTrackingView.swift
//  HotelCompanion
//
//  File: Features/Dining/Views/FoodOrderTrackingView.swift
//

import SwiftUI

struct FoodOrderTrackingView: View {
    @ObservedObject var viewModel: DiningViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.large) {
            if let successMessage = viewModel.successMessage {
                SuccessToastBanner(message: successMessage)
            }

            contentSection
        }
    }
}

private extension FoodOrderTrackingView {
    @ViewBuilder
    var contentSection: some View {
        if viewModel.isLoading {
            SectionCard(title: "Order Tracking", subtitle: "Follow the latest updates from the hotel kitchen") {
                LoadingStateView(
                    title: "Loading Dining Orders",
                    message: "Fetching the latest updates from the kitchen.",
                    systemImage: "fork.knife.circle.fill"
                )
            }
        } else if let errorMessage = viewModel.errorMessage, viewModel.currentOrders.isEmpty {
            ErrorStateCard(
                title: "Unable to Load Orders",
                subtitle: "Please try again in a moment",
                message: errorMessage,
                retryTitle: "Refresh Orders",
                retryAction: {
                    Task {
                        await viewModel.loadOrders()
                    }
                }
            )
        } else if viewModel.isEmpty {
            EmptyStateCard(
                title: "No Dining Orders",
                subtitle: "Status updates will appear here after your first order",
                message: "Once you place a food order, preparation and delivery updates will appear in this section.",
                systemImage: "fork.knife"
            )
        } else {
            SectionCard(title: "Order Tracking", subtitle: "Follow the latest updates from the hotel kitchen") {
                VStack(alignment: .leading, spacing: AppSpacing.large) {
                    ForEach(viewModel.currentOrders) { order in
                        VStack(alignment: .leading, spacing: AppSpacing.medium) {
                            HStack(alignment: .top, spacing: AppSpacing.medium) {
                                VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
                                    Text(order.venueName)
                                        .font(AppTypography.headline)
                                        .foregroundStyle(AppColors.primaryText)

                                    Text(order.deliveryLocationLabel)
                                        .font(AppTypography.body)
                                        .foregroundStyle(AppColors.secondaryText)
                                }

                                Spacer()

                                StatusChip(
                                    title: viewModel.displayTitle(for: order.status),
                                    systemImage: "fork.knife.circle.fill",
                                    tone: .accent,
                                    size: .compact
                                )
                                .accessibilityLabel("Order status")
                                .accessibilityValue(viewModel.displayTitle(for: order.status))
                            }

                            Text(viewModel.orderItemsSummary(for: order))
                                .font(AppTypography.body)
                                .foregroundStyle(AppColors.secondaryText)
                                .fixedSize(horizontal: false, vertical: true)

                            Text("Placed \(viewModel.formattedCreatedAt(for: order))")
                                .font(AppTypography.footnote)
                                .foregroundStyle(AppColors.secondaryText)

                            Text(viewModel.formatCurrency(order.totalAmount))
                                .font(AppTypography.bodyEmphasized)
                                .foregroundStyle(AppColors.primaryText)

                            if
                                let nextStatus = viewModel.nextStatus(for: order),
                                let actionTitle = viewModel.actionTitle(for: order),
                                let actionSystemImage = viewModel.actionSystemImage(for: order)
                            {
                                Button {
                                    Task {
                                        await viewModel.updateOrderStatus(order, status: nextStatus)
                                    }
                                } label: {
                                    trackingActionLabel(
                                        title: actionTitle,
                                        systemImage: actionSystemImage
                                    )
                                }
                                .buttonStyle(.plain)
                                .disabled(viewModel.activeOrderID == order.id)
                                .opacity(viewModel.activeOrderID == order.id ? 0.6 : 1)
                            }
                        }
                        .accessibilityElement(children: .combine)
                    }
                }
            }
        }
    }

    func trackingActionLabel(title: String, systemImage: String) -> some View {
        HStack(spacing: AppSpacing.small) {
            Image(systemName: systemImage)
                .font(.headline)

            Text(title)
                .font(AppTypography.bodyEmphasized)
        }
        .foregroundStyle(AppColors.brandBrown)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(minHeight: AppSpacing.minimumTouchTarget)
        .padding(.horizontal, AppSpacing.medium)
        .background(AppColors.surfaceCream)
        .overlay(
            RoundedRectangle(cornerRadius: AppSpacing.buttonCornerRadius, style: .continuous)
                .stroke(AppColors.border, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.buttonCornerRadius, style: .continuous))
    }
}

#Preview {
    FoodOrderTrackingView(viewModel: DiningViewModel())
        .padding()
        .background(AppColors.backgroundCream)
}
