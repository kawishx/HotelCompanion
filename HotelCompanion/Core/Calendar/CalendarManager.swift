//
//  CalendarManager.swift
//  HotelCompanion
//
//  File: Core/Calendar/CalendarManager.swift
//

import EventKit
import Foundation

struct CalendarEventPayload {
    let title: String
    let startDate: Date
    let endDate: Date
    let notes: String
    let location: String?
}

enum CalendarManagerError: LocalizedError, Equatable {
    case message(String)

    var errorDescription: String? {
        switch self {
        case .message(let message):
            return message
        }
    }
}

enum CalendarPermissionState: Equatable {
    case authorized
    case denied(String)
    case restricted(String)
    case notDetermined
    case unknown(String)
}

final class CalendarManager {
    static let shared = CalendarManager()

    private let eventStore = EKEventStore()

    typealias PermissionResult = Result<Void, CalendarManagerError>
    typealias EventCreationResult = Result<String, CalendarManagerError>

    func currentPermissionState() -> CalendarPermissionState {
        let status = EKEventStore.authorizationStatus(for: .event)

        switch status {
        case .fullAccess, .writeOnly:
            return .authorized
        case .denied:
            return .denied("Calendar access has been denied. Enable it in Settings to add events.")
        case .restricted:
            return .restricted("Calendar access is restricted on this device.")
        case .notDetermined:
            return .notDetermined
        @unknown default:
            return .unknown("Calendar permission status is unavailable right now.")
        }
    }

    func requestCalendarPermission() async -> PermissionResult {
        switch currentPermissionState() {
        case .authorized:
            return .success(())
        case .denied(let message), .restricted(let message), .unknown(let message):
            return .failure(.message(message))
        case .notDetermined:
            return await withCheckedContinuation { continuation in
                eventStore.requestWriteOnlyAccessToEvents { granted, error in
                    if granted {
                        continuation.resume(returning: .success(()))
                    } else if let error {
                        continuation.resume(returning: .failure(.message(self.userFriendlyMessage(for: error))))
                    } else {
                        continuation.resume(returning: .failure(.message("Calendar access was not granted.")))
                    }
                }
            }
        }
    }

    func createEvent(_ payload: CalendarEventPayload) async -> EventCreationResult {
        let permissionResult = await requestCalendarPermission()

        switch permissionResult {
        case .failure(let error):
            return .failure(error)
        case .success:
            guard let calendar = eventStore.defaultCalendarForNewEvents else {
                return .failure(.message("No writable calendar is available on this device."))
            }

            let event = EKEvent(eventStore: eventStore)
            event.calendar = calendar
            event.title = payload.title
            event.startDate = payload.startDate
            event.endDate = payload.endDate
            event.notes = payload.notes
            event.location = payload.location

            do {
                try eventStore.save(event, span: .thisEvent, commit: true)
                return .success("Added \"\(payload.title)\" to your calendar.")
            } catch {
                return .failure(.message(userFriendlyMessage(for: error)))
            }
        }
    }

    func addBookedExperienceToCalendar(
        title: String,
        startDate: Date,
        endDate: Date,
        notes: String,
        location: String?
    ) async -> EventCreationResult {
        let payload = CalendarEventPayload(
            title: title,
            startDate: startDate,
            endDate: endDate,
            notes: notes,
            location: location
        )

        return await createEvent(payload)
    }

    private func userFriendlyMessage(for error: Error) -> String {
        let nsError = error as NSError

        if nsError.domain == EKErrorDomain,
           let code = EKError.Code(rawValue: nsError.code) {
            switch code {
            case .eventNotMutable:
                return "This calendar event cannot be modified."
            case .noCalendar:
                return "No calendar is available for saving this event."
            case .calendarReadOnly:
                return "The selected calendar is read-only."
            case .sourceDoesNotAllowEvents:
                return "This calendar account does not allow new events."
            case .eventStoreNotAuthorized:
                return "Calendar access is not authorized."
            default:
                return "The event could not be saved to Calendar. Please try again."
            }
        }

        return "The event could not be saved to Calendar. Please try again."
    }
}
