//
//  ExploreView.swift
//  HotelCompanion
//
//  File: Features/Explore/Views/ExploreView.swift
//

import SwiftUI

struct ExploreView: View {
    @StateObject private var viewModel: ExploreViewModel

    init(viewModel: ExploreViewModel = ExploreViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.large) {
                SectionCard(
                    title: "Explore Sri Lanka",
                    subtitle: "Experiences and destination discovery"
                ) {
                    Text("This module is ready for future API or Firebase-backed recommendations, featured experiences, and real-time availability.")
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.secondaryText)
                }

                ForEach(viewModel.destinations) { destination in
                    SectionCard(title: destination.name) {
                        VStack(alignment: .leading, spacing: AppSpacing.medium) {
                            Text(destination.description)
                                .font(AppTypography.body)
                                .foregroundStyle(AppColors.secondaryText)

                            PrimaryButton(title: "Explore More", systemImage: "map") { }
                                .accessibilityLabel("Explore more about \(destination.name)")
                        }
                    }
                }
            }
            .padding(.horizontal, AppSpacing.screenPadding)
            .padding(.vertical, AppSpacing.large)
        }
        .background(AppColors.backgroundCream.ignoresSafeArea())
        .navigationTitle("Explore")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    NavigationStack {
        ExploreView()
    }
}

