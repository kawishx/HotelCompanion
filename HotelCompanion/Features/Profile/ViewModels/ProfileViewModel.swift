//
//  ProfileViewModel.swift
//  HotelCompanion
//
//  File: Features/Profile/ViewModels/ProfileViewModel.swift
//

import Combine
import Foundation

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published private(set) var profile: UserProfileRecord?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let userProfileService: UserProfileServicing

    init(userProfileService: UserProfileServicing? = nil) {
        self.userProfileService = userProfileService ?? UserProfileService.shared
    }

    var memberName: String {
        profile?.fullName ?? "Guest Profile"
    }

    var membershipTier: String {
        profile?.loyaltyTier ?? "No Membership Tier"
    }

    var preferenceSummary: String {
        guard let profile else {
            return "Sign in to sync your preferences across stays, services, and dining."
        }

        var preferences: [String] = []

        if profile.accessibilityPreferences.largeTextPreferred {
            preferences.append("large text")
        }

        if profile.accessibilityPreferences.reducedMotionPreferred {
            preferences.append("reduced motion")
        }

        if profile.notificationPreferences.diningUpdatesEnabled {
            preferences.append("dining updates")
        }

        if profile.notificationPreferences.conciergeUpdatesEnabled {
            preferences.append("concierge updates")
        }

        if preferences.isEmpty {
            return "No synced guest preferences have been recorded yet."
        }

        return preferences.joined(separator: ", ").capitalized
    }

    var emailText: String? {
        profile?.email
    }

    var phoneText: String? {
        profile?.phoneNumber
    }

    var preferredHotelText: String? {
        profile?.primaryHotelID?.replacingOccurrences(of: "-", with: " ").capitalized
    }

    var isEmpty: Bool {
        !isLoading && profile == nil && errorMessage == nil
    }

    func loadProfile() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            profile = try await userProfileService.fetchCurrentUserProfile()
        } catch {
            profile = nil
            errorMessage = error.localizedDescription
        }
    }
}
