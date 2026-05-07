//
//  Attraction.swift
//  HotelCompanion
//
//  File: Features/Explore/Models/Attraction.swift
//

import CoreLocation
import Foundation

enum AttractionCategory: String, CaseIterable, Identifiable {
    case beaches = "Beaches"
    case restaurants = "Restaurants"
    case touristSpots = "Tourist Spots"
    case shopping = "Shopping"

    var id: String { rawValue }

    var symbolName: String {
        switch self {
        case .beaches:
            return "sun.max.fill"
        case .restaurants:
            return "fork.knife"
        case .touristSpots:
            return "camera.fill"
        case .shopping:
            return "bag.fill"
        }
    }
}

struct Attraction: Identifiable, Equatable {
    let id: UUID
    let title: String
    let category: AttractionCategory
    let latitude: CLLocationDegrees
    let longitude: CLLocationDegrees
    let shortDescription: String
    let imageURLString: String

    init(
        id: UUID = UUID(),
        title: String,
        category: AttractionCategory,
        latitude: CLLocationDegrees,
        longitude: CLLocationDegrees,
        shortDescription: String,
        imageURLString: String
    ) {
        self.id = id
        self.title = title
        self.category = category
        self.latitude = latitude
        self.longitude = longitude
        self.shortDescription = shortDescription
        self.imageURLString = imageURLString
    }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var imageURL: URL? {
        URL(string: imageURLString)
    }
}

extension AttractionCategory {
    var favoriteCategory: FavoriteAttractionCategory {
        switch self {
        case .beaches:
            return .beach
        case .restaurants:
            return .restaurant
        case .touristSpots:
            return .touristSpot
        case .shopping:
            return .shopping
        }
    }
}

extension FavoriteAttractionCategory {
    var attractionCategory: AttractionCategory {
        switch self {
        case .beach:
            return .beaches
        case .restaurant:
            return .restaurants
        case .touristSpot:
            return .touristSpots
        case .shopping:
            return .shopping
        case .other:
            return .touristSpots
        }
    }
}
