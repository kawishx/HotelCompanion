//
//  BookingManagementView.swift
//  HotelCompanion
//
//  File: Features/Bookings/Views/BookingManagementView.swift
//

import SwiftUI

@MainActor
struct BookingManagementView: View {
    @StateObject private var viewModel = BookingViewModel()
    @State private var reschedulingBooking: BookingSummary?
    @State private var proposedStartDate = Date()
    @State private var proposedEndDate = Date().addingTimeInterval(3600)

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.large) {
                SectionCard(
                    title: "Reservation Overview",
                    subtitle: "Manage upcoming stays and scheduled experiences"
                ) {
                    VStack(alignment: .leading, spacing: AppSpacing.medium) {
                        Text("Use Firestore-backed booking records to manage reservations, QR access, rescheduling, and calendar sync in one place.")
                            .font(AppTypography.body)
                            .foregroundStyle(AppColors.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)

                        if let successMessage = viewModel.successMessage {
                            Text(successMessage)
                                .font(AppTypography.footnote)
                                .foregroundStyle(AppColors.brandBrown)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                                .font(AppTypography.footnote)
                                .foregroundStyle(.red.opacity(0.85))
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        NavigationLink {
                            DigitalCheckInView()
                        } label: {
                            HStack(spacing: AppSpacing.small) {
                                Text("Open Digital Check-In")
                                    .font(AppTypography.bodyEmphasized)
                                    .foregroundStyle(AppColors.brandBrown)

                                Image(systemName: "chevron.right.circle.fill")
                                    .foregroundStyle(AppColors.brandBrown)
                                    .accessibilityHidden(true)
                            }
                            .frame(minHeight: AppSpacing.minimumTouchTarget)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Open digital check-in")
                        .accessibilityHint("Upload your ID or passport for arrival")
                    }
                }

                currentBookingsSection
                qrValidationSection
                availableExperiencesSection
            }
            .padding(.horizontal, AppSpacing.screenPadding)
            .padding(.vertical, AppSpacing.large)
        }
        .background(AppColors.backgroundCream.ignoresSafeArea())
        .navigationTitle("Manage Booking")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            Task {
                await viewModel.loadBookings()
            }
        }
        .refreshable {
            await viewModel.loadBookings()
        }
        .alert(item: $viewModel.alertItem) { alert in
            Alert(
                title: Text(alert.title),
                message: Text(alert.message),
                dismissButton: .default(Text("OK"))
            )
        }
        .sheet(item: $reschedulingBooking) { booking in
            NavigationStack {
                rescheduleSheet(for: booking)
            }
            .presentationDetents([.medium, .large])
        }
    }
}

