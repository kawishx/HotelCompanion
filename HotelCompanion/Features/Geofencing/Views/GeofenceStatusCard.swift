//
//  GeofenceStatusCard.swift
//  HotelCompanion
//
//  File: Features/Geofencing/Views/GeofenceStatusCard.swift
//

import SwiftUI

@MainActor
struct GeofenceStatusCard: View {
    @StateObject private var viewModel: GeofenceStatusViewModel

    init(viewModel: GeofenceStatusViewModel? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel ?? GeofenceStatusViewModel())
    }

    var body: some View {
        SectionCard(
            title: viewModel.statusTitle,
            subtitle: "Hotel arrival automation"
        ) {
            VStack(alignment: .leading, spacing: AppSpacing.large) {
                Text(viewModel.statusMessage)
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)

                ViewThatFits(in: .vertical) {
                    HStack(spacing: AppSpacing.medium) {
                        statusChip(title: viewModel.locationStateText, systemImage: "location.fill")
                        statusChip(title: viewModel.notificationStateText, systemImage: "bell.badge.fill")
                    }

                    VStack(alignment: .leading, spacing: AppSpacing.medium) {
                        statusChip(title: viewModel.locationStateText, systemImage: "location.fill")
                        statusChip(title: viewModel.notificationStateText, systemImage: "bell.badge.fill")
                    }
                }

                statusChip(title: viewModel.monitoringStateText, systemImage: "dot.radiowaves.left.and.right")
                statusChip(title: viewModel.lastEventText, systemImage: "figure.walk.circle")

                if viewModel.shouldShowPermissionButton {
                    PrimaryButton(title: "Enable Hotel Alerts", systemImage: "bell.and.waves.left.and.right.fill") {
                        viewModel.requestPermissions()
                    }
                    .accessibilityLabel("Enable hotel geofence alerts")
                }

                if viewModel.shouldShowStartButton {
                    SecondaryButton(title: "Start Monitoring Hotel Region", systemImage: "dot.radiowaves.left.and.right", alignment: .leading) {
                        viewModel.startMonitoring()
                    }
                    .accessibilityLabel("Start monitoring the Cinnamon Thiya hotel region")
                }
            }
        }
        .task {
            viewModel.refresh()
        }
    }

    private func statusChip(title: String, systemImage: String) -> some View {
        StatusChip(title: title, systemImage: systemImage, tone: .neutral)
    }
}

#Preview {
    GeofenceStatusCard()
        .padding()
        .background(AppColors.backgroundCream)
}
