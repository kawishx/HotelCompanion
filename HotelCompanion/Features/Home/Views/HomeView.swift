//
//  HomeView.swift
//  HotelCompanion
//
//  File: Features/Home/Views/HomeView.swift
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel

    init(viewModel: HomeViewModel = HomeViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.large) {
                VStack(alignment: .leading, spacing: AppSpacing.medium) {
                    Text("Welcome back, \(viewModel.guestName)")
                        .font(AppTypography.display)
                        .foregroundStyle(AppColors.primaryText)
                        .accessibilityAddTraits(.isHeader)

                    Text(viewModel.welcomeMessage)
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.secondaryText)
                }

                SectionCard(
                    title: viewModel.resortName,
                    subtitle: "Luxury hospitality, simplified"
                ) {
                    VStack(alignment: .leading, spacing: AppSpacing.medium) {
                        Text("Start with your itinerary, then explore dining, local experiences, and personalized services as your stay grows.")
                            .font(AppTypography.body)
                            .foregroundStyle(AppColors.secondaryText)

                        PrimaryButton(title: "View My Stay", systemImage: "sparkles") { }
                            .accessibilityLabel("View my stay details")
                    }
                }

                SectionCard(
                    title: "Today at a glance",
                    subtitle: "A polished home base for future live trip data"
                ) {
                    VStack(alignment: .leading, spacing: AppSpacing.medium) {
                        ForEach(viewModel.highlights) { highlight in
                            HStack(alignment: .top, spacing: AppSpacing.medium) {
                                Image(systemName: highlight.systemImage)
                                    .font(.title3)
                                    .foregroundStyle(AppColors.accentGold)
                                    .frame(width: 28)
                                    .accessibilityHidden(true)

                                VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
                                    Text(highlight.title)
                                        .font(AppTypography.headline)
                                        .foregroundStyle(AppColors.primaryText)

                                    Text(highlight.subtitle)
                                        .font(AppTypography.body)
                                        .foregroundStyle(AppColors.secondaryText)
                                }
                            }
                            .padding(.vertical, AppSpacing.xSmall)
                        }
                    }
                }
            }
            .padding(.horizontal, AppSpacing.screenPadding)
            .padding(.vertical, AppSpacing.large)
        }
        .background(AppColors.backgroundCream.ignoresSafeArea())
        .navigationTitle("Home")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
}