private extension BookingManagementView {
    var currentBookingsSection: some View {
        SectionCard(title: "Current Bookings", subtitle: "Your Firestore-backed reservation records") {
            VStack(alignment: .leading, spacing: AppSpacing.large) {
                if viewModel.isLoading {
                    HStack(spacing: AppSpacing.medium) {
                        ProgressView()
                            .tint(AppColors.brandBrown)

                        Text("Loading current bookings.")
                            .font(AppTypography.body)
                            .foregroundStyle(AppColors.secondaryText)
                    }
                    .frame(minHeight: AppSpacing.minimumTouchTarget)
                } else if viewModel.upcomingBookings.isEmpty {
                    Text("No current bookings are available yet. Reserve an experience to see it here.")
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    ForEach(viewModel.upcomingBookings) { booking in
                        VStack(alignment: .leading, spacing: AppSpacing.medium) {
                            Text(booking.title)
                                .font(AppTypography.headline)
                                .foregroundStyle(AppColors.primaryText)

                            Text(booking.detail)
                                .font(AppTypography.body)
                                .foregroundStyle(AppColors.secondaryText)
                                .fixedSize(horizontal: false, vertical: true)

                            Text("Status: \(booking.status.rawValue.replacingOccurrences(of: "([a-z])([A-Z])", with: "$1 $2", options: .regularExpression).capitalized)")
                                .font(AppTypography.footnote)
                                .foregroundStyle(AppColors.secondaryText)
                                .accessibilityLabel("Booking status")
                                .accessibilityValue(booking.status.rawValue.replacingOccurrences(of: "([a-z])([A-Z])", with: "$1 $2", options: .regularExpression).capitalized)

                            NavigationLink {
                                QRPassView(booking: booking)
                            } label: {
                                actionRowLabel(title: "Open QR Pass", systemImage: "qrcode")
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Open QR pass for \(booking.title)")

                            Button {
                                Task {
                                    await viewModel.addBookingToCalendar(booking)
                                }
                            } label: {
                                actionRowLabel(
                                    title: viewModel.activeBookingID == booking.id ? "Adding to Calendar..." : "Add to Calendar",
                                    systemImage: "calendar.badge.plus"
                                )
                            }
                            .buttonStyle(.plain)
                            .disabled(viewModel.activeBookingID == booking.id)
                            .opacity(viewModel.activeBookingID == booking.id ? 0.6 : 1)

                            Button {
                                proposedStartDate = booking.startDate
                                proposedEndDate = booking.endDate ?? booking.startDate.addingTimeInterval(3600)
                                reschedulingBooking = booking
                            } label: {
                                actionRowLabel(title: "Reschedule Booking", systemImage: "calendar")
                            }
                            .buttonStyle(.plain)

                            if booking.status != .cancelled {
                                Button(role: .destructive) {
                                    Task {
                                        await viewModel.cancelBooking(booking)
                                    }
                                } label: {
                                    actionRowLabel(title: "Cancel Booking", systemImage: "xmark.circle")
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.bottom, AppSpacing.small)
                        .accessibilityElement(children: .contain)
                        .accessibilityLabel("\(booking.title), \(booking.detail)")
                    }
                }
            }
        }
    }

    var qrValidationSection: some View {
        SectionCard(title: "QR Validation") {
            NavigationLink {
                QRScannerView(bookings: viewModel.upcomingBookings)
            } label: {
                HStack(spacing: AppSpacing.medium) {
                    Image(systemName: "qrcode.viewfinder")
                        .font(.headline)
                        .foregroundStyle(AppColors.brandBrown)
                        .frame(width: 32, height: 32)
                        .background(AppColors.accentGoldSoft.opacity(0.35))
                        .clipShape(Circle())
                        .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
                        Text("Scan Booking QR Code")
                            .font(AppTypography.headline)
                            .foregroundStyle(AppColors.primaryText)

                        Text("Validate a guest booking code with the device camera.")
                            .font(AppTypography.body)
                            .foregroundStyle(AppColors.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(minHeight: AppSpacing.minimumTouchTarget)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Scan booking QR code")
        }
    }

    var availableExperiencesSection: some View {
        SectionCard(title: "Available Experiences", subtitle: "Book and sync curated hotel activities") {
            VStack(alignment: .leading, spacing: AppSpacing.large) {
                ForEach(viewModel.availableExperiences) { experience in
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
                }
            }
        }
    }

    func rescheduleSheet(for booking: BookingSummary) -> some View {
        Form {
            Section("Booking") {
                Text(booking.title)
                Text(booking.detail)
                    .foregroundStyle(AppColors.secondaryText)
            }

            Section("New Schedule") {
                DatePicker("Start", selection: $proposedStartDate)
                DatePicker("End", selection: $proposedEndDate)
            }
        }
        .navigationTitle("Reschedule")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close") {
                    reschedulingBooking = nil
                }
            }

            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    let bookingToUpdate = booking
                    reschedulingBooking = nil

                    Task {
                        await viewModel.rescheduleBooking(
                            bookingToUpdate,
                            startDate: proposedStartDate,
                            endDate: proposedEndDate
                        )
                    }
                }
            }
        }
    }

    func actionRowLabel(title: String, systemImage: String) -> some View {
        HStack(spacing: AppSpacing.small) {
            Image(systemName: systemImage)
                .font(.headline)

            Text(title)
                .font(AppTypography.bodyEmphasized)
        }
        .foregroundStyle(AppColors.brandBrown)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(minHeight: AppSpacing.minimumTouchTarget)
        .padding(.horizontal, AppSpacing.medium)
        .background(AppColors.surfaceCream)
        .overlay(
            RoundedRectangle(cornerRadius: AppSpacing.buttonCornerRadius, style: .continuous)
                .stroke(AppColors.border, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.buttonCornerRadius, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}
