//
//  CalendarAlertItem.swift
//  HotelCompanion
//
//  File: Core/Calendar/CalendarAlertItem.swift
//

import Foundation

struct CalendarAlertItem: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}

