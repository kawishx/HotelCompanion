//
//  BillingSummaryViewModel.swift
//  HotelCompanion
//
//  File: Features/Billing/ViewModels/BillingSummaryViewModel.swift
//

import Combine
import Foundation

@MainActor
final class BillingSummaryViewModel: ObservableObject {
    @Published private(set) var summaries: [BillingSummaryRecord] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let billingSummaryService: BillingSummaryServicing

    init(billingSummaryService: BillingSummaryServicing? = nil) {
        self.billingSummaryService = billingSummaryService ?? BillingSummaryService.shared
    }

    var currentSummary: BillingSummaryRecord? {
        summaries.first
    }

    var isEmpty: Bool {
        !isLoading && summaries.isEmpty && errorMessage == nil
    }

    func loadBillingSummary() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            summaries = try await billingSummaryService.fetchCurrentUserBillingSummaries()
        } catch {
            summaries = []
            errorMessage = error.localizedDescription
        }
    }

    func amount(for category: String) -> MoneyAmount? {
        guard let summary = currentSummary else { return nil }
        let filtered = summary.lineItems.filter { $0.category == category }
        let total = filtered.reduce(0) { $0 + $1.amount.amountMinorUnits }
        return MoneyAmount(currencyCode: summary.totalAmount.currencyCode, amountMinorUnits: total)
    }

    func formatCurrency(_ amount: MoneyAmount) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = amount.currencyCode
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter.string(from: NSNumber(value: Double(amount.amountMinorUnits) / 100)) ?? "\(amount.currencyCode) \(amount.amountMinorUnits)"
    }
}
