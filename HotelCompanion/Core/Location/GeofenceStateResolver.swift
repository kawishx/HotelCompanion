//
//  GeofenceStateResolver.swift
//  HotelCompanion
//
//  File: Core/Location/GeofenceStateResolver.swift
//

import CoreLocation
import Foundation

enum GeofenceRegionTrigger {
    case enteredHotel
    case exitedHotel
}

struct GeofenceEventStateSnapshot: Equatable {
    let regionState: CLRegionState
    let lastEvent: GeofenceEvent
    let statusMessage: String
}

enum GeofenceStateResolver {
    static func snapshot(for trigger: GeofenceRegionTrigger, hotelName: String) -> GeofenceEventStateSnapshot {
        switch trigger {
        case .enteredHotel:
            return GeofenceEventStateSnapshot(
                regionState: .inside,
                lastEvent: .didEnterHotel,
                statusMessage: "Welcome to \(hotelName). Check-in assistance is ready."
            )
        case .exitedHotel:
            return GeofenceEventStateSnapshot(
                regionState: .outside,
                lastEvent: .didExitHotel,
                statusMessage: "Leaving the hotel? Concierge and checkout support are ready when you need them."
            )
        }
    }

    static func statusMessage(
        for authorizationStatus: CLAuthorizationStatus,
        isMonitoringHotelRegion: Bool,
        currentRegionState: CLRegionState
    ) -> String {
        switch authorizationStatus {
        case .authorizedAlways:
            if isMonitoringHotelRegion {
                switch currentRegionState {
                case .inside:
                    return "You are currently inside the Cinnamon Thiya hotel zone."
                case .outside:
                    return "Hotel geofencing is active. We'll let you know when you arrive or leave."
                case .unknown:
                    return "Hotel geofencing is active and waiting for your current region state."
                @unknown default:
                    return "Hotel geofencing is active."
                }
            } else {
                return "Always Location is enabled. Start hotel geofencing whenever you're ready."
            }
        case .authorizedWhenInUse:
            return "Upgrade to Always Location to receive hotel arrival and departure alerts."
        case .notDetermined:
            return "Enable Always Location and notifications for hotel arrival assistance."
        case .denied, .restricted:
            return "Location permission is off. Enable Always Location in Settings to use hotel geofencing."
        @unknown default:
            return "Geofence status is unavailable right now."
        }
    }
}
