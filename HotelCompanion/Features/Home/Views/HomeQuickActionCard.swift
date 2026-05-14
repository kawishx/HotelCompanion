//
//  HomeQuickActionCard.swift
//  HotelCompanion
//
//  File: Features/Home/Views/HomeQuickActionCard.swift
//

import SwiftUI

struct HomeQuickActionCard: View {
    let action: HomeQuickAction
    let tapAction: () -> Void

    var body: some View {
        Button(action: tapAction) {
            VStack(alignment: .leading, spacing: AppSpacing.medium) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(AppColors.accentGoldSoft.opacity(0.28))
                        .frame(width: 48, height: 48)

                    Image(systemName: action.systemImage)
                        .font(.title3)
                        .foregroundStyle(AppColors.brandBrown)
                }
                .accessibilityHidden(true)

                Text(action.title)
                    .font(AppTypography.bodyEmphasized)
                    .foregroundStyle(AppColors.primaryText)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, minHeight: 128, alignment: .topLeading)
            .padding(AppSpacing.large)
            .background(AppColors.surfaceCream)
            .overlay(
                RoundedRectangle(cornerRadius: AppSpacing.cardCornerRadius, style: .continuous)
                    .stroke(AppColors.border, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cardCornerRadius, style: .continuous))
            .shadow(color: AppColors.shadow, radius: 8, y: 4)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(action.accessibilityLabel)
        .accessibilityHint("Opens \(action.title.lowercased())")
    }
}

#Preview {
    HomeQuickActionCard(
        action: HomeQuickAction(
            title: "Request Service",
            systemImage: "bell.badge.fill",
            accessibilityLabel: "Request guest service",
            route: .requestService
        ),
        tapAction: { }
    )
    .padding()
    .background(AppColors.backgroundCream)
}
