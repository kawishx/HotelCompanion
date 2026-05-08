//
//  LocationManager.swift
//  HotelCompanion
//
//  File: Core/Location/LocationManager.swift
//

import Combine
import CoreLocation
import Foundation

final class LocationManager: NSObject, ObservableObject {
    @Published private(set) var authorizationStatus: CLAuthorizationStatus
    @Published private(set) var currentLocation: CLLocation?
    @Published private(set) var deniedMessage: String?

    private let manager = CLLocationManager()

    override init() {
        authorizationStatus = manager.authorizationStatus
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        updateAuthorizationState(authorizationStatus)
    }

    var isAuthorized: Bool {
        authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways
    }

    var isDeniedOrRestricted: Bool {
        authorizationStatus == .denied || authorizationStatus == .restricted
    }

    func requestPermission() {
        guard CLLocationManager.locationServicesEnabled() else {
            deniedMessage = "Location Services are currently disabled on this device."
            return
        }

        manager.requestWhenInUseAuthorization()
    }

    func startUpdatingLocation() {
        guard CLLocationManager.locationServicesEnabled() else {
            deniedMessage = "Location Services are currently disabled on this device."
            return
        }

        switch authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            deniedMessage = nil
            manager.startUpdatingLocation()
            manager.requestLocation()
        case .notDetermined:
            requestPermission()
        case .denied, .restricted:
            updateAuthorizationState(authorizationStatus)
        @unknown default:
            deniedMessage = "Location access is unavailable right now."
        }
    }

    func stopUpdatingLocation() {
        manager.stopUpdatingLocation()
    }

    private func updateAuthorizationState(_ status: CLAuthorizationStatus) {
        authorizationStatus = status

        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            deniedMessage = nil
        case .denied, .restricted:
            currentLocation = nil
            deniedMessage = "Location access is turned off. Enable it in Settings to show your live position on the map."
            manager.stopUpdatingLocation()
        case .notDetermined:
            deniedMessage = nil
        @unknown default:
            deniedMessage = "Location permission is in an unknown state."
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        updateAuthorizationState(manager.authorizationStatus)

        if isAuthorized {
            startUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if !isDeniedOrRestricted {
            deniedMessage = "Your location could not be determined right now. Please try again in a moment."
        }
    }
}
