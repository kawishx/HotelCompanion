//
//  ExploreNearbyViewModel.swift
//  HotelCompanion
//
//  File: Features/Explore/ViewModels/ExploreNearbyViewModel.swift
//

import Combine
import CoreLocation
import Foundation
import MapKit

final class ExploreNearbyViewModel: ObservableObject {
    @Published var selectedCategory: AttractionCategory?
    @Published var selectedAttraction: Attraction?
    @Published private(set) var favoriteAttractionIDs: Set<UUID> = []

    let hotel = HotelLocation(
        name: "Cinnamon Thiya",
        subtitle: "Your hotel base for nearby discovery",
        latitude: 6.9147,
        longitude: 79.8641
    )

    let attractions: [Attraction] = [
        Attraction(
            title: "Galle Face Green",
            category: .beaches,
            latitude: 6.9272,
            longitude: 79.8447,
            shortDescription: "A breezy oceanfront promenade ideal for sunset walks, street snacks, and relaxed evening views.",
            imageURLString: "https://picsum.photos/id/1011/1200/800"
        ),
        Attraction(
            title: "Ministry of Crab",
            category: .restaurants,
            latitude: 6.9344,
            longitude: 79.8449,
            shortDescription: "An iconic Colombo dining destination known for elevated seafood and a memorable heritage setting.",
            imageURLString: "https://picsum.photos/id/1080/1200/800"
        ),
        Attraction(
            title: "Gangaramaya Temple",
            category: .touristSpots,
            latitude: 6.9167,
            longitude: 79.8564,
            shortDescription: "One of Colombo's most beloved landmarks, blending spiritual heritage, architecture, and serene lakefront surroundings.",
            imageURLString: "https://picsum.photos/id/1040/1200/800"
        ),
        Attraction(
            title: "Crescat Boulevard",
            category: .shopping,
            latitude: 6.9211,
            longitude: 79.8487,
            shortDescription: "A convenient luxury shopping stop for fashion, gifts, and quick dining close to the city waterfront.",
            imageURLString: "https://picsum.photos/id/1060/1200/800"
        ),
        Attraction(
            title: "Mount Lavinia Beach",
            category: .beaches,
            latitude: 6.8389,
            longitude: 79.8643,
            shortDescription: "A classic beach escape with golden sand, sea breeze, and a lively coastal dining atmosphere.",
            imageURLString: "https://picsum.photos/id/1015/1200/800"
        ),
        Attraction(
            title: "Dutch Hospital Precinct",
            category: .touristSpots,
            latitude: 6.9350,
            longitude: 79.8428,
            shortDescription: "A beautifully restored colonial landmark filled with cafes, boutiques, and charming nighttime ambience.",
            imageURLString: "https://picsum.photos/id/1035/1200/800"
        ),
        Attraction(
            title: "Park Street Mews",
            category: .restaurants,
            latitude: 6.9151,
            longitude: 79.8586,
            shortDescription: "A stylish dining cluster with intimate ambience, cocktails, and multiple culinary concepts in one place.",
            imageURLString: "https://picsum.photos/id/292/1200/800"
        ),
        Attraction(
            title: "One Galle Face",
            category: .shopping,
            latitude: 6.9286,
            longitude: 79.8445,
            shortDescription: "A premium mall with designer labels, entertainment, and sweeping views near the oceanfront district.",
            imageURLString: "https://picsum.photos/id/1059/1200/800"
        )
    ]

    var filteredAttractions: [Attraction] {
        guard let selectedCategory else { return attractions }
        return attractions.filter { $0.category == selectedCategory }
    }

    var hotelRegion: MKCoordinateRegion {
        MKCoordinateRegion(
            center: hotel.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.12, longitudeDelta: 0.12)
        )
    }

    func selectCategory(_ category: AttractionCategory?) {
        selectedCategory = category
    }

    func selectAttraction(_ attraction: Attraction) {
        selectedAttraction = attraction
    }

    func toggleFavorite(for attraction: Attraction) {
        if favoriteAttractionIDs.contains(attraction.id) {
            favoriteAttractionIDs.remove(attraction.id)
        } else {
            favoriteAttractionIDs.insert(attraction.id)
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

