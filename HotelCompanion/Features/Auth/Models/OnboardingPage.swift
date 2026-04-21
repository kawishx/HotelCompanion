//
//  OnboardingPage.swift
//  HotelCompanion
//
//  File: Features/Auth/Models/OnboardingPage.swift
//

import Foundation

struct OnboardingPage: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let subtitle: String
    let detail: String
    let systemImage: String
}

