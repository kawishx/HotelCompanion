//
//  GeofenceManager.swift
//  HotelCompanion
//
//  File: Core/Location/GeofenceManager.swift
//

import Combine
import CoreLocation
import Foundation
import UserNotifications

final class GeofenceManager: NSObject, ObservableObject {
    static let shared = GeofenceManager()

    @Published private(set) var locationAuthorizationStatus: CLAuthorizationStatus
    @Published private(set) var notificationAuthorizationStatus: UNAuthorizationStatus = .notDetermined
    @Published private(set) var currentRegionState: CLRegionState = .unknown
    @Published private(set) var lastEvent: GeofenceEvent = .none
    @Published private(set) var isMonitoringHotelRegion = false
    @Published private(set) var statusMessage = "Hotel arrival alerts are not active yet."

    let hotel = HotelLocation(
        name: "Cinnamon Thiya",
        subtitle: "Hotel arrival assistance",
        latitude: 6.9147,
        longitude: 79.8641
    )

    let geofenceRadius: CLLocationDistance = 180

    private let locationManager = CLLocationManager()
    private let notificationManager: NotificationManager
    private let geofenceIdentifier = "com.cinnamoncompanion.hotel.cinnamon-thiya"
    private var cancellables: Set<AnyCancellable> = []

    init(notificationManager: NotificationManager = .shared) {
        locationAuthorizationStatus = locationManager.authorizationStatus
        self.notificationManager = notificationManager
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        bindNotificationState()
        refreshNotificationSettings()
        updateStatusMessage()
    }

    var canMonitorGeofences: Bool {
        CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self)
    }

    var needsAlwaysLocation: Bool {
        locationAuthorizationStatus != .authorizedAlways
    }

    var notificationsEnabled: Bool {
        notificationAuthorizationStatus == .authorized ||
        notificationAuthorizationStatus == .provisional ||
        notificationAuthorizationStatus == .ephemeral
    }

    func configure() {
        refreshNotificationSettings()
        updateStatusMessage()

        if locationAuthorizationStatus == .authorizedAlways {
            startMonitoringHotelRegion()
        }
    }

    func requestLocationPermission() {
        guard CLLocationManager.locationServicesEnabled() else {
            statusMessage = "Location Services are disabled on this device."
            return
        }

        locationManager.requestAlwaysAuthorization()
    }

    func requestNotificationPermission() {
        notificationManager.requestNotificationPermission()
    }

    func requestRequiredPermissions() {
        requestNotificationPermission()
        requestLocationPermission()
    }

    func startMonitoringHotelRegion() {
        guard canMonitorGeofences else {
            statusMessage = "Geofencing is not supported on this device."
            return
        }

        guard CLLocationManager.locationServicesEnabled() else {
            statusMessage = "Location Services are disabled on this device."
            return
        }

        switch locationAuthorizationStatus {
        case .authorizedAlways:
            let region = hotelRegion
            stopMonitoringHotelRegion()
            locationManager.startMonitoring(for: region)
            isMonitoringHotelRegion = true
            locationManager.requestState(for: region)
            updateStatusMessage()
        case .authorizedWhenInUse:
            statusMessage = "Allow Always Location to receive arrival and departure hotel alerts."
        case .notDetermined:
            requestLocationPermission()
        case .denied, .restricted:
            statusMessage = "Location access is denied. Enable Always Location in Settings for geofence alerts."
        @unknown default:
            statusMessage = "Location permission is unavailable right now."
        }
    }

    func stopMonitoringHotelRegion() {
        let monitoredRegions = locationManager.monitoredRegions.filter { $0.identifier == geofenceIdentifier }

        for region in monitoredRegions {
            locationManager.stopMonitoring(for: region)
        }

        isMonitoringHotelRegion = false
    }

    private var hotelRegion: CLCircularRegion {
        let region = CLCircularRegion(
            center: hotel.coordinate,
            radius: geofenceRadius,
            identifier: geofenceIdentifier
        )
        region.notifyOnEntry = true
        region.notifyOnExit = true
        return region
    }

    private func refreshNotificationSettings() {
        notificationManager.refreshAuthorizationStatus()
    }

    private func handleRegionEntry() {
        let snapshot = GeofenceStateResolver.snapshot(for: .enteredHotel, hotelName: hotel.name)
        currentRegionState = snapshot.regionState
        lastEvent = snapshot.lastEvent
        statusMessage = snapshot.statusMessage
        notificationManager.scheduleGeofenceWelcomeNotification(hotelName: hotel.name)
    }

    private func handleRegionExit() {
        let snapshot = GeofenceStateResolver.snapshot(for: .exitedHotel, hotelName: hotel.name)
        currentRegionState = snapshot.regionState
        lastEvent = snapshot.lastEvent
        statusMessage = snapshot.statusMessage
        notificationManager.scheduleGeofenceExitNotification(hotelName: hotel.name)
    }

    private func updateStatusMessage() {
        statusMessage = GeofenceStateResolver.statusMessage(
            for: locationAuthorizationStatus,
            isMonitoringHotelRegion: isMonitoringHotelRegion,
            currentRegionState: currentRegionState
        )
    }

    private func bindNotificationState() {
        notificationManager.$authorizationStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                self?.notificationAuthorizationStatus = status
                self?.updateStatusMessage()
            }
            .store(in: &cancellables)
    }
}

extension GeofenceManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        locationAuthorizationStatus = manager.authorizationStatus
        updateStatusMessage()

        if locationAuthorizationStatus == .authorizedAlways {
            startMonitoringHotelRegion()
        }
    }

    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        guard region.identifier == geofenceIdentifier else { return }
        isMonitoringHotelRegion = true
        manager.requestState(for: region)
        updateStatusMessage()
    }

    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        guard region.identifier == geofenceIdentifier else { return }
        currentRegionState = state
        updateStatusMessage()
    }

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        guard region.identifier == geofenceIdentifier else { return }
        handleRegionEntry()
    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        guard region.identifier == geofenceIdentifier else { return }
        handleRegionExit()
    }

    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        isMonitoringHotelRegion = false
        statusMessage = "Hotel geofencing could not start. Please check permissions and try again."
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if locationAuthorizationStatus != .denied && locationAuthorizationStatus != .restricted {
            statusMessage = "Location services encountered an issue. Please try again."
        }
    }
}
