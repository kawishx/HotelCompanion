//
//  SectionCard.swift
//  HotelCompanion
//
//  File: Core/Components/SectionCard.swift
//

import SwiftUI

struct SectionCard<Content: View>: View {
    let title: String
    var subtitle: String?
    private let content: Content

    init(
        title: String,
        subtitle: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sectionSpacing) {
            SectionHeaderView(title: title, subtitle: subtitle)

            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppSpacing.cardPadding)
        .background(AppColors.surfaceCream)
        .overlay(
            RoundedRectangle(cornerRadius: AppSpacing.cardCornerRadius, style: .continuous)
                .stroke(AppColors.border, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cardCornerRadius, style: .continuous))
        .shadow(color: AppColors.shadow, radius: AppSpacing.standardShadowRadius, y: AppSpacing.standardShadowYOffset)
        .accessibilityElement(children: .contain)
    }
}

#Preview {
    SectionCard(title: "Arrival", subtitle: "Your next stay") {
        Text("Early check-in subject to availability.")
            .font(AppTypography.body)
            .foregroundStyle(AppColors.secondaryText)
    }
    .padding()
    .background(AppColors.backgroundCream)
}
