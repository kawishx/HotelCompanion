//
//  GeofenceEvent.swift
//  HotelCompanion
//
//  File: Features/Geofencing/Models/GeofenceEvent.swift
//

import Foundation

enum GeofenceEvent: String {
    case none
    case didEnterHotel
    case didExitHotel

    var title: String {
        switch self {
        case .none:
            return "No geofence event yet"
        case .didEnterHotel:
            return "Entered hotel zone"
        case .didExitHotel:
            return "Exited hotel zone"
        }
    }
}

