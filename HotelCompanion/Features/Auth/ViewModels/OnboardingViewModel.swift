//
//  OnboardingViewModel.swift
//  HotelCompanion
//
//  File: Features/Auth/ViewModels/OnboardingViewModel.swift
//

import Combine
import Foundation

final class OnboardingViewModel: ObservableObject {
    @Published var selectedIndex = 0

    let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Manage Your Stay",
            subtitle: "Everything important, beautifully organized",
            detail: "View reservation details, arrival planning, room requests, and personalized services in one calm experience.",
            systemImage: "bed.double.circle.fill"
        ),
        OnboardingPage(
            title: "Book Experiences",
            subtitle: "Moments beyond the room",
            detail: "Discover wellness rituals, island excursions, and curated local activities designed around your itinerary.",
            systemImage: "sparkles.rectangle.stack.fill"
        ),
        OnboardingPage(
            title: "Order Food and Explore Nearby",
            subtitle: "Dining and discovery without friction",
            detail: "Reserve tables, place in-room dining requests, and uncover nearby highlights from a single guest companion.",
            systemImage: "fork.knife.circle.fill"
        )
    ]

    var isLastPage: Bool {
        selectedIndex == pages.count - 1
    }

    func advance() {
        guard selectedIndex < pages.count - 1 else { return }
        selectedIndex += 1
    }
}

