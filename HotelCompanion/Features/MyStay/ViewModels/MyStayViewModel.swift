//
//  MyStayViewModel.swift
//  HotelCompanion
//
//  File: Features/MyStay/ViewModels/MyStayViewModel.swift
//

import Combine
import Foundation

@MainActor
final class MyStayViewModel: ObservableObject {
    @Published private(set) var stay: StayRecord?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let stayService: StayServicing
    private let dateFormatter: DateIntervalFormatter
    private let timeFormatter: DateFormatter

    init(stayService: StayServicing? = nil) {
        self.stayService = stayService ?? StayService.shared

        let dateFormatter = DateIntervalFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        self.dateFormatter = dateFormatter

        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        timeFormatter.dateStyle = .none
        self.timeFormatter = timeFormatter
    }

    var title: String {
        stay?.room.roomType ?? "My Stay"
    }

    var subtitle: String {
        guard let stay else {
            return "Your current or upcoming hotel stay"
        }

        return formattedDateRange(for: stay)
    }

    var hotelDisplayName: String {
        humanizedHotelID(stay?.hotelID) ?? "Cinnamon Thiya Hotel"
    }

    var roomDisplay: String {
        guard let stay else { return "Room details will appear here." }

        let roomNumber = stay.room.roomNumber.map { "Room \($0)" } ?? "Room assignment pending"
        return "\(roomNumber) • \(stay.room.roomType)"
    }

    var bookingDisplay: String {
        stay?.confirmationCode ?? "No confirmation code available"
    }

    var guestCountDisplay: String {
        guard let stay else { return "Guest details unavailable" }

        let totalGuests = stay.adultCount + stay.childCount
        return totalGuests == 1 ? "1 guest" : "\(totalGuests) guests"
    }

    var wingDisplay: String? {
        guard let stay else { return nil }

        return [stay.room.wingName, stay.room.floorLabel]
            .compactMap { $0 }
            .joined(separator: " • ")
            .nilIfEmpty
    }

    var highlightText: String {
        stay?.specialNotes ?? "Your stay details will update here once hotel systems sync."
    }

    var checkInTimeText: String {
        stay.map { timeFormatter.string(from: $0.checkInDate) } ?? "Unavailable"
    }

    var checkOutTimeText: String {
        stay.map { timeFormatter.string(from: $0.checkOutDate) } ?? "Unavailable"
    }

    var statusTitle: String {
        stay?.status.rawValue.replacingOccurrences(of: "([a-z])([A-Z])", with: "$1 $2", options: .regularExpression).capitalized ?? "Unavailable"
    }

    var isEmpty: Bool {
        !isLoading && stay == nil && errorMessage == nil
    }

    func loadStay() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            stay = try await stayService.fetchCurrentStay()
        } catch {
            stay = nil
            errorMessage = error.localizedDescription
        }
    }

    private func formattedDateRange(for stay: StayRecord) -> String {
        dateFormatter.string(from: stay.checkInDate, to: stay.checkOutDate)
    }

    private func humanizedHotelID(_ hotelID: String?) -> String? {
        hotelID?
            .replacingOccurrences(of: "-", with: " ")
            .capitalized
    }
}

private extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}
