//
//  SavedAttractionsView.swift
//  HotelCompanion
//
//  File: Features/Favorites/Views/SavedAttractionsView.swift
//

import SwiftUI

@MainActor
struct SavedAttractionsView: View {
    @StateObject private var viewModel: SavedAttractionsViewModel

    init(viewModel: SavedAttractionsViewModel? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel ?? SavedAttractionsViewModel())
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.large) {
                SectionCard(
                    title: "Saved Attractions",
                    subtitle: "Your favorite nearby discoveries"
                ) {
                    content
                }
            }
            .padding(.horizontal, AppSpacing.screenPadding)
            .padding(.vertical, AppSpacing.large)
        }
        .background(AppColors.backgroundCream.ignoresSafeArea())
        .navigationTitle("Favorites")
        .navigationBarTitleDisplayMode(.large)
        .task {
            await viewModel.loadSavedAttractions()
        }
        .refreshable {
            await viewModel.loadSavedAttractions()
        }
    }
}

private extension SavedAttractionsView {
    @ViewBuilder
    var content: some View {
        if viewModel.isLoading {
            HStack(spacing: AppSpacing.medium) {
                ProgressView()
                    .tint(AppColors.brandBrown)

                Text("Loading your saved places.")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.secondaryText)
            }
            .frame(minHeight: AppSpacing.minimumTouchTarget)
        } else if let errorMessage = viewModel.errorMessage {
            Text(errorMessage)
                .font(AppTypography.body)
                .foregroundStyle(.red.opacity(0.85))
                .fixedSize(horizontal: false, vertical: true)
        } else if viewModel.isEmpty {
            Text("Save attractions from Explore to keep your favorite nearby places handy during the stay.")
                .font(AppTypography.body)
                .foregroundStyle(AppColors.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        } else {
            VStack(alignment: .leading, spacing: AppSpacing.large) {
                ForEach(viewModel.savedAttractions) { saved in
                    VStack(alignment: .leading, spacing: AppSpacing.small) {
                        Text(saved.attraction.title)
                            .font(AppTypography.headline)
                            .foregroundStyle(AppColors.primaryText)

                        Text(saved.attraction.category.rawValue.capitalized)
                            .font(AppTypography.footnote)
                            .foregroundStyle(AppColors.brandBrown)

                        Text(viewModel.distanceText(for: saved))
                            .font(AppTypography.body)
                            .foregroundStyle(AppColors.secondaryText)

                        Button(role: .destructive) {
                            Task {
                                await viewModel.remove(saved)
                            }
                        } label: {
                            Text("Remove Favorite")
                                .font(AppTypography.bodyEmphasized)
                        }
                        .buttonStyle(.plain)
                        .frame(minHeight: AppSpacing.minimumTouchTarget)
                    }
                    .accessibilityElement(children: .combine)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        SavedAttractionsView()
    }
}
