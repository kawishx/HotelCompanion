//
//  DiningViewModelTests.swift
//  HotelCompanionTests
//
//  File: HotelCompanionTests/ViewModels/DiningViewModelTests.swift
//

import XCTest
@testable import HotelCompanion

@MainActor
final class DiningViewModelTests: XCTestCase {
    func testCartTotalsReflectCurrentItems() {
        let viewModel = DiningViewModel(diningOrderService: nil)
        let sandwich = viewModel.menuItems[0]
        let tea = viewModel.menuItems[2]

        viewModel.addToCart(sandwich)
        viewModel.addToCart(sandwich)
        viewModel.addToCart(tea)

        XCTAssertEqual(viewModel.cartItemCount, 3)
        XCTAssertEqual(viewModel.subtotalAmount.amountMinorUnits, 9_350)
        XCTAssertEqual(viewModel.estimatedTaxAmount.amountMinorUnits, 935)
        XCTAssertEqual(viewModel.totalAmount.amountMinorUnits, 10_285)
    }

    func testDecrementingCartItemRemovesItAtZero() {
        let viewModel = DiningViewModel(diningOrderService: nil)
        let sandwich = viewModel.menuItems[0]

        viewModel.addToCart(sandwich)
        XCTAssertEqual(viewModel.cartItems.count, 1)

        viewModel.decrementCartItem(viewModel.cartItems[0])
        XCTAssertTrue(viewModel.cartItems.isEmpty)
        XCTAssertEqual(viewModel.subtotalAmount.amountMinorUnits, 0)
    }
}
