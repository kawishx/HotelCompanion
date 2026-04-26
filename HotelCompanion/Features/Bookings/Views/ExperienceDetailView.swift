//
//  ExperienceDetailView.swift
//  HotelCompanion
//
//  File: Features/Bookings/Views/ExperienceDetailView.swift
//

import SwiftUI

struct ExperienceDetailView: View {
    @StateObject private var viewModel: ExperienceDetailViewModel

    init(
        experience: ExperienceBooking,
        viewModelFactory: @escaping (ExperienceBooking) -> ExperienceDetailViewModel = { ExperienceDetailViewModel(experience: $0) }
    ) {
        _viewModel = StateObject(wrappedValue: viewModelFactory(experience))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.large) {
                SectionCard(
                    title: viewModel.experience.title,
                    subtitle: viewModel.experience.category
                ) {
                    VStack(alignment: .leading, spacing: AppSpacing.medium) {
                        Text(viewModel.experience.summary)
                            .font(AppTypography.body)
                            .foregroundStyle(AppColors.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)

                        detailRow(title: "Location", value: viewModel.experience.location)
                        detailRow(title: "Starts", value: viewModel.experience.startDate.formatted(date: .abbreviated, time: .shortened))
                        detailRow(title: "Ends", value: viewModel.experience.endDate.formatted(date: .abbreviated, time: .shortened))
                    }
                }

                PrimaryButton(
                    title: viewModel.isSavingToCalendar ? "Adding to Calendar..." : "Add to Calendar",
                    systemImage: "calendar.badge.plus"
                ) {
                    Task {
                        await viewModel.addToCalendar()
                    }
                }
                .disabled(viewModel.isSavingToCalendar)
                .opacity(viewModel.isSavingToCalendar ? 0.6 : 1)
                .accessibilityLabel("Add booked experience to calendar")
            }
            .padding(.horizontal, AppSpacing.screenPadding)
            .padding(.vertical, AppSpacing.large)
        }
        .background(AppColors.backgroundCream.ignoresSafeArea())
        .navigationTitle("Experience")
        .navigationBarTitleDisplayMode(.inline)
        .alert(item: $viewModel.alertItem) { alert in
            Alert(
                title: Text(alert.title),
                message: Text(alert.message),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    private func detailRow(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
            Text(title)
                .font(AppTypography.footnote)
                .foregroundStyle(AppColors.secondaryText)

            Text(value)
                .font(AppTypography.bodyEmphasized)
                .foregroundStyle(AppColors.primaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    NavigationStack {
        ExperienceDetailView(
            experience: ExperienceBooking(
                title: "Sunset River Cruise",
                category: "Signature Experience",
                summary: "A curated evening cruise with refreshments and local storytelling.",
                location: "Bentota Jetty",
                startDate: Date(),
                endDate: Date().addingTimeInterval(7200)
            )
        )
    }
}

