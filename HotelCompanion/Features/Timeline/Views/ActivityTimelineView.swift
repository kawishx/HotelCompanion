//
//  ActivityTimelineView.swift
//  HotelCompanion
//
//  File: Features/Timeline/Views/ActivityTimelineView.swift
//

import SwiftUI

struct ActivityTimelineView: View {
    @StateObject private var viewModel: ActivityTimelineViewModel

    init(viewModel: ActivityTimelineViewModel = ActivityTimelineViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.large) {
                SectionCard(
                    title: "Guest Activity",
                    subtitle: "Bookings, dining, check-in, service, and concierge updates"
                ) {
                    content
                }
            }
            .padding(.horizontal, AppSpacing.screenPadding)
            .padding(.vertical, AppSpacing.large)
        }
        .background(AppColors.backgroundCream.ignoresSafeArea())
        .navigationTitle("Activity Timeline")
        .navigationBarTitleDisplayMode(.large)
        .task {
            await viewModel.loadTimeline()
        }
        .refreshable {
            await viewModel.loadTimeline()
        }
    }
}

private extension ActivityTimelineView {
    @ViewBuilder
    var content: some View {
        if viewModel.isLoading {
            HStack(spacing: AppSpacing.medium) {
                ProgressView()
                    .tint(AppColors.brandBrown)

                Text("Loading your guest activity.")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.secondaryText)
            }
            .frame(minHeight: AppSpacing.minimumTouchTarget)
        } else if let errorMessage = viewModel.errorMessage {
            Text(errorMessage)
                .font(AppTypography.body)
                .foregroundStyle(.red.opacity(0.85))
                .fixedSize(horizontal: false, vertical: true)
        } else if viewModel.isEmpty {
            Text("Your guest timeline will appear here as bookings, services, dining, and stay activity are synced.")
                .font(AppTypography.body)
                .foregroundStyle(AppColors.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        } else {
            VStack(alignment: .leading, spacing: AppSpacing.large) {
                ForEach(viewModel.events) { event in
                    VStack(alignment: .leading, spacing: AppSpacing.small) {
                        Text(viewModel.title(for: event.eventType))
                            .font(AppTypography.footnote)
                            .foregroundStyle(AppColors.brandBrown)

                        Text(event.title)
                            .font(AppTypography.headline)
                            .foregroundStyle(AppColors.primaryText)

                        Text(event.detail)
                            .font(AppTypography.body)
                            .foregroundStyle(AppColors.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)

                        Text(event.occurredAt.formatted(date: .abbreviated, time: .shortened))
                            .font(AppTypography.footnote)
                            .foregroundStyle(AppColors.secondaryText)
                    }
                    .padding(AppSpacing.medium)
                    .background(AppColors.surfaceWarm.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .accessibilityElement(children: .combine)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ActivityTimelineView()
    }
}
