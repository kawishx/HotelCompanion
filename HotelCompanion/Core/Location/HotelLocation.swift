//
//  HotelLocation.swift
//  HotelCompanion
//
//  File: Core/Location/HotelLocation.swift
//

import CoreLocation
import Foundation

struct HotelLocation {
    let name: String
    let subtitle: String
    let latitude: CLLocationDegrees
    let longitude: CLLocationDegrees

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

