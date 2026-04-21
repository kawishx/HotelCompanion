//
//  MainTabView.swift
//  HotelCompanion
//
//  File: Features/Root/Views/MainTabView.swift
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var viewModel = RootViewModel()

    var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Label(AppTab.home.title, systemImage: AppTab.home.systemImage)
            }
            .tag(AppTab.home)

            NavigationStack {
                ExploreView()
            }
            .tabItem {
                Label(AppTab.explore.title, systemImage: AppTab.explore.systemImage)
            }
            .tag(AppTab.explore)

            NavigationStack {
                BookingsView()
            }
            .tabItem {
                Label(AppTab.bookings.title, systemImage: AppTab.bookings.systemImage)
            }
            .tag(AppTab.bookings)

            NavigationStack {
                DiningView()
            }
            .tabItem {
                Label(AppTab.dining.title, systemImage: AppTab.dining.systemImage)
            }
            .tag(AppTab.dining)

            NavigationStack {
                ProfileView()
            }
            .tabItem {
                Label(AppTab.profile.title, systemImage: AppTab.profile.systemImage)
            }
            .tag(AppTab.profile)
        }
        .tint(AppColors.accentGold)
        .accessibilityLabel("Main navigation tabs")
    }
}

#Preview {
    MainTabView()
}
