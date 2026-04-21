//
//  DiningView.swift
//  HotelCompanion
//
//  File: Features/Dining/Views/DiningView.swift
//

import SwiftUI

struct DiningView: View {
    @StateObject private var viewModel: DiningViewModel

    init(viewModel: DiningViewModel = DiningViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.large) {
                SectionCard(
                    title: "Dining",
                    subtitle: "Reserve tables, browse venues, and preview culinary experiences"
                ) {
                    Text("The dining tab is ready for later menu feeds, table availability, and personalized guest preferences.")
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.secondaryText)
                }

                ForEach(viewModel.venues) { venue in
                    SectionCard(title: venue.name) {
                        Text(venue.serviceWindow)
                            .font(AppTypography.bodyEmphasized)
                            .foregroundStyle(AppColors.primaryText)
                    }
                }

                PrimaryButton(title: "Reserve a Table", systemImage: "fork.knife.circle") { }
                    .accessibilityLabel("Reserve a dining table")
            }
            .padding(.horizontal, AppSpacing.screenPadding)
            .padding(.vertical, AppSpacing.large)
        }
        .background(AppColors.backgroundCream.ignoresSafeArea())
        .navigationTitle("Dining")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    NavigationStack {
        DiningView()
    }
}

