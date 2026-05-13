//
//  LoadingStateView.swift
//  HotelCompanion
//
//  File: Core/Components/LoadingStateView.swift
//

import SwiftUI

struct LoadingStateView: View {
    let title: String
    let message: String
    var systemImage: String = "hourglass.circle.fill"

    var body: some View {
        HStack(alignment: .center, spacing: AppSpacing.medium) {
            ZStack {
                Circle()
                    .fill(AppColors.accentGoldSoft.opacity(0.35))
                    .frame(width: 42, height: 42)

                Image(systemName: systemImage)
                    .font(.headline)
                    .foregroundStyle(AppColors.brandBrown)
                    .accessibilityHidden(true)
            }

            VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
                Text(title)
                    .font(AppTypography.bodyEmphasized)
                    .foregroundStyle(AppColors.primaryText)

                Text(message)
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: AppSpacing.medium)

            ProgressView()
                .tint(AppColors.brandBrown)
                .accessibilityHidden(true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(minHeight: AppSpacing.minimumTouchTarget)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue(message)
    }
}

#Preview {
    LoadingStateView(
        title: "Loading Stay",
        message: "Preparing the latest details from the hotel."
    )
    .padding()
    .background(AppColors.backgroundCream)
}
