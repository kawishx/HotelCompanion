//
//  ProfileViewModel.swift
//  HotelCompanion
//
//  File: Features/Profile/ViewModels/ProfileViewModel.swift
//

import Combine
import Foundation

final class ProfileViewModel: ObservableObject {
    @Published private(set) var memberName = "Kawish Jayawardena"
    @Published private(set) var membershipTier = "Gold Member"
    @Published private(set) var preferenceSummary = "Ocean-view rooms, vegetarian dining, evening spa appointments"
}
