//
//  CategoryFilterChip.swift
//  HotelCompanion
//
//  File: Features/Explore/Views/CategoryFilterChip.swift
//

import SwiftUI

struct CategoryFilterChip: View {
    let title: String
    let systemImage: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.small) {
                Image(systemName: systemImage)
                    .font(.subheadline)

                Text(title)
                    .font(AppTypography.bodyEmphasized)
                    .lineLimit(1)
            }
            .foregroundStyle(isSelected ? Color.white : AppColors.brandBrown)
            .padding(.horizontal, AppSpacing.large)
            .frame(minHeight: AppSpacing.minimumTouchTarget)
            .background(isSelected ? AppColors.brandBrown : AppColors.surfaceCream)
            .overlay(
                Capsule()
                    .stroke(isSelected ? AppColors.accentGoldSoft : AppColors.border, lineWidth: 1)
            )
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .accessibilityHint(isSelected ? "Currently selected category filter" : "Filters nearby attractions by \(title.lowercased())")
    }
}

#Preview {
    CategoryFilterChip(title: "Beaches", systemImage: "sun.max.fill", isSelected: true) { }
        .padding()
        .background(AppColors.backgroundCream)
}

