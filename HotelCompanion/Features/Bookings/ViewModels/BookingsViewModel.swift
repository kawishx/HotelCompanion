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
    let guestName: String
    let confirmationCode: String
    let propertyName: String

    var qrPayload: String {
        "cinnamon-booking|\(confirmationCode)|\(guestName)|\(propertyName)"
    }
}

@MainActor
final class BookingsViewModel: ObservableObject {
    @Published private(set) var upcomingBookings: [BookingSummary] = [
        BookingSummary(
            title: "Oceanfront Suite",
            detail: "12 May to 15 May • 2 guests",
            guestName: "Kawish Jayawardena",
            confirmationCode: "CC48291",
            propertyName: "Cinnamon Bentota Beach"
        ),
        BookingSummary(
            title: "Airport Transfer",
            detail: "Arrival pickup requested • Awaiting confirmation",
            guestName: "Kawish Jayawardena",
            confirmationCode: "CC48292",
            propertyName: "Cinnamon Bentota Beach"
        )
    ]
    @Published private(set) var bookedExperiences: [ExperienceBooking]

    init() {
        let calendar = Calendar.current
        let experienceStart = calendar.date(bySettingHour: 17, minute: 30, second: 0, of: Date()) ?? Date()
        let experienceEnd = calendar.date(byAdding: .hour, value: 2, to: experienceStart) ?? experienceStart
        let spaStart = calendar.date(byAdding: .day, value: 1, to: experienceStart) ?? experienceStart
        let spaEnd = calendar.date(byAdding: .hour, value: 1, to: spaStart) ?? spaStart

        bookedExperiences = [
            ExperienceBooking(
                title: "Sunset River Cruise",
                category: "Signature Experience",
                summary: "A curated evening cruise with refreshments and guided local storytelling.",
                location: "Bentota Jetty",
                startDate: experienceStart,
                endDate: experienceEnd
            ),
            ExperienceBooking(
                title: "Oceanfront Wellness Ritual",
                category: "Spa & Wellness",
                summary: "A private relaxation journey with aromatherapy and coastal-inspired treatments.",
                location: "Cinnamon Bentota Spa Pavilion",
                startDate: spaStart,
                endDate: spaEnd
            )
        ]
    }
}
