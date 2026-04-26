//
//  BookingConfirmationViewModel.swift
//  HotelCompanion
//
//  File: Features/Bookings/ViewModels/BookingConfirmationViewModel.swift
//

import Foundation

@MainActor
final class BookingConfirmationViewModel: ObservableObject {
    @Published private(set) var booking: BookingSummary

    init(booking: BookingSummary) {
        self.booking = booking
    }
}

