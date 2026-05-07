//
//  ConciergeViewModel.swift
//  HotelCompanion
//
//  File: Features/Concierge/ViewModels/ConciergeViewModel.swift
//

import Foundation

@MainActor
final class ConciergeViewModel: ObservableObject {
    @Published var selectedRequestType: ConciergeRequestType = .reservation
    @Published var title = ""
    @Published var detail = ""
    @Published var requestedFor = Date()
    @Published var partySize = 2
    @Published private(set) var requests: [ConciergeRequestRecord] = []
    @Published private(set) var isLoading = false
    @Published private(set) var isSubmitting = false
    @Published private(set) var activeRequestID: String?
    @Published private(set) var errorMessage: String?
    @Published private(set) var successMessage: String?

    private let conciergeRequestService: ConciergeRequestServicing

    init(conciergeRequestService: ConciergeRequestServicing = ConciergeRequestService.shared) {
        self.conciergeRequestService = conciergeRequestService
    }

    var canSubmit: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !detail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !isSubmitting
    }

    var isEmpty: Bool {
        !isLoading && requests.isEmpty && errorMessage == nil
    }

    func loadRequests() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            requests = try await conciergeRequestService.fetchCurrentUserConciergeRequests()
                .sorted { ($0.createdAt ?? .distantPast) > ($1.createdAt ?? .distantPast) }
        } catch {
            requests = []
            errorMessage = error.localizedDescription
        }
    }

    @discardableResult
    func submitRequest() async -> Bool {
        isSubmitting = true
        errorMessage = nil
        successMessage = nil
        defer { isSubmitting = false }

        do {
            let request = try await conciergeRequestService.createConciergeRequest(
                requestType: selectedRequestType,
                title: title,
                detail: detail,
                requestedFor: requestedFor,
                partySize: partySize
            )

            requests.removeAll { $0.id == request.id }
            requests.insert(request, at: 0)
            successMessage = "Your concierge request has been sent."
            resetForm()
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func updateStatus(for request: ConciergeRequestRecord, to status: ConciergeRequestStatus) async {
        activeRequestID = request.id
        errorMessage = nil
        successMessage = nil
        defer { activeRequestID = nil }

        do {
            let updated = try await conciergeRequestService.updateRequestStatus(request, status: status)
            requests.removeAll { $0.id == updated.id }
            requests.append(updated)
            requests.sort { ($0.createdAt ?? .distantPast) > ($1.createdAt ?? .distantPast) }
            successMessage = "Concierge request updated to \(displayTitle(for: status))."
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func displayTitle(for type: ConciergeRequestType) -> String {
        switch type {
        case .transport:
            return "Transport"
        case .reservation:
            return "Reservation"
        case .excursion:
            return "Excursion"
        case .celebration:
            return "Celebration"
        case .airportTransfer:
            return "Airport Transfer"
        case .other:
            return "Other"
        }
    }

    func displayTitle(for status: ConciergeRequestStatus) -> String {
        switch status {
        case .submitted:
            return "Submitted"
        case .reviewing:
            return "Reviewing"
        case .confirmed:
            return "Confirmed"
        case .fulfilled:
            return "Fulfilled"
        case .cancelled:
            return "Cancelled"
        }
    }

    func formattedDate(for request: ConciergeRequestRecord) -> String {
        (request.requestedFor ?? request.createdAt ?? Date()).formatted(date: .abbreviated, time: .shortened)
    }

    func clearMessages() {
        errorMessage = nil
        successMessage = nil
    }

    private func resetForm() {
        title = ""
        detail = ""
        selectedRequestType = .reservation
        requestedFor = Date()
        partySize = 2
    }
}
