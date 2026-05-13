//
//  ErrorStateCard.swift
//  HotelCompanion
//
//  File: Core/Components/ErrorStateCard.swift
//

import SwiftUI

struct ErrorStateCard: View {
    let title: String
    let subtitle: String?
    let message: String
    var retryTitle: String = "Retry"
    let retryAction: () -> Void

    var body: some View {
        SectionCard(title: title, subtitle: subtitle) {
            VStack(alignment: .leading, spacing: AppSpacing.medium) {
                HStack(spacing: AppSpacing.medium) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.title3)
                        .foregroundStyle(AppColors.errorRed)
                        .frame(width: 44, height: 44)
                        .background(AppColors.errorSurface)
                        .clipShape(Circle())
                        .accessibilityHidden(true)

                    Text("Something needs attention.")
                        .font(AppTypography.bodyEmphasized)
                        .foregroundStyle(AppColors.primaryText)

                    Spacer()
                }

                Text(message)
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)

                RetryActionButton(title: retryTitle, action: retryAction)
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel(title)
            .accessibilityValue(message)
        }
    }
}

#Preview {
    ErrorStateCard(
        title: "Unable to Load Stay",
        subtitle: "Please try again in a moment",
        message: "The hotel data could not be loaded.",
        retryAction: {}
    )
    .padding()
    .background(AppColors.backgroundCream)
}
