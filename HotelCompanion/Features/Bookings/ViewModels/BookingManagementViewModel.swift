//
//  BookingManagementViewModel.swift
//  HotelCompanion
//
//  File: Features/Bookings/ViewModels/BookingManagementViewModel.swift
//

import Foundation

@MainActor
final class BookingManagementViewModel: ObservableObject {
    @Published private(set) var upcomingBookings: [BookingSummary]
    @Published private(set) var bookedExperiences: [ExperienceBooking]
    @Published var alertItem: CalendarAlertItem?
    @Published private(set) var savingExperienceID: UUID?

    private let calendarManager: CalendarManager

    init(
        upcomingBookings: [BookingSummary],
        bookedExperiences: [ExperienceBooking],
        calendarManager: CalendarManager = .shared
    ) {
        self.upcomingBookings = upcomingBookings
        self.bookedExperiences = bookedExperiences
        self.calendarManager = calendarManager
    }

    func addExperienceToCalendar(_ experience: ExperienceBooking) async {
        savingExperienceID = experience.id
        let result = await calendarManager.addBookedExperienceToCalendar(
            title: experience.title,
            startDate: experience.startDate,
            endDate: experience.endDate,
            notes: experience.calendarNotes,
            location: experience.location
        )
        savingExperienceID = nil

        switch result {
        case .success(let message):
            alertItem = CalendarAlertItem(title: "Added to Calendar", message: message)
        case .failure(let message):
            alertItem = CalendarAlertItem(title: "Calendar Error", message: message)
        }
    }
}

