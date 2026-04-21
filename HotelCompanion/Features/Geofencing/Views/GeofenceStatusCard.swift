//
//  GeofenceStatusCard.swift
//  HotelCompanion
//
//  File: Features/Geofencing/Views/GeofenceStatusCard.swift
//

import SwiftUI

struct GeofenceStatusCard: View {
    @StateObject private var viewModel: GeofenceStatusViewModel

    init(viewModel: GeofenceStatusViewModel = GeofenceStatusViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
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
                    Button {
                        viewModel.startMonitoring()
                    } label: {
                        Text("Start Monitoring Hotel Region")
                            .font(AppTypography.button)
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
                    .accessibilityLabel("Start monitoring the Cinnamon Thiya hotel region")
                }
            }
        }
        .task {
            viewModel.refresh()
        }
    }

    private func statusChip(title: String, systemImage: String) -> some View {
        HStack(spacing: AppSpacing.small) {
            Image(systemName: systemImage)
                .font(.subheadline)
                .foregroundStyle(AppColors.brandBrown)

            Text(title)
                .font(AppTypography.footnote)
                .foregroundStyle(AppColors.primaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, AppSpacing.medium)
        .frame(minHeight: AppSpacing.minimumTouchTarget)
        .background(AppColors.surfaceWarm.opacity(0.45))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    GeofenceStatusCard()
        .padding()
        .background(AppColors.backgroundCream)
}

