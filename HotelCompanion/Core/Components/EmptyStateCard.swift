//
//  EmptyStateCard.swift
//  HotelCompanion
//
//  File: Core/Components/EmptyStateCard.swift
//

import SwiftUI

struct EmptyStateCard: View {
    let title: String
    let subtitle: String?
    let message: String
    var systemImage: String = "tray.fill"
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        SectionCard(title: title, subtitle: subtitle) {
            VStack(alignment: .leading, spacing: AppSpacing.medium) {
                stateHeader

                Text(message)
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)

                if let actionTitle, let action {
                    PrimaryButton(title: actionTitle, systemImage: "sparkles") {
                        action()
                    }
                }
            }
        }
    }

    private var stateHeader: some View {
        HStack(spacing: AppSpacing.medium) {
            Image(systemName: systemImage)
                .font(.title3)
                .foregroundStyle(AppColors.brandBrown)
                .frame(width: 44, height: 44)
                .background(AppColors.accentGoldSoft.opacity(0.35))
                .clipShape(Circle())
                .accessibilityHidden(true)

            Text("Nothing to show just yet.")
                .font(AppTypography.bodyEmphasized)
                .foregroundStyle(AppColors.primaryText)

            Spacer()
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue(message)
    }
}

#Preview {
    EmptyStateCard(
        title: "No Active Stay",
        subtitle: "Your reservation will appear here when available",
        message: "Once a hotel stay is linked to your account, room details and dates will appear here."
    )
    .padding()
    .background(AppColors.backgroundCream)
}
