//
//  ExploreViewModel.swift
//  HotelCompanion
//
//  File: Features/Explore/ViewModels/ExploreViewModel.swift
//

import Combine
import Foundation

struct ExploreDestination: Identifiable {
    let id = UUID()
    let name: String
    let description: String
}

final class ExploreViewModel: ObservableObject {
    @Published private(set) var destinations: [ExploreDestination] = [
        ExploreDestination(name: "Tea Trails", description: "Private highland journeys with panoramic views and curated tastings."),
        ExploreDestination(name: "Ocean Excursions", description: "Sunset cruises, snorkeling trips, and family-friendly adventures."),
        ExploreDestination(name: "Culture & Heritage", description: "Temple visits, artisan workshops, and local storytelling experiences.")
    ]
}
