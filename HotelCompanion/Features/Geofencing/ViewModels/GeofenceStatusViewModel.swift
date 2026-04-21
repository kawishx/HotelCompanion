//
//  GeofenceStatusViewModel.swift
//  HotelCompanion
//
//  File: Features/Geofencing/ViewModels/GeofenceStatusViewModel.swift
//

import Combine
import CoreLocation
import Foundation
import UserNotifications

final class GeofenceStatusViewModel: ObservableObject {
    @Published private(set) var hotelName: String
    @Published private(set) var statusTitle = "Hotel Geofencing"
    @Published private(set) var statusMessage = ""
    @Published private(set) var monitoringStateText = "Inactive"
    @Published private(set) var locationStateText = "Location permission not set"
    @Published private(set) var notificationStateText = "Notification permission not set"
    @Published private(set) var lastEventText = "No geofence event yet"
    @Published private(set) var shouldShowPermissionButton = true
    @Published private(set) var shouldShowStartButton = true

    private let geofenceManager: GeofenceManager
    private var cancellables: Set<AnyCancellable> = []

    init(geofenceManager: GeofenceManager = .shared) {
        self.geofenceManager = geofenceManager
        hotelName = geofenceManager.hotel.name
        bind()
        refresh()
    }

    func requestPermissions() {
        geofenceManager.requestRequiredPermissions()
    }

    func startMonitoring() {
        geofenceManager.startMonitoringHotelRegion()
    }

    func refresh() {
        geofenceManager.configure()
        updateFromManager()
    }

    private func bind() {
        geofenceManager.$locationAuthorizationStatus
            .sink { [weak self] _ in self?.updateFromManager() }
            .store(in: &cancellables)

        geofenceManager.$notificationAuthorizationStatus
            .sink { [weak self] _ in self?.updateFromManager() }
            .store(in: &cancellables)

        geofenceManager.$currentRegionState
            .sink { [weak self] _ in self?.updateFromManager() }
            .store(in: &cancellables)

        geofenceManager.$lastEvent
            .sink { [weak self] _ in self?.updateFromManager() }
            .store(in: &cancellables)

        geofenceManager.$isMonitoringHotelRegion
            .sink { [weak self] _ in self?.updateFromManager() }
            .store(in: &cancellables)

        geofenceManager.$statusMessage
            .sink { [weak self] _ in self?.updateFromManager() }
            .store(in: &cancellables)
    }

    private func updateFromManager() {
        statusMessage = geofenceManager.statusMessage
        lastEventText = geofenceManager.lastEvent.title

        switch geofenceManager.currentRegionState {
        case .inside:
            statusTitle = "Inside \(hotelName)"
            monitoringStateText = "Monitoring active"
        case .outside:
            statusTitle = "Outside hotel geofence"
            monitoringStateText = geofenceManager.isMonitoringHotelRegion ? "Monitoring active" : "Monitoring inactive"
        case .unknown:
            statusTitle = "Hotel Geofencing"
            monitoringStateText = geofenceManager.isMonitoringHotelRegion ? "Monitoring active" : "Monitoring inactive"
        @unknown default:
            statusTitle = "Hotel Geofencing"
            monitoringStateText = "Status unavailable"
        }

        locationStateText = locationDescription(for: geofenceManager.locationAuthorizationStatus)
        notificationStateText = notificationDescription(for: geofenceManager.notificationAuthorizationStatus)
        shouldShowPermissionButton = geofenceManager.needsAlwaysLocation || !geofenceManager.notificationsEnabled
        shouldShowStartButton = geofenceManager.locationAuthorizationStatus == .authorizedAlways && !geofenceManager.isMonitoringHotelRegion
    }

    private func locationDescription(for status: CLAuthorizationStatus) -> String {
        switch status {
        case .authorizedAlways:
            return "Always Location enabled"
        case .authorizedWhenInUse:
            return "When In Use enabled"
        case .notDetermined:
            return "Location permission not requested"
        case .denied:
            return "Location access denied"
        case .restricted:
            return "Location access restricted"
        @unknown default:
            return "Location permission unknown"
        }
    }

    private func notificationDescription(for status: UNAuthorizationStatus) -> String {
        switch status {
        case .authorized:
            return "Notifications enabled"
        case .provisional:
            return "Provisional notifications enabled"
        case .ephemeral:
            return "Temporary notifications enabled"
        case .denied:
            return "Notifications denied"
        case .notDetermined:
            return "Notifications not requested"
        @unknown default:
            return "Notification permission unknown"
        }
    }
}

