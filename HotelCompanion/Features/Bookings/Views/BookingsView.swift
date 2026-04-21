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
                    SectionCard(title: booking.title) {
                        Text(booking.detail)
                            .font(AppTypography.body)
                            .foregroundStyle(AppColors.secondaryText)
                    }
                }

                PrimaryButton(title: "Manage Reservation", systemImage: "calendar.badge.clock") { }
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

