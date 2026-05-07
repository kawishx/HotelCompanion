//
//  ActivityTimelineViewModel.swift
//  HotelCompanion
//
//  File: Features/Timeline/ViewModels/ActivityTimelineViewModel.swift
//

import Foundation

@MainActor
final class ActivityTimelineViewModel: ObservableObject {
    @Published private(set) var events: [ActivityTimelineRecord] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let activityTimelineService: ActivityTimelineServicing

    init(activityTimelineService: ActivityTimelineServicing = ActivityTimelineService.shared) {
        self.activityTimelineService = activityTimelineService
    }

    var isEmpty: Bool {
        !isLoading && events.isEmpty && errorMessage == nil
    }

    func loadTimeline() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            events = try await activityTimelineService.fetchCurrentUserTimeline()
        } catch {
            events = []
            errorMessage = error.localizedDescription
        }
    }

    func title(for eventType: ActivityEventType) -> String {
        switch eventType {
        case .accountCreated:
            return "Account Created"
        case .bookingConfirmed:
            return "Booking Confirmed"
        case .checkInCompleted:
            return "Check-In"
        case .checkOutCompleted:
            return "Check-Out"
        case .roomAssigned:
            return "Room Assigned"
        case .serviceRequested:
            return "Service Request"
        case .diningOrdered:
            return "Dining Order"
        case .conciergeRequested:
            return "Concierge"
        case .paymentPosted:
            return "Billing"
        case .favoriteSaved:
            return "Favorite Saved"
        case .notificationOpened:
            return "Notification"
        }
    }
}
