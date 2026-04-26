//
//  ExperienceBooking.swift
//  HotelCompanion
//
//  File: Features/Bookings/Models/ExperienceBooking.swift
//

import Foundation

struct ExperienceBooking: Identifiable {
    let id = UUID()
    let title: String
    let category: String
    let summary: String
    let location: String
    let startDate: Date
    let endDate: Date

    var calendarNotes: String {
        "\(summary)\nLocation: \(location)"
    }
}

