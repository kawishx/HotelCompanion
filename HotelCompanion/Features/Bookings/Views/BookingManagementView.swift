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
                    VStack(alignment: .leading, spacing: AppSpacing.medium) {
                        Text("Add booked experiences to your iPhone Calendar so your itinerary stays visible alongside your other plans.")
                            .font(AppTypography.body)
                            .foregroundStyle(AppColors.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)

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

                                NavigationLink {
                                    QRPassView(booking: booking)
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
                                .accessibilityLabel("Open QR pass for \(booking.title)")
                            }
                        }
                    }
                }

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
