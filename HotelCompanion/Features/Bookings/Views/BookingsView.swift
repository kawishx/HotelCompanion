//
//  BookingsView.swift
//  HotelCompanion
//
//  File: Features/Bookings/Views/BookingsView.swift
//

import SwiftUI

struct BookingsView: View {
    @StateObject private var viewModel: BookingsViewModel

    init(viewModel: BookingsViewModel = BookingsViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.large) {
                SectionCard(
                    title: "Bookings",
                    subtitle: "Reservations, room upgrades, and transport in one place"
                ) {
                    Text("Your reservations layer is ready for future synchronization with booking systems and authenticated guest records.")
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.secondaryText)
                }

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

                NavigationLink {
                    BookingManagementView(
                        viewModel: BookingManagementViewModel(
                            upcomingBookings: viewModel.upcomingBookings,
                            bookedExperiences: viewModel.bookedExperiences
                        )
                    )
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
    }
}

#Preview {
    NavigationStack {
        BookingsView()
    }
}
