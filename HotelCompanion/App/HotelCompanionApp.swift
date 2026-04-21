//
//  HotelCompanionApp.swift
//  HotelCompanion
//
//  File: App/HotelCompanionApp.swift
//

import SwiftUI
import UIKit

@main
struct HotelCompanionApp: App {
    init() {
        configureAppearance()
    }

    var body: some Scene {
        WindowGroup {
            RootTabView()
        }
    }

    private func configureAppearance() {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor(AppColors.surfaceCream)

        let normalTabColor = UIColor(AppColors.secondaryText)
        let selectedTabColor = UIColor(AppColors.accentGold)

        tabBarAppearance.stackedLayoutAppearance.normal.iconColor = normalTabColor
        tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: normalTabColor]
        tabBarAppearance.stackedLayoutAppearance.selected.iconColor = selectedTabColor
        tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: selectedTabColor]

        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance

        let navigationAppearance = UINavigationBarAppearance()
        navigationAppearance.configureWithOpaqueBackground()
        navigationAppearance.backgroundColor = UIColor(AppColors.backgroundCream)
        navigationAppearance.titleTextAttributes = [.foregroundColor: UIColor(AppColors.primaryText)]
        navigationAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor(AppColors.primaryText)]

        UINavigationBar.appearance().standardAppearance = navigationAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationAppearance
        UINavigationBar.appearance().compactAppearance = navigationAppearance
    }
}

