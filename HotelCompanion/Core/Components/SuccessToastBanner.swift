//
//  SuccessToastBanner.swift
//  HotelCompanion
//
//  File: Core/Components/SuccessToastBanner.swift
//

import SwiftUI

struct SuccessToastBanner: View {
    let message: String
    var title: String = "Success"

    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.medium) {
            Image(systemName: "checkmark.circle.fill")
                .font(.headline)
                .foregroundStyle(AppColors.successGreen)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
                Text(title)
                    .font(AppTypography.footnote)
                    .foregroundStyle(AppColors.successGreen)

                Text(message)
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.primaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: AppSpacing.small)
        }
        .padding(AppSpacing.medium)
        .background(AppColors.successSurface)
        .overlay(
            RoundedRectangle(cornerRadius: AppSpacing.buttonCornerRadius, style: .continuous)
                .stroke(AppColors.successGreen.opacity(0.25), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.buttonCornerRadius, style: .continuous))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue(message)
    }
}

#Preview {
    SuccessToastBanner(message: "Your booking was rescheduled.")
        .padding()
        .background(AppColors.backgroundCream)
}
