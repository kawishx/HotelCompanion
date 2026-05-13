//
//  RetryActionButton.swift
//  HotelCompanion
//
//  File: Core/Components/RetryActionButton.swift
//

import SwiftUI

struct RetryActionButton: View {
    let title: String
    let action: () -> Void

    init(title: String = "Retry", action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.small) {
                Image(systemName: "arrow.clockwise")
                    .font(.headline)
                    .accessibilityHidden(true)

                Text(title)
                    .font(AppTypography.bodyEmphasized)
                    .multilineTextAlignment(.center)
            }
            .foregroundStyle(AppColors.brandBrown)
            .frame(maxWidth: .infinity)
            .frame(minHeight: AppSpacing.minimumTouchTarget)
            .padding(.horizontal, AppSpacing.large)
            .background(AppColors.surfaceCream)
            .overlay(
                RoundedRectangle(cornerRadius: AppSpacing.buttonCornerRadius, style: .continuous)
                    .stroke(AppColors.border, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: AppSpacing.buttonCornerRadius, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .accessibilityHint("Attempts this action again")
    }
}

#Preview {
    RetryActionButton { }
        .padding()
        .background(AppColors.backgroundCream)
}
