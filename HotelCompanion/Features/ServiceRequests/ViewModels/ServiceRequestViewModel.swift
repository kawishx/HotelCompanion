//
//  ServiceRequestViewModel.swift
//  HotelCompanion
//
//  File: Features/ServiceRequests/ViewModels/ServiceRequestViewModel.swift
//

import Combine
import Foundation

@MainActor
final class ServiceRequestViewModel: ObservableObject {
    @Published var selectedRequestType: ServiceRequestCategory = .maintenance
    @Published var priority: ServiceRequestPriority = .normal
    @Published var note = ""
    @Published var roomNumber = ""
    @Published private(set) var requests: [ServiceRequestRecord] = []
    @Published private(set) var isLoadingRequests = false
    @Published private(set) var isSubmitting = false
    @Published private(set) var activeRequestID: String?
    @Published private(set) var errorMessage: String?
    @Published private(set) var successMessage: String?

    private let serviceRequestService: ServiceRequestServicing

    init(serviceRequestService: ServiceRequestServicing = ServiceRequestService.shared) {
        self.serviceRequestService = serviceRequestService
    }

    var canSubmit: Bool {
        !note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isSubmitting
    }

    var isEmpty: Bool {
        !isLoadingRequests && requests.isEmpty && errorMessage == nil
    }

    var recentRequests: [ServiceRequestRecord] {
        Array(requests.prefix(2))
    }

    func loadRequests() async {
        isLoadingRequests = true
        errorMessage = nil
        defer { isLoadingRequests = false }

        do {
            requests = try await serviceRequestService.fetchCurrentUserServiceRequests()
                .sorted { ($0.createdAt ?? .distantPast) > ($1.createdAt ?? .distantPast) }
        } catch {
            requests = []
            errorMessage = error.localizedDescription
        }
    }

    @discardableResult
    func submitRequest(uploadedImageURL: URL?) async -> Bool {
        isSubmitting = true
        errorMessage = nil
        successMessage = nil
        defer { isSubmitting = false }

        do {
            let request = try await serviceRequestService.createServiceRequest(
                requestType: selectedRequestType,
                note: note,
                roomNumber: roomNumber,
                uploadedImageURL: uploadedImageURL,
                priority: priority
            )

            requests.removeAll { $0.id == request.id }
            requests.insert(request, at: 0)
            successMessage = "Your service request has been sent to the hotel team."
            resetForm()
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func updateStatus(for request: ServiceRequestRecord, to status: ServiceRequestStatus) async {
        activeRequestID = request.id
        errorMessage = nil
        successMessage = nil
        defer { activeRequestID = nil }

        do {
            let updatedRequest = try await serviceRequestService.updateRequestStatus(request, status: status)
            requests.removeAll { $0.id == updatedRequest.id }
            requests.append(updatedRequest)
            requests.sort { ($0.createdAt ?? .distantPast) > ($1.createdAt ?? .distantPast) }
            successMessage = "Request status updated to \(displayTitle(for: status))."
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func displayTitle(for requestType: ServiceRequestCategory) -> String {
        switch requestType {
        case .housekeeping:
            return "Housekeeping"
        case .maintenance:
            return "Maintenance"
        case .roomSetup:
            return "Room Setup"
        case .amenities:
            return "Amenities"
        case .other:
            return "Other"
        }
    }

    func displayTitle(for priority: ServiceRequestPriority) -> String {
        switch priority {
        case .low:
            return "Low"
        case .normal:
            return "Normal"
        case .high:
            return "High"
        case .urgent:
            return "Urgent"
        }
    }

    func displayTitle(for status: ServiceRequestStatus) -> String {
        switch status {
        case .open:
            return "Open"
        case .acknowledged:
            return "Acknowledged"
        case .inProgress:
            return "In Progress"
        case .resolved:
            return "Resolved"
        case .closed:
            return "Closed"
        case .cancelled:
            return "Cancelled"
        }
    }

    func formattedCreatedAt(for request: ServiceRequestRecord) -> String {
        guard let createdAt = request.createdAt else {
            return "Pending sync"
        }

        return createdAt.formatted(date: .abbreviated, time: .shortened)
    }

    func clearMessages() {
        errorMessage = nil
        successMessage = nil
    }

    private func resetForm() {
        note = ""
        roomNumber = ""
        selectedRequestType = .maintenance
        priority = .normal
    }
}
