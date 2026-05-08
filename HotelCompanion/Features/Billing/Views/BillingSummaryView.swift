//
//  BillingSummaryView.swift
//  HotelCompanion
//
//  File: Features/Billing/Views/BillingSummaryView.swift
//

import SwiftUI

@MainActor
struct BillingSummaryView: View {
    @StateObject private var viewModel: BillingSummaryViewModel

    init(viewModel: BillingSummaryViewModel? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel ?? BillingSummaryViewModel())
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.large) {
                SectionCard(
                    title: "Billing Summary",
                    subtitle: "Room, food, experiences, and extra services"
                ) {
                    content
                }
            }
            .padding(.horizontal, AppSpacing.screenPadding)
            .padding(.vertical, AppSpacing.large)
        }
        .background(AppColors.backgroundCream.ignoresSafeArea())
        .navigationTitle("Billing")
        .navigationBarTitleDisplayMode(.large)
        .task {
            await viewModel.loadBillingSummary()
        }
        .refreshable {
            await viewModel.loadBillingSummary()
        }
    }
}

private extension BillingSummaryView {
    @ViewBuilder
    var content: some View {
        if viewModel.isLoading {
            HStack(spacing: AppSpacing.medium) {
                ProgressView()
                    .tint(AppColors.brandBrown)

                Text("Loading your folio summary.")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.secondaryText)
            }
            .frame(minHeight: AppSpacing.minimumTouchTarget)
        } else if let errorMessage = viewModel.errorMessage {
            Text(errorMessage)
                .font(AppTypography.body)
                .foregroundStyle(.red.opacity(0.85))
                .fixedSize(horizontal: false, vertical: true)
        } else if let summary = viewModel.currentSummary {
            VStack(alignment: .leading, spacing: AppSpacing.large) {
                summaryRow(title: "Room Charges", amount: viewModel.amount(for: "room"))
                summaryRow(title: "Food Charges", amount: viewModel.amount(for: "food"))
                summaryRow(title: "Experience Charges", amount: viewModel.amount(for: "experience"))
                summaryRow(title: "Extra Service Charges", amount: viewModel.amount(for: "service"))

                Divider()

                summaryRow(title: "Subtotal", amount: summary.subtotalAmount)
                summaryRow(title: "Tax", amount: summary.taxAmount)
                summaryRow(title: "Total", amount: summary.totalAmount, emphasized: true)

                Text("Folio \(summary.folioNumber) • \(summary.issuedAt.formatted(date: .abbreviated, time: .shortened))")
                    .font(AppTypography.footnote)
                    .foregroundStyle(AppColors.secondaryText)
            }
        } else {
            Text("Your current billing summary will appear here once charges are synced to Firestore.")
                .font(AppTypography.body)
                .foregroundStyle(AppColors.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    func summaryRow(title: String, amount: MoneyAmount?, emphasized: Bool = false) -> some View {
        HStack {
            Text(title)
                .font(emphasized ? AppTypography.bodyEmphasized : AppTypography.body)
                .foregroundStyle(AppColors.primaryText)

            Spacer()

            Text(amount.map { viewModel.formatCurrency($0) } ?? "LKR 0.00")
                .font(emphasized ? AppTypography.bodyEmphasized : AppTypography.body)
                .foregroundStyle(emphasized ? AppColors.brandBrown : AppColors.secondaryText)
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    NavigationStack {
        BillingSummaryView()
    }
}
