//
//  DiningViewModel.swift
//  HotelCompanion
//
//  File: Features/Dining/ViewModels/DiningViewModel.swift
//

import Combine
import Foundation

struct DiningVenue: Identifiable {
    let id = UUID()
    let name: String
    let serviceWindow: String
}

final class DiningViewModel: ObservableObject {
    @Published private(set) var venues: [DiningVenue] = [
        DiningVenue(name: "The Verandah", serviceWindow: "Breakfast from 6:30 AM to 10:30 AM"),
        DiningVenue(name: "Lagoon Grill", serviceWindow: "Seafood dinner from 6:00 PM to 10:30 PM"),
        DiningVenue(name: "In-Room Dining", serviceWindow: "Available 24 hours for premium comfort")
    ]
}
