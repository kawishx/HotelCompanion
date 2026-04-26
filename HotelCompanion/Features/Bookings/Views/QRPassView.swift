//
//  QRPassView.swift
//  HotelCompanion
//
//  File: Features/Bookings/Views/QRPassView.swift
//

import SwiftUI

struct QRPassView: View {
    @StateObject private var viewModel: QRPassViewModel

    init(booking: BookingSummary) {
        _viewModel = StateObject(wrappedValue: QRPassViewModel(booking: booking))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.large) {
                SectionCard(
                    title: viewModel.booking.title,
                    subtitle: "Booking QR Pass"
                ) {
                    VStack(alignment: .leading, spacing: AppSpacing.large) {
                        Text(viewModel.booking.detail)
                            .font(AppTypography.body)
                            .foregroundStyle(AppColors.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)

                        qrDisplay

                        VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
                            Text("Confirmation Code")
                                .font(AppTypography.footnote)
                                .foregroundStyle(AppColors.secondaryText)

                            Text(viewModel.booking.confirmationCode)
                                .font(AppTypography.bodyEmphasized)
                                .foregroundStyle(AppColors.primaryText)
                        }
                        .accessibilityElement(children: .combine)
                    }
                }
            }
            .padding(.horizontal, AppSpacing.screenPadding)
            .padding(.vertical, AppSpacing.large)
        }
        .background(AppColors.backgroundCream.ignoresSafeArea())
        .navigationTitle("QR Pass")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var qrDisplay: some View {
        Group {
            if let qrImage = viewModel.qrImage {
                Image(uiImage: qrImage)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .frame(height: 220)
                    .padding(AppSpacing.medium)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cardCornerRadius, style: .continuous))
                    .accessibilityLabel("Booking QR code for \(viewModel.booking.title)")
            } else {
                RoundedRectangle(cornerRadius: AppSpacing.cardCornerRadius, style: .continuous)
                    .fill(AppColors.surfaceWarm.opacity(0.4))
                    .frame(height: 220)
                    .overlay {
                        Text("QR code unavailable")
                            .font(AppTypography.bodyEmphasized)
                            .foregroundStyle(AppColors.primaryText)
                    }
                    .accessibilityLabel("QR code unavailable")
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: AppSpacing.cardCornerRadius, style: .continuous)
                .stroke(AppColors.border, lineWidth: 1)
        )
    }
}

#Preview {
    NavigationStack {
        QRPassView(
            booking: BookingSummary(
                title: "Oceanfront Suite",
                detail: "12 May to 15 May • 2 guests",
                guestName: "Kawish Jayawardena",
                confirmationCode: "CC48291",
                propertyName: "Cinnamon Bentota Beach"
            )
        )
    }
}

