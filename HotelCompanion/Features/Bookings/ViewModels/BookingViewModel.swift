//
//  BookingViewModel.swift
//  HotelCompanion
//
//  File: Features/Bookings/ViewModels/BookingViewModel.swift
//

import Foundation

@MainActor
final class BookingViewModel: ObservableObject {
    @Published private(set) var bookings: [BookingSummary] = []
    @Published private(set) var availableExperiences: [ExperienceBooking]
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var successMessage: String?
    @Published private(set) var activeBookingID: String?
    @Published var alertItem: CalendarAlertItem?

    private let bookingService: BookingServicing
    private let calendarManager: CalendarManager

    init(
        bookingService: BookingServicing = BookingService.shared,
        calendarManager: CalendarManager = .shared
    ) {
        self.bookingService = bookingService
        self.calendarManager = calendarManager

        let calendar = Calendar.current
        let sunsetStart = calendar.date(bySettingHour: 17, minute: 30, second: 0, of: Date()) ?? Date()
        let sunsetEnd = calendar.date(byAdding: .hour, value: 2, to: sunsetStart) ?? sunsetStart
        let wellnessStart = calendar.date(byAdding: .day, value: 1, to: sunsetStart) ?? sunsetStart
        let wellnessEnd = calendar.date(byAdding: .hour, value: 1, to: wellnessStart) ?? wellnessStart

        availableExperiences = [
            ExperienceBooking(
                id: "experience-river-cruise",
                hotelID: "cinnamon-thiya",
                title: "Sunset River Cruise",
                category: "Signature Experience",
                summary: "A curated evening cruise with refreshments and guided local storytelling.",
                location: "Cinnamon Thiya Jetty",
                startDate: sunsetStart,
                endDate: sunsetEnd
            ),
            ExperienceBooking(
                id: "experience-wellness-ritual",
                hotelID: "cinnamon-thiya",
                title: "Oceanfront Wellness Ritual",
                category: "Spa & Wellness",
                summary: "A private relaxation journey with aromatherapy and coastal-inspired treatments.",
                location: "Cinnamon Thiya Spa Pavilion",
                startDate: wellnessStart,
                endDate: wellnessEnd
            )
        ]
    }

    var upcomingBookings: [BookingSummary] {
        bookings.sorted { $0.startDate < $1.startDate }
    }

    var experienceBookings: [BookingSummary] {
        bookings.filter { $0.experienceID != nil }
    }

    var isEmpty: Bool {
        !isLoading && bookings.isEmpty && errorMessage == nil
    }

    func loadBookings() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let records = try await bookingService.fetchCurrentUserBookings()
            bookings = records.map(BookingSummary.init(record:))
        } catch {
            bookings = []
            errorMessage = error.localizedDescription
        }
    }

    func cancelBooking(_ booking: BookingSummary) async {
        await performMutation(for: booking.id, successMessage: "\(booking.title) was cancelled.") {
            let record = bookingRecord(for: booking)
            let updated = try await bookingService.cancelBooking(record)
            return BookingSummary(record: updated)
        }
    }

    func rescheduleBooking(_ booking: BookingSummary, startDate: Date, endDate: Date?) async {
        await performMutation(for: booking.id, successMessage: "\(booking.title) was rescheduled.") {
            let record = bookingRecord(for: booking)
            let updated = try await bookingService.rescheduleBooking(record, startDate: startDate, endDate: endDate)
            return BookingSummary(record: updated)
        }
    }

    func addBookingToCalendar(_ booking: BookingSummary) async {
        activeBookingID = booking.id
        let result = await calendarManager.addBookedExperienceToCalendar(
            title: booking.title,
            startDate: booking.startDate,
            endDate: booking.endDate ?? booking.startDate.addingTimeInterval(3600),
            notes: booking.detail,
            location: booking.propertyName
        )
        activeBookingID = nil

        switch result {
        case .success(let message):
            alertItem = CalendarAlertItem(title: "Added to Calendar", message: message)
        case .failure(let message):
            alertItem = CalendarAlertItem(title: "Calendar Error", message: message)
        }
    }

    func clearMessages() {
        errorMessage = nil
        successMessage = nil
    }
}

private extension BookingViewModel {
    func performMutation(
        for bookingID: String,
        successMessage: String,
        operation: () async throws -> BookingSummary?
    ) async {
        activeBookingID = bookingID
        errorMessage = nil
        self.successMessage = nil
        defer { activeBookingID = nil }

        do {
            if let updatedBooking = try await operation() {
                bookings.removeAll { $0.id == updatedBooking.id }
                bookings.append(updatedBooking)
                bookings.sort { $0.startDate < $1.startDate }
            }
            self.successMessage = successMessage
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func bookingRecord(for booking: BookingSummary) -> BookingRecord {
        BookingRecord(
            id: booking.id,
            hotelID: booking.hotelID,
            guestUserID: booking.guestUserID,
            guest: GuestSnapshot(
                userID: booking.guestUserID,
                fullName: booking.guestName,
                email: nil,
                phoneNumber: nil
            ),
            stayID: nil,
            experienceID: booking.experienceID,
            category: booking.experienceID == nil ? .room : .experience,
            status: booking.status,
            title: booking.title,
            summary: booking.detail,
            confirmationCode: booking.confirmationCode,
            qrPayloadSource: booking.qrPayloadSource,
            startDate: booking.startDate,
            endDate: booking.endDate,
            guestCount: booking.guestCount,
            totalAmount: nil,
            sourceChannel: "ios-app",
            createdAt: Date(),
            updatedAt: Date()
        )
    }
}
