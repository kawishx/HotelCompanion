//
//  AttractionDetailView.swift
//  HotelCompanion
//
//  File: Features/Explore/Views/AttractionDetailView.swift
//

import SwiftUI

struct AttractionDetailView: View {
    let attraction: Attraction
    let distanceText: String
    let isFavorite: Bool
    let onNavigate: () -> Void
    let onToggleFavorite: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.xLarge) {
                AttractionHeroImage(attraction: attraction)

                VStack(alignment: .leading, spacing: AppSpacing.medium) {
                    Text(attraction.title)
                        .font(AppTypography.display)
                        .foregroundStyle(AppColors.primaryText)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityAddTraits(.isHeader)

                    ViewThatFits(in: .vertical) {
                        HStack(spacing: AppSpacing.small) {
                            Label(attraction.category.rawValue, systemImage: attraction.category.symbolName)
                                .font(AppTypography.bodyEmphasized)
                                .foregroundStyle(AppColors.brandBrown)

                            Text("•")
                                .foregroundStyle(AppColors.secondaryText)
                                .accessibilityHidden(true)

                            Text(distanceText)
                                .font(AppTypography.body)
                                .foregroundStyle(AppColors.secondaryText)
                        }

                        VStack(alignment: .leading, spacing: AppSpacing.small) {
                            Label(attraction.category.rawValue, systemImage: attraction.category.symbolName)
                                .font(AppTypography.bodyEmphasized)
                                .foregroundStyle(AppColors.brandBrown)

                            Text(distanceText)
                                .font(AppTypography.body)
                                .foregroundStyle(AppColors.secondaryText)
                        }
                    }
                    .fixedSize(horizontal: false, vertical: true)

                    Text(attraction.shortDescription)
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }

                VStack(spacing: AppSpacing.medium) {
                    PrimaryButton(title: "Navigate", systemImage: "arrow.triangle.turn.up.right.diamond.fill") {
                        onNavigate()
                    }
                    .accessibilityLabel("Navigate to \(attraction.title)")

                    Button(action: onToggleFavorite) {
                        HStack(spacing: AppSpacing.small) {
                            Image(systemName: isFavorite ? "heart.fill" : "heart")
                                .font(.headline)

                            Text(isFavorite ? "Saved to Favorites" : "Save Favorite")
                                .font(AppTypography.button)
                        }
                        .foregroundStyle(AppColors.brandBrown)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: AppSpacing.minimumTouchTarget)
                        .background(AppColors.surfaceCream)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppSpacing.buttonCornerRadius, style: .continuous)
                                .stroke(AppColors.border, lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.buttonCornerRadius, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(isFavorite ? "Remove from favorites" : "Save as favorite")
                }
            }
            .padding(AppSpacing.screenPadding)
        }
        .background(AppColors.backgroundCream.ignoresSafeArea())
    }
}

private struct AttractionHeroImage: View {
    let attraction: Attraction

    var body: some View {
        AsyncImage(url: attraction.imageURL) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
            case .failure, .empty:
                ZStack {
                    LinearGradient(
                        colors: [AppColors.brandBrownDeep, AppColors.brandBrown, AppColors.accentGold],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )

                    Image(systemName: attraction.category.symbolName)
                        .font(.system(size: 54, weight: .medium))
                        .foregroundStyle(AppColors.accentGoldSoft)
                }
            @unknown default:
                Color.clear
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 260)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .accessibilityLabel("Image preview for \(attraction.title)")
    }
}

#Preview {
    AttractionDetailView(
        attraction: Attraction(
            title: "Galle Face Green",
            category: .beaches,
            latitude: 6.9272,
            longitude: 79.8447,
            shortDescription: "A breezy oceanfront promenade ideal for sunset walks and relaxing views.",
            imageURLString: "https://picsum.photos/id/1011/1200/800"
        ),
        distanceText: "2.3 km from hotel",
        isFavorite: false,
        onNavigate: { },
        onToggleFavorite: { }
    )
}
