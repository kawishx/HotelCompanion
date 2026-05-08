//
//  BookingsView.swift
//  HotelCompanion
//
//  File: Features/Bookings/Views/BookingsView.swift
//

import SwiftUI

@MainActor
struct BookingsView: View {
    @StateObject private var viewModel: BookingViewModel

    init(viewModel: BookingViewModel? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel ?? BookingViewModel())
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.large) {
                SectionCard(
                    title: "Bookings",
                    subtitle: "Reservations, room upgrades, and transport in one place"
                ) {
                    Text("Your experience and stay bookings now flow through a Firestore-ready reservation layer.")
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.secondaryText)
                }

                if viewModel.isLoading {
                    SectionCard(title: "Loading Bookings", subtitle: "Syncing your reservation history") {
                        HStack(spacing: AppSpacing.medium) {
                            ProgressView()
                                .tint(AppColors.brandBrown)

                            Text("Your bookings are being prepared.")
                                .font(AppTypography.body)
                                .foregroundStyle(AppColors.secondaryText)
                        }
                        .frame(minHeight: AppSpacing.minimumTouchTarget)
                    }
                } else if let errorMessage = viewModel.errorMessage {
                    SectionCard(title: "Unable to Load Bookings", subtitle: "Please try again in a moment") {
                        VStack(alignment: .leading, spacing: AppSpacing.medium) {
                            Text(errorMessage)
                                .font(AppTypography.body)
                                .foregroundStyle(AppColors.secondaryText)
                                .fixedSize(horizontal: false, vertical: true)

                            PrimaryButton(title: "Retry", systemImage: "arrow.clockwise") {
                                Task {
                                    await viewModel.loadBookings()
                                }
                            }
                        }
                    }
                } else if viewModel.isEmpty {
                    SectionCard(title: "No Current Bookings", subtitle: "Your confirmed reservations will appear here") {
                        Text("Once you reserve an experience or a stay, booking details and QR access will be shown in this space.")
                            .font(AppTypography.body)
                            .foregroundStyle(AppColors.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                } else {
                    ForEach(viewModel.upcomingBookings) { booking in
                        SectionCard(title: booking.title, subtitle: booking.propertyName) {
                            VStack(alignment: .leading, spacing: AppSpacing.medium) {
                                Text(booking.detail)
                                    .font(AppTypography.body)
                                    .foregroundStyle(AppColors.secondaryText)

                                NavigationLink {
                                    BookingConfirmationView(booking: booking)
                                } label: {
                                    HStack(spacing: AppSpacing.small) {
                                        Text("View Booking QR Pass")
                                            .font(AppTypography.bodyEmphasized)
                                            .foregroundStyle(AppColors.brandBrown)

                                        Image(systemName: "qrcode")
                                            .foregroundStyle(AppColors.brandBrown)
                                            .accessibilityHidden(true)
                                    }
                                    .frame(minHeight: AppSpacing.minimumTouchTarget)
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel("View QR pass for \(booking.title)")
                            }
                        }
                    }
                }

                NavigationLink {
                    BookingManagementView()
                } label: {
                    Text("Manage Reservation")
                        .font(AppTypography.button)
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: AppSpacing.minimumTouchTarget)
                        .padding(.horizontal, AppSpacing.large)
                        .background(AppColors.brandBrown)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppSpacing.buttonCornerRadius)
                                .stroke(AppColors.accentGoldSoft, lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.buttonCornerRadius, style: .continuous))
                        .shadow(color: AppColors.shadow, radius: 12, y: 6)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Manage reservation")
            }
            .padding(.horizontal, AppSpacing.screenPadding)
            .padding(.vertical, AppSpacing.large)
        }
        .background(AppColors.backgroundCream.ignoresSafeArea())
        .navigationTitle("Bookings")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            Task {
                await viewModel.loadBookings()
            }
        }
        .refreshable {
            await viewModel.loadBookings()
        }
    }
}

#Preview {
    NavigationStack {
        BookingsView()
    }
}
