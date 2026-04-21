//
//  SplashViewModel.swift
//  HotelCompanion
//
//  File: Features/Auth/ViewModels/SplashViewModel.swift
//

import Combine
import Foundation

final class SplashViewModel: ObservableObject {
    @Published private(set) var brandTitle = "Cinnamon Companion"
    @Published private(set) var brandSubtitle = "A refined way to stay, dine, and explore."
    @Published private(set) var tagline = "Curated hospitality at your fingertips."
}

