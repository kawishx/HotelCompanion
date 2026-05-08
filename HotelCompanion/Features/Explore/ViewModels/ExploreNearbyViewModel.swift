//
//  ExploreNearbyViewModel.swift
//  HotelCompanion
//
//  File: Features/Explore/ViewModels/ExploreNearbyViewModel.swift
//

import CoreLocation
import Combine
import Foundation
import MapKit

@MainActor
final class ExploreNearbyViewModel: ObservableObject {
    @Published var selectedCategory: AttractionCategory?
    @Published var selectedAttraction: Attraction?
    @Published private(set) var favoriteAttractionIDs: Set<UUID> = []
    @Published private(set) var isLoadingFavorites = false
    @Published private(set) var favoriteMessage: String?

    let hotel = HotelLocation(
        name: "Cinnamon Thiya",
        subtitle: "Your hotel base for nearby discovery",
        latitude: 6.9147,
        longitude: 79.8641
    )

    let attractions: [Attraction] = [
        Attraction(
            id: UUID(uuidString: "6B495F87-0A22-442D-9ED9-4A22D0A10001")!,
            title: "Galle Face Green",
            category: .beaches,
            latitude: 6.9272,
            longitude: 79.8447,
            shortDescription: "A breezy oceanfront promenade ideal for sunset walks, street snacks, and relaxed evening views.",
            imageURLString: "https://picsum.photos/id/1011/1200/800"
        ),
        Attraction(
            id: UUID(uuidString: "6B495F87-0A22-442D-9ED9-4A22D0A10002")!,
            title: "Ministry of Crab",
            category: .restaurants,
            latitude: 6.9344,
            longitude: 79.8449,
            shortDescription: "An iconic Colombo dining destination known for elevated seafood and a memorable heritage setting.",
            imageURLString: "https://picsum.photos/id/1080/1200/800"
        ),
        Attraction(
            id: UUID(uuidString: "6B495F87-0A22-442D-9ED9-4A22D0A10003")!,
            title: "Gangaramaya Temple",
            category: .touristSpots,
            latitude: 6.9167,
            longitude: 79.8564,
            shortDescription: "One of Colombo's most beloved landmarks, blending spiritual heritage, architecture, and serene lakefront surroundings.",
            imageURLString: "https://picsum.photos/id/1040/1200/800"
        ),
        Attraction(
            id: UUID(uuidString: "6B495F87-0A22-442D-9ED9-4A22D0A10004")!,
            title: "Crescat Boulevard",
            category: .shopping,
            latitude: 6.9211,
            longitude: 79.8487,
            shortDescription: "A convenient luxury shopping stop for fashion, gifts, and quick dining close to the city waterfront.",
            imageURLString: "https://picsum.photos/id/1060/1200/800"
        ),
        Attraction(
            id: UUID(uuidString: "6B495F87-0A22-442D-9ED9-4A22D0A10005")!,
            title: "Mount Lavinia Beach",
            category: .beaches,
            latitude: 6.8389,
            longitude: 79.8643,
            shortDescription: "A classic beach escape with golden sand, sea breeze, and a lively coastal dining atmosphere.",
            imageURLString: "https://picsum.photos/id/1015/1200/800"
        ),
        Attraction(
            id: UUID(uuidString: "6B495F87-0A22-442D-9ED9-4A22D0A10006")!,
            title: "Dutch Hospital Precinct",
            category: .touristSpots,
            latitude: 6.9350,
            longitude: 79.8428,
            shortDescription: "A beautifully restored colonial landmark filled with cafes, boutiques, and charming nighttime ambience.",
            imageURLString: "https://picsum.photos/id/1035/1200/800"
        ),
        Attraction(
            id: UUID(uuidString: "6B495F87-0A22-442D-9ED9-4A22D0A10007")!,
            title: "Park Street Mews",
            category: .restaurants,
            latitude: 6.9151,
            longitude: 79.8586,
            shortDescription: "A stylish dining cluster with intimate ambience, cocktails, and multiple culinary concepts in one place.",
            imageURLString: "https://picsum.photos/id/292/1200/800"
        ),
        Attraction(
            id: UUID(uuidString: "6B495F87-0A22-442D-9ED9-4A22D0A10008")!,
            title: "One Galle Face",
            category: .shopping,
            latitude: 6.9286,
            longitude: 79.8445,
            shortDescription: "A premium mall with designer labels, entertainment, and sweeping views near the oceanfront district.",
            imageURLString: "https://picsum.photos/id/1059/1200/800"
        )
    ]

