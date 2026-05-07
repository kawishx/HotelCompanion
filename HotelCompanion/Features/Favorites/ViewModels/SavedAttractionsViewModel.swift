//
//  SavedAttractionsViewModel.swift
//  HotelCompanion
//
//  File: Features/Favorites/ViewModels/SavedAttractionsViewModel.swift
//

import Foundation

@MainActor
final class SavedAttractionsViewModel: ObservableObject {
    @Published private(set) var savedAttractions: [SavedAttractionRecord] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let savedAttractionsService: SavedAttractionsServicing

    init(savedAttractionsService: SavedAttractionsServicing = SavedAttractionsService.shared) {
        self.savedAttractionsService = savedAttractionsService
    }

    var isEmpty: Bool {
        !isLoading && savedAttractions.isEmpty && errorMessage == nil
    }

    func loadSavedAttractions() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            savedAttractions = try await savedAttractionsService.fetchCurrentUserSavedAttractions()
        } catch {
            savedAttractions = []
            errorMessage = error.localizedDescription
        }
    }

    func remove(_ attraction: SavedAttractionRecord) async {
        do {
            try await savedAttractionsService.removeSavedAttraction(attraction)
            savedAttractions.removeAll { $0.id == attraction.id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func distanceText(for attraction: SavedAttractionRecord) -> String {
        if let distanceMeters = attraction.attraction.distanceMeters {
            if distanceMeters < 1000 {
                return "\(Int(distanceMeters.rounded())) m from hotel"
            }

            return String(format: "%.1f km from hotel", distanceMeters / 1000)
        }

        return attraction.attraction.shortLocationName
    }
}
