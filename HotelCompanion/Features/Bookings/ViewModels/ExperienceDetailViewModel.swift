//
//  ExperienceDetailViewModel.swift
//  HotelCompanion
//
//  File: Features/Bookings/ViewModels/ExperienceDetailViewModel.swift
//

import Foundation

@MainActor
final class ExperienceDetailViewModel: ObservableObject {
    @Published private(set) var experience: ExperienceBooking
    @Published var alertItem: CalendarAlertItem?
    @Published private(set) var isSavingToCalendar = false

    private let calendarManager: CalendarManager

    init(
        experience: ExperienceBooking,
        calendarManager: CalendarManager = .shared
    ) {
        self.experience = experience
        self.calendarManager = calendarManager
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
        case .failure(let message):
            alertItem = CalendarAlertItem(title: "Calendar Error", message: message)
        }
    }
}

