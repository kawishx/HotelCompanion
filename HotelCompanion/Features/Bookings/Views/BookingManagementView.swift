//
//  BookingManagementView.swift
//  HotelCompanion
//
//  File: Features/Bookings/Views/BookingManagementView.swift
//

import SwiftUI

struct BookingManagementView: View {
    @StateObject private var viewModel: BookingManagementViewModel

    init(
        viewModel: BookingManagementViewModel
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.large) {
                SectionCard(
                    title: "Reservation Overview",
                    subtitle: "Manage upcoming stays and scheduled experiences"
                ) {
                    Text("Add booked experiences to your iPhone Calendar so your itinerary stays visible alongside your other plans.")
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }

                SectionCard(title: "Upcoming Bookings") {
                    VStack(alignment: .leading, spacing: AppSpacing.medium) {
                        ForEach(viewModel.upcomingBookings) { booking in
                            VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
                                Text(booking.title)
                                    .font(AppTypography.headline)
                                    .foregroundStyle(AppColors.primaryText)

                                Text(booking.detail)
                                    .font(AppTypography.body)
                                    .foregroundStyle(AppColors.secondaryText)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .accessibilityElement(children: .combine)
                        }
                    }
                }

                SectionCard(title: "Booked Experiences") {
                    VStack(alignment: .leading, spacing: AppSpacing.large) {
                        ForEach(viewModel.bookedExperiences) { experience in
                            VStack(alignment: .leading, spacing: AppSpacing.medium) {
                                NavigationLink {
                                    ExperienceDetailView(experience: experience)
                                } label: {
                                    VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
                                        Text(experience.title)
                                            .font(AppTypography.headline)
                                            .foregroundStyle(AppColors.primaryText)

                                        Text(experience.summary)
                                            .font(AppTypography.body)
                                            .foregroundStyle(AppColors.secondaryText)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel("Open details for \(experience.title)")

                                Button {
                                    Task {
                                        await viewModel.addExperienceToCalendar(experience)
                                    }
                                } label: {
                                    HStack(spacing: AppSpacing.small) {
                                        Image(systemName: "calendar.badge.plus")
                                            .font(.headline)

                                        Text(viewModel.savingExperienceID == experience.id ? "Adding..." : "Add to Calendar")
                                            .font(AppTypography.bodyEmphasized)
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
                                .disabled(viewModel.savingExperienceID == experience.id)
                                .opacity(viewModel.savingExperienceID == experience.id ? 0.6 : 1)
                                .accessibilityLabel("Add \(experience.title) to calendar")
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, AppSpacing.screenPadding)
            .padding(.vertical, AppSpacing.large)
        }
        .background(AppColors.backgroundCream.ignoresSafeArea())
        .navigationTitle("Manage Booking")
        .navigationBarTitleDisplayMode(.large)
        .alert(item: $viewModel.alertItem) { alert in
            Alert(
                title: Text(alert.title),
                message: Text(alert.message),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

