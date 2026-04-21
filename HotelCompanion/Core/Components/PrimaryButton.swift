//
//  PrimaryButton.swift
//  HotelCompanion
//
//  File: Core/Components/PrimaryButton.swift
//

import SwiftUI

struct PrimaryButton: View {
    let title: String
    var systemImage: String?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.small) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.headline)
                }

                Text(title)
                    .font(AppTypography.button)
                    .multilineTextAlignment(.center)
            }
            .foregroundStyle(Color.white)
            .frame(maxWidth: .infinity)
            .frame(minHeight: AppSpacing.minimumTouchTarget)
            .padding(.horizontal, AppSpacing.large)
            .background(AppColors.brandBrown)
            .overlay(
                RoundedRectangle(cornerRadius: AppSpacing.buttonCornerRadius)
                    .stroke(AppColors.accentGoldSoft, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: AppSpacing.buttonCornerRadius, style: .continuous))
            .shadow(color: AppColors.shadow, radius: 12, y: 6)
        }
        .buttonStyle(.plain)
        .accessibilityHint("Activates \(title.lowercased())")
    }
}

#Preview {
    PrimaryButton(title: "View Offers", systemImage: "sparkles") { }
        .padding()
        .background(AppColors.backgroundCream)
}

