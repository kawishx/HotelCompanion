//
//  HomeViewModel.swift
//  HotelCompanion
//
//  File: Features/Home/ViewModels/HomeViewModel.swift
//

import Combine
import Foundation

struct HomeHighlight: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let systemImage: String
}

final class HomeViewModel: ObservableObject {
    @Published private(set) var guestName = "Kawish"
    @Published private(set) var resortName = "Cinnamon Companion"
    @Published private(set) var welcomeMessage = "Plan every part of your stay with one calm, beautifully guided experience."
    @Published private(set) var highlights: [HomeHighlight] = [
        HomeHighlight(title: "Suite Arrival", subtitle: "Check-in from 2:00 PM with concierge support.", systemImage: "bed.double.fill"),
        HomeHighlight(title: "Wellness Escape", subtitle: "Reserve spa rituals and sunrise yoga sessions.", systemImage: "leaf.fill"),
        HomeHighlight(title: "Island Curations", subtitle: "Discover signature experiences tailored to your itinerary.", systemImage: "sparkles")
    ]
}
