//
//  BillingSummaryCalculatorTests.swift
//  HotelCompanionTests
//
//  File: HotelCompanionTests/Logic/BillingSummaryCalculatorTests.swift
//

import XCTest
@testable import HotelCompanion

final class BillingSummaryCalculatorTests: XCTestCase {
    func testAmountForCategoryReturnsSummedLineItems() {
        let summary = makeBillingSummary()

        let roomAmount = BillingSummaryCalculator.amount(for: "room", in: summary)
        let foodAmount = BillingSummaryCalculator.amount(for: "food", in: summary)

        XCTAssertEqual(roomAmount?.amountMinorUnits, 145_000)
        XCTAssertEqual(foodAmount?.amountMinorUnits, 12_450)
    }

    func testSubtotalConsistencyUsesLineItems() {
        let summary = makeBillingSummary()

        XCTAssertEqual(BillingSummaryCalculator.subtotalFromLineItems(in: summary).amountMinorUnits, 163_450)
        XCTAssertTrue(BillingSummaryCalculator.isSubtotalConsistent(for: summary))
    }
}
