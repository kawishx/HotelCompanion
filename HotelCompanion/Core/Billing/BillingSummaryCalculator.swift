//
//  BillingSummaryCalculator.swift
//  HotelCompanion
//
//  File: Core/Billing/BillingSummaryCalculator.swift
//

import Foundation

enum BillingSummaryCalculator {
    static func amount(for category: String, in summary: BillingSummaryRecord) -> MoneyAmount? {
        let filtered = summary.lineItems.filter { $0.category == category }
        let totalMinorUnits = filtered.reduce(0) { $0 + $1.amount.amountMinorUnits }

        return MoneyAmount(
            currencyCode: summary.totalAmount.currencyCode,
            amountMinorUnits: totalMinorUnits
        )
    }

    static func subtotalFromLineItems(in summary: BillingSummaryRecord) -> MoneyAmount {
        let totalMinorUnits = summary.lineItems.reduce(0) { $0 + $1.amount.amountMinorUnits }

        return MoneyAmount(
            currencyCode: summary.totalAmount.currencyCode,
            amountMinorUnits: totalMinorUnits
        )
    }

    static func isSubtotalConsistent(for summary: BillingSummaryRecord) -> Bool {
        subtotalFromLineItems(in: summary).amountMinorUnits == summary.subtotalAmount.amountMinorUnits
    }
}