    private let savedAttractionsService: SavedAttractionsServicing
    private let authService: AuthServicing
    private var savedRecordsByAttractionID: [UUID: SavedAttractionRecord] = [:]

    init(
        savedAttractionsService: SavedAttractionsServicing? = nil,
        authService: AuthServicing? = nil
    ) {
        self.savedAttractionsService = savedAttractionsService ?? SavedAttractionsService.shared
        self.authService = authService ?? AuthService.shared
    }

    var filteredAttractions: [Attraction] {
        guard let selectedCategory else { return attractions }
        return attractions.filter { $0.category == selectedCategory }
    }

    var savedAttractions: [Attraction] {
        attractions.filter { favoriteAttractionIDs.contains($0.id) }
    }

    var hotelRegion: MKCoordinateRegion {
        MKCoordinateRegion(
            center: hotel.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.12, longitudeDelta: 0.12)
        )
    }

    func loadSavedAttractions() async {
        isLoadingFavorites = true
        defer { isLoadingFavorites = false }

        do {
            let records = try await savedAttractionsService.fetchCurrentUserSavedAttractions()
            savedRecordsByAttractionID = Dictionary(uniqueKeysWithValues: records.compactMap { record in
                guard let id = UUID(uuidString: record.attraction.attractionID ?? record.id) else {
                    return nil
                }

                return (id, record)
            })
            favoriteAttractionIDs = Set(savedRecordsByAttractionID.keys)
        } catch {
            favoriteMessage = error.localizedDescription
        }
    }

    func selectCategory(_ category: AttractionCategory?) {
        selectedCategory = category
    }

    func selectAttraction(_ attraction: Attraction) {
        selectedAttraction = attraction
    }

    func toggleFavorite(for attraction: Attraction) async {
        do {
            if let record = savedRecordsByAttractionID[attraction.id] {
                try await savedAttractionsService.removeSavedAttraction(record)
                savedRecordsByAttractionID.removeValue(forKey: attraction.id)
                favoriteAttractionIDs.remove(attraction.id)
                favoriteMessage = "\(attraction.title) was removed from your saved places."
            } else {
                let record = makeSavedRecord(for: attraction)
                let saved = try await savedAttractionsService.saveAttraction(record)
                savedRecordsByAttractionID[attraction.id] = saved
                favoriteAttractionIDs.insert(attraction.id)
                favoriteMessage = "\(attraction.title) was saved to your favorites."
            }
        } catch {
            favoriteMessage = error.localizedDescription
        }
    }

    func isFavorite(_ attraction: Attraction) -> Bool {
        favoriteAttractionIDs.contains(attraction.id)
    }

    func distanceText(for attraction: Attraction) -> String {
        let hotelLocation = CLLocation(latitude: hotel.latitude, longitude: hotel.longitude)
        let attractionLocation = CLLocation(latitude: attraction.latitude, longitude: attraction.longitude)
        let distance = attractionLocation.distance(from: hotelLocation)

        if distance < 1000 {
            return "\(Int(distance.rounded())) m from hotel"
        }

        return String(format: "%.1f km from hotel", distance / 1000)
    }

    func region(for attraction: Attraction) -> MKCoordinateRegion {
        MKCoordinateRegion(
            center: attraction.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
        )
    }

    func regionForUserLocation(_ location: CLLocation) -> MKCoordinateRegion {
        MKCoordinateRegion(
            center: location.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.025, longitudeDelta: 0.025)
        )
    }

    func navigationURL(for attraction: Attraction) -> URL? {
        URL(string: "http://maps.apple.com/?daddr=\(attraction.latitude),\(attraction.longitude)&dirflg=w")
    }
}

private extension ExploreNearbyViewModel {
    func makeSavedRecord(for attraction: Attraction) -> SavedAttractionRecord {
        let session = authService.currentSession ?? .guest
        let now = Date()

        return SavedAttractionRecord(
            id: attraction.id.uuidString,
            userID: session.id,
            hotelID: "cinnamon-thiya",
            attraction: AttractionSnapshot(
                attractionID: attraction.id.uuidString,
                title: attraction.title,
                category: attraction.category.favoriteCategory,
                shortLocationName: hotel.name,
                distanceMeters: nil,
                imageURL: attraction.imageURL,
                coordinate: GeoCoordinateSnapshot(
                    latitude: attraction.latitude,
                    longitude: attraction.longitude
                )
            ),
            notes: nil,
            savedAt: now,
            createdAt: now,
            updatedAt: now
        )
    }
}
