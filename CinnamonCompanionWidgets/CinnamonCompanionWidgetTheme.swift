//
//  CinnamonCompanionWidgetTheme.swift
//  CinnamonCompanionWidgets
//
//  File: CinnamonCompanionWidgets/CinnamonCompanionWidgetTheme.swift
//

import SwiftUI

enum CinnamonWidgetTheme {
    static let backgroundTop = Color(red: 0.98, green: 0.96, blue: 0.92)
    static let backgroundBottom = Color(red: 0.94, green: 0.90, blue: 0.84)
    static let brandBrown = Color(red: 0.24, green: 0.16, blue: 0.10)
    static let warmBrown = Color(red: 0.43, green: 0.30, blue: 0.20)
    static let accentGold = Color(red: 0.78, green: 0.64, blue: 0.31)
    static let accentGoldSoft = Color(red: 0.89, green: 0.82, blue: 0.65)
    static let surface = Color.white.opacity(0.72)
    static let secondaryText = Color(red: 0.45, green: 0.36, blue: 0.27)
    static let border = Color(red: 0.84, green: 0.77, blue: 0.67)
}

struct CinnamonWidgetBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    CinnamonWidgetTheme.backgroundTop,
                    CinnamonWidgetTheme.backgroundBottom
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(CinnamonWidgetTheme.accentGoldSoft.opacity(0.35))
                .frame(width: 160, height: 160)
                .offset(x: 80, y: -80)

            Circle()
                .fill(CinnamonWidgetTheme.warmBrown.opacity(0.08))
                .frame(width: 180, height: 180)
                .offset(x: -90, y: 100)
        }
    }
}

struct CinnamonWidgetTag: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.caption2.weight(.semibold))
            .foregroundStyle(CinnamonWidgetTheme.warmBrown)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(CinnamonWidgetTheme.accentGoldSoft.opacity(0.4))
            .clipShape(Capsule())
    }
}

