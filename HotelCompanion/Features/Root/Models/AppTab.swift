//
//  AppTab.swift
//  HotelCompanion
//
//  File: Features/Root/Models/AppTab.swift
//

import Foundation

enum AppTab: Hashable {
    case home
    case explore
    case bookings
    case dining
    case profile

    var title: String {
        switch self {
        case .home:
            return "Home"
        case .explore:
            return "Explore"
        case .bookings:
            return "Bookings"
        case .dining:
            return "Dining"
        case .profile:
            return "Profile"
        }
    }

    var systemImage: String {
        switch self {
        case .home:
            return "house"
        case .explore:
            return "safari"
        case .bookings:
            return "calendar"
        case .dining:
            return "fork.knife"
        case .profile:
            return "person.crop.circle"
        }
    }
}

