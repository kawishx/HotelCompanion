//
//  SectionHeaderView.swift
//  HotelCompanion
//
//  File: Core/Components/SectionHeaderView.swift
//

import SwiftUI

struct SectionHeaderView: View {
    let title: String
    var subtitle: String?

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
            Text(title)
                .font(AppTypography.sectionTitle)
                .foregroundStyle(AppColors.primaryText)

            if let subtitle, !subtitle.isEmpty {
                Text(subtitle)
                    .font(AppTypography.sectionSubtitle)
                    .foregroundStyle(AppColors.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    SectionHeaderView(title: "Arrival", subtitle: "Your next stay")
        .padding()
        .background(AppColors.backgroundCream)
}
