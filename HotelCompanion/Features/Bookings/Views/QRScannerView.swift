//
//  QRScannerView.swift
//  HotelCompanion
//
//  File: Features/Bookings/Views/QRScannerView.swift
//

import SwiftUI
import UIKit

struct QRScannerView: View {
    @StateObject private var viewModel: QRScannerViewModel
    @Environment(\.openURL) private var openURL

    init(bookings: [BookingSummary]) {
        _viewModel = StateObject(wrappedValue: QRScannerViewModel(bookings: bookings))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.large) {
                SectionCard(
                    title: "QR Scanner",
                    subtitle: "Scan and validate a booking code"
                ) {
                    Text("Point the camera at a Cinnamon Companion booking QR code to validate the reservation.")
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }

                scannerContent
            }
            .padding(.horizontal, AppSpacing.screenPadding)
            .padding(.vertical, AppSpacing.large)
        }
        .background(AppColors.backgroundCream.ignoresSafeArea())
        .navigationTitle("Scan QR")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.prepareScanner()
        }
    }

    @ViewBuilder
    private var scannerContent: some View {
        switch viewModel.scanState {
        case .idle:
            scannerCard
        case .success(let message):
            resultCard(
                title: "Scan Successful",
                subtitle: message,
                systemImage: "checkmark.seal.fill",
                accentColor: AppColors.brandBrown
            )
        case .invalid(let message):
            resultCard(
                title: "Invalid QR Code",
                subtitle: message,
                systemImage: "xmark.octagon.fill",
                accentColor: .red
            )
        case .permissionRequired(let message):
            permissionCard(message: message)
        }
    }

    private var scannerCard: some View {
        SectionCard(
            title: "Live Camera Scan",
            subtitle: "Hold your device steady over the QR code"
        ) {
            VStack(alignment: .leading, spacing: AppSpacing.large) {
                QRCodeScannerCameraView { code in
                    viewModel.processScannedCode(code)
                }
                .frame(height: 320)
                .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cardCornerRadius, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: AppSpacing.cardCornerRadius, style: .continuous)
                        .stroke(AppColors.border, lineWidth: 1)
                )
                .accessibilityLabel("Live QR code scanner")

                Button {
                    viewModel.resetScanner()
                    Task {
                        await viewModel.prepareScanner()
                    }
                } label: {
                    HStack(spacing: AppSpacing.small) {
                        Image(systemName: "qrcode.viewfinder")
                            .font(.headline)

                        Text("Restart Scanner")
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
                .accessibilityLabel("Restart QR scanner")
            }
        }
    }

    private func resultCard(
        title: String,
        subtitle: String,
        systemImage: String,
        accentColor: Color
    ) -> some View {
        SectionCard(title: title, subtitle: "Scan result") {
            VStack(alignment: .leading, spacing: AppSpacing.large) {
                HStack(alignment: .top, spacing: AppSpacing.medium) {
                    Image(systemName: systemImage)
                        .font(.title2)
                        .foregroundStyle(accentColor)
                        .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: AppSpacing.small) {
                        Text(subtitle)
                            .font(AppTypography.body)
                            .foregroundStyle(AppColors.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)

                        if let booking = viewModel.matchedBooking {
                            Text("\(booking.propertyName) • \(booking.confirmationCode)")
                                .font(AppTypography.bodyEmphasized)
                                .foregroundStyle(AppColors.primaryText)
                        }
                    }
                }

                Button {
                    viewModel.resetScanner()
                    Task {
                        await viewModel.prepareScanner()
                    }
                } label: {
                    HStack(spacing: AppSpacing.small) {
                        Image(systemName: "arrow.clockwise")
                            .font(.headline)

                        Text("Scan Another QR")
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
                .accessibilityLabel("Scan another QR code")
            }
        }
    }

    private func permissionCard(message: String) -> some View {
        SectionCard(title: "Camera Permission Required", subtitle: "Scanner access") {
            VStack(alignment: .leading, spacing: AppSpacing.large) {
                Text(message)
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)

                PrimaryButton(title: "Open Settings", systemImage: "camera.fill") {
                    if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                        openURL(settingsURL)
                    }
                }
                .accessibilityLabel("Open settings to enable camera permission")
            }
        }
    }
}

#Preview {
    NavigationStack {
        QRScannerView(
            bookings: [
                BookingSummary(
                    title: "Oceanfront Suite",
                    detail: "12 May to 15 May • 2 guests",
                    guestName: "Kawish Jayawardena",
                    confirmationCode: "CC48291",
                    propertyName: "Cinnamon Bentota Beach"
                )
            ]
        )
    }
}

