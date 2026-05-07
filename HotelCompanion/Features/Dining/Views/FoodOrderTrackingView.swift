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
        SectionCard(title: "Order Tracking", subtitle: "Follow the latest updates from the hotel kitchen") {
            VStack(alignment: .leading, spacing: AppSpacing.large) {
                if viewModel.isLoading {
                    HStack(spacing: AppSpacing.medium) {
                        ProgressView()
                            .tint(AppColors.brandBrown)

                        Text("Loading your dining orders.")
                            .font(AppTypography.body)
                            .foregroundStyle(AppColors.secondaryText)
                    }
                    .frame(minHeight: AppSpacing.minimumTouchTarget)
                } else if let errorMessage = viewModel.errorMessage, viewModel.currentOrders.isEmpty {
                    Text(errorMessage)
                        .font(AppTypography.body)
                        .foregroundStyle(.red.opacity(0.85))
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityLabel("Unable to load dining orders. \(errorMessage)")
                } else if viewModel.isEmpty {
                    Text("Once you place a food order, status updates will appear here.")
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
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

                                Text(viewModel.displayTitle(for: order.status))
                                    .font(AppTypography.footnote)
                                    .foregroundStyle(AppColors.brandBrown)
                                    .padding(.horizontal, AppSpacing.small)
                                    .padding(.vertical, AppSpacing.xSmall)
                                    .background(AppColors.accentGoldSoft.opacity(0.35))
                                    .clipShape(Capsule())
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
}

private extension FoodOrderTrackingView {
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
