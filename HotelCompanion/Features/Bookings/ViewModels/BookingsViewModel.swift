//
//  BookingsViewModel.swift
//  HotelCompanion
//
//  File: Features/Bookings/ViewModels/BookingsViewModel.swift
//

import Combine
import Foundation

struct BookingSummary: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
}

final class BookingsViewModel: ObservableObject {
    @Published private(set) var upcomingBookings: [BookingSummary] = [
        BookingSummary(title: "Oceanfront Suite", detail: "12 May to 15 May • 2 guests"),
        BookingSummary(title: "Airport Transfer", detail: "Arrival pickup requested • Awaiting confirmation")
    ]
}
