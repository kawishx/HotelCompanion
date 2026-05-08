//
//  ExperienceDetailViewModel.swift
//  HotelCompanion
//
//  File: Features/Bookings/ViewModels/ExperienceDetailViewModel.swift
//

import Combine
import Foundation

@MainActor
final class ExperienceDetailViewModel: ObservableObject {
    @Published private(set) var experience: ExperienceBooking
    @Published var alertItem: CalendarAlertItem?
    @Published private(set) var isSavingToCalendar = false
    @Published private(set) var isCreatingBooking = false
    @Published private(set) var createdBooking: BookingSummary?
    @Published private(set) var bookingErrorMessage: String?
    @Published private(set) var bookingSuccessMessage: String?
    @Published var guestCount: Int

    private let calendarManager: CalendarManager
    private let bookingService: BookingServicing

    init(
        experience: ExperienceBooking,
        calendarManager: CalendarManager = .shared,
        bookingService: BookingServicing = BookingService.shared
    ) {
        self.experience = experience
        self.calendarManager = calendarManager
        self.bookingService = bookingService
        self.guestCount = experience.defaultGuestCount
    }

    func addToCalendar() async {
        isSavingToCalendar = true
        let result = await calendarManager.addBookedExperienceToCalendar(
            title: experience.title,
            startDate: experience.startDate,
            endDate: experience.endDate,
            notes: experience.calendarNotes,
            location: experience.location
        )
        isSavingToCalendar = false

        switch result {
        case .success(let message):
            alertItem = CalendarAlertItem(title: "Added to Calendar", message: message)
        case .failure(let error):
            alertItem = CalendarAlertItem(title: "Calendar Error", message: error.localizedDescription)
        }
    }

    func createBooking() async {
        isCreatingBooking = true
        bookingErrorMessage = nil
        bookingSuccessMessage = nil
        defer { isCreatingBooking = false }

        do {
            let booking = try await bookingService.createBooking(for: experience, guestCount: guestCount)
            createdBooking = BookingSummary(record: booking)
            bookingSuccessMessage = "\(experience.title) was booked successfully."
        } catch {
            bookingErrorMessage = error.localizedDescription
        }
    }
}
