//
//  ExperienceDetailView.swift
//  HotelCompanion
//
//  File: Features/Bookings/Views/ExperienceDetailView.swift
//

import SwiftUI

@MainActor
struct ExperienceDetailView: View {
    @StateObject private var viewModel: ExperienceDetailViewModel

    init(experience: ExperienceBooking, viewModel: ExperienceDetailViewModel? = nil) {
        _viewModel = StateObject(
            wrappedValue: viewModel ?? ExperienceDetailViewModel(experience: experience)
        )
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

                        VStack(alignment: .leading, spacing: AppSpacing.small) {
                            Text("Guests")
                                .font(AppTypography.footnote)
                                .foregroundStyle(AppColors.secondaryText)

                            Stepper(value: $viewModel.guestCount, in: 1...8) {
                                Text("\(viewModel.guestCount) \(viewModel.guestCount == 1 ? "Guest" : "Guests")")
                                    .font(AppTypography.bodyEmphasized)
                                    .foregroundStyle(AppColors.primaryText)
                            }
                            .tint(AppColors.brandBrown)
                        }
                    }
                }

                if let successMessage = viewModel.bookingSuccessMessage {
                    SectionCard(title: "Booking Confirmed", subtitle: "Your reservation is ready") {
                        VStack(alignment: .leading, spacing: AppSpacing.medium) {
                            Text(successMessage)
                                .font(AppTypography.body)
                                .foregroundStyle(AppColors.secondaryText)
                                .fixedSize(horizontal: false, vertical: true)

                            if let createdBooking = viewModel.createdBooking {
                                NavigationLink {
                                    BookingConfirmationView(booking: createdBooking)
                                } label: {
                                    HStack(spacing: AppSpacing.small) {
                                        Text("Open QR Pass")
                                            .font(AppTypography.bodyEmphasized)
                                            .foregroundStyle(AppColors.brandBrown)

                                        Image(systemName: "qrcode")
                                            .foregroundStyle(AppColors.brandBrown)
                                            .accessibilityHidden(true)
                                    }
                                    .frame(minHeight: AppSpacing.minimumTouchTarget)
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel("Open QR pass for \(createdBooking.title)")
                            }
                        }
                    }
                }

                if let bookingErrorMessage = viewModel.bookingErrorMessage {
                    Text(bookingErrorMessage)
                        .font(AppTypography.footnote)
                        .foregroundStyle(.red.opacity(0.85))
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityLabel("Booking error: \(bookingErrorMessage)")
                }

                PrimaryButton(
                    title: viewModel.isCreatingBooking ? "Booking..." : "Book Experience",
                    systemImage: "checkmark.circle.fill"
                ) {
                    Task {
                        await viewModel.createBooking()
                    }
                }
                .disabled(viewModel.isCreatingBooking)
                .opacity(viewModel.isCreatingBooking ? 0.6 : 1)
                .accessibilityLabel("Book \(viewModel.experience.title)")

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
                id: "experience-river-cruise",
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
