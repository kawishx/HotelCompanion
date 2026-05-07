//
//  ExperienceBooking.swift
//  HotelCompanion
//
//  File: Features/Bookings/Models/ExperienceBooking.swift
//

import Foundation

struct ExperienceBooking: Identifiable, Codable, Hashable {
    let id: String
    let hotelID: String
    let experienceID: String
    let title: String
    let category: String
    let summary: String
    let location: String
    let startDate: Date
    let endDate: Date
    let defaultGuestCount: Int

    init(
        id: String? = nil,
        hotelID: String = "cinnamon-thiya",
        experienceID: String? = nil,
        title: String,
        category: String,
        summary: String,
        location: String,
        startDate: Date,
        endDate: Date,
        defaultGuestCount: Int = 2
    ) {
        let resolvedExperienceID = experienceID ?? id ?? UUID().uuidString
        self.id = id ?? resolvedExperienceID
        self.hotelID = hotelID
        self.experienceID = resolvedExperienceID
        self.title = title
        self.category = category
        self.summary = summary
        self.location = location
        self.startDate = startDate
        self.endDate = endDate
        self.defaultGuestCount = defaultGuestCount
    }

    var calendarNotes: String {
        "\(summary)\nLocation: \(location)"
    }
}

struct BookingSummary: Identifiable, Hashable {
    let id: String
    let title: String
    let detail: String
    let guestName: String
    let confirmationCode: String
    let propertyName: String
    let hotelID: String
    let guestUserID: String
    let experienceID: String?
    let startDate: Date
    let endDate: Date?
    let guestCount: Int
    let status: BookingStatus
    let qrPayloadSource: String

    init(
        id: String = UUID().uuidString,
        title: String,
        detail: String,
        guestName: String,
        confirmationCode: String,
        propertyName: String,
        hotelID: String = "cinnamon-thiya",
        guestUserID: String = "preview-user",
        experienceID: String? = nil,
        startDate: Date = Date(),
        endDate: Date? = nil,
        guestCount: Int = 1,
        status: BookingStatus = .confirmed,
        qrPayloadSource: String? = nil
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.guestName = guestName
        self.confirmationCode = confirmationCode
        self.propertyName = propertyName
        self.hotelID = hotelID
        self.guestUserID = guestUserID
        self.experienceID = experienceID
        self.startDate = startDate
        self.endDate = endDate
        self.guestCount = guestCount
        self.status = status
        self.qrPayloadSource = qrPayloadSource ?? "cinnamon-booking|\(hotelID)|\(id)|\(experienceID ?? "stay")|\(confirmationCode)|\(guestUserID)"
    }

    var qrPayload: String {
        qrPayloadSource
    }
}

extension BookingSummary {
    init(record: BookingRecord) {
        let propertyName = record.hotelID.replacingOccurrences(of: "-", with: " ").capitalized
        let dateText = record.startDate.formatted(date: .abbreviated, time: .shortened)
        let endText = record.endDate?.formatted(date: .abbreviated, time: .shortened)
        let guestText = record.guestCount == 1 ? "1 guest" : "\(record.guestCount) guests"
        let statusText = record.status.rawValue.replacingOccurrences(of: "([a-z])([A-Z])", with: "$1 $2", options: .regularExpression).capitalized
        let detail = [dateText, endText, guestText, statusText]
            .compactMap { $0 }
            .joined(separator: " • ")

        self.init(
            id: record.id,
            title: record.title,
            detail: detail,
            guestName: record.guest.fullName,
            confirmationCode: record.confirmationCode,
            propertyName: propertyName,
            hotelID: record.hotelID,
            guestUserID: record.guestUserID,
            experienceID: record.experienceID,
            startDate: record.startDate,
            endDate: record.endDate,
            guestCount: record.guestCount,
            status: record.status,
            qrPayloadSource: record.qrPayloadSource
        )
    }
}
