//
//  AuthBackgroundView.swift
//  HotelCompanion
//
//  File: Core/Components/AuthBackgroundView.swift
//

import SwiftUI

struct AuthBackgroundView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    AppColors.backgroundCream,
                    AppColors.surfaceWarm,
                    AppColors.surfaceCream
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(AppColors.accentGoldSoft.opacity(0.35))
                .frame(width: 280, height: 280)
                .blur(radius: 10)
                .offset(x: 120, y: -220)

            Circle()
                .fill(AppColors.brandBrown.opacity(0.10))
                .frame(width: 260, height: 260)
                .blur(radius: 18)
                .offset(x: -140, y: 260)

            RoundedRectangle(cornerRadius: 48, style: .continuous)
                .fill(.white.opacity(0.18))
                .frame(width: 240, height: 240)
                .rotationEffect(.degrees(18))
                .offset(x: 150, y: 320)
                .blur(radius: 1)
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }
}

