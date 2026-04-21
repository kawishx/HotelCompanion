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
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
                Text(title)
                    .font(AppTypography.sectionTitle)
                    .foregroundStyle(AppColors.primaryText)

                if let subtitle {
                    Text(subtitle)
                        .font(AppTypography.footnote)
                        .foregroundStyle(AppColors.secondaryText)
                }
            }

            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppSpacing.large)
        .background(AppColors.surfaceCream)
        .overlay(
            RoundedRectangle(cornerRadius: AppSpacing.cardCornerRadius, style: .continuous)
                .stroke(AppColors.border, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cardCornerRadius, style: .continuous))
        .shadow(color: AppColors.shadow, radius: 10, y: 4)
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
