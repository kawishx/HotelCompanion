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
    private let notificationCenter = UNUserNotificationCenter.current()
    private let geofenceIdentifier = "com.cinnamoncompanion.hotel.cinnamon-thiya"

    override init() {
        locationAuthorizationStatus = CLLocationManager.authorizationStatus()
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
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
        notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { [weak self] _, _ in
            DispatchQueue.main.async {
                self?.refreshNotificationSettings()
            }
        }
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
        notificationCenter.getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.notificationAuthorizationStatus = settings.authorizationStatus
                self?.updateStatusMessage()
            }
        }
    }

    private func handleRegionEntry() {
        currentRegionState = .inside
        lastEvent = .didEnterHotel
        statusMessage = "Welcome to Cinnamon Thiya. Check-in assistance is ready."
        scheduleNotification(
            title: "Welcome to Cinnamon Thiya",
            body: "You're at the hotel. Open Cinnamon Companion to complete check-in and view your stay."
        )
    }

    private func handleRegionExit() {
        currentRegionState = .outside
        lastEvent = .didExitHotel
        statusMessage = "Leaving the hotel? Concierge and checkout support are ready when you need them."
        scheduleNotification(
            title: "Need help before you go?",
            body: "Open Cinnamon Companion for concierge support, transport help, or a smooth checkout."
        )
    }

    private func scheduleNotification(title: String, body: String) {
        notificationCenter.getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.notificationAuthorizationStatus = settings.authorizationStatus

                guard self?.notificationsEnabled == true else { return }

                let content = UNMutableNotificationContent()
                content.title = title
                content.body = body
                content.sound = .default

                let request = UNNotificationRequest(
                    identifier: UUID().uuidString,
                    content: content,
                    trigger: nil
                )

                self?.notificationCenter.add(request)
            }
        }
    }

    private func updateStatusMessage() {
        switch locationAuthorizationStatus {
        case .authorizedAlways:
            if isMonitoringHotelRegion {
                switch currentRegionState {
                case .inside:
                    statusMessage = "You are currently inside the Cinnamon Thiya hotel zone."
                case .outside:
                    statusMessage = "Hotel geofencing is active. We'll let you know when you arrive or leave."
                case .unknown:
                    statusMessage = "Hotel geofencing is active and waiting for your current region state."
                @unknown default:
                    statusMessage = "Hotel geofencing is active."
                }
            } else {
                statusMessage = "Always Location is enabled. Start hotel geofencing whenever you're ready."
            }
        case .authorizedWhenInUse:
            statusMessage = "Upgrade to Always Location to receive hotel arrival and departure alerts."
        case .notDetermined:
            statusMessage = "Enable Always Location and notifications for hotel arrival assistance."
        case .denied, .restricted:
            statusMessage = "Location permission is off. Enable Always Location in Settings to use hotel geofencing."
        @unknown default:
            statusMessage = "Geofence status is unavailable right now."
        }
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
