//
//  BookingConfirmationView.swift
//  HotelCompanion
//
//  File: Features/Bookings/Views/BookingConfirmationView.swift
//

import SwiftUI

@MainActor
struct BookingConfirmationView: View {
    @StateObject private var viewModel: BookingConfirmationViewModel

    init(booking: BookingSummary, viewModel: BookingConfirmationViewModel? = nil) {
        _viewModel = StateObject(
            wrappedValue: viewModel ?? BookingConfirmationViewModel(booking: booking)
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.large) {
                SectionCard(
                    title: "Booking Confirmed",
                    subtitle: viewModel.booking.propertyName
                ) {
                    VStack(alignment: .leading, spacing: AppSpacing.medium) {
                        Text(viewModel.booking.title)
                            .font(AppTypography.headline)
                            .foregroundStyle(AppColors.primaryText)

                        Text(viewModel.booking.detail)
                            .font(AppTypography.body)
                            .foregroundStyle(AppColors.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)

                        Text("Guest: \(viewModel.booking.guestName)")
                            .font(AppTypography.bodyEmphasized)
                            .foregroundStyle(AppColors.primaryText)
                    }
                }

                QRPassView(booking: viewModel.booking)
            }
            .padding(.horizontal, AppSpacing.screenPadding)
            .padding(.vertical, AppSpacing.large)
        }
        .background(AppColors.backgroundCream.ignoresSafeArea())
        .navigationTitle("Confirmation")
        .navigationBarTitleDisplayMode(.large)
    }
}
