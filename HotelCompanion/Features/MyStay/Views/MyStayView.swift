//
//  MyStayView.swift
//  HotelCompanion
//
//  File: Features/MyStay/Views/MyStayView.swift
//

import SwiftUI

@MainActor
struct MyStayView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @StateObject private var viewModel: MyStayViewModel

    init(viewModel: MyStayViewModel? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel ?? MyStayViewModel())
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.large) {
                switch contentState {
                case .loading:
                    loadingSection
                case .error(let message):
                    errorSection(message: message)
                case .empty:
                    emptySection
                case .loaded:
                    stayContent
                }
            }
            .padding(.horizontal, AppSpacing.screenPadding)
            .padding(.vertical, AppSpacing.large)
        }
        .background(AppColors.backgroundCream.ignoresSafeArea())
        .navigationTitle("My Stay")
        .navigationBarTitleDisplayMode(.large)
        .task {
            await viewModel.loadStay()
        }
    }
}

private extension MyStayView {
    enum ContentState {
        case loading
        case error(String)
        case empty
        case loaded
    }

    var contentState: ContentState {
        if viewModel.isLoading {
            return .loading
        }

        if let errorMessage = viewModel.errorMessage {
            return .error(errorMessage)
        }

        if viewModel.isEmpty {
            return .empty
        }

        return .loaded
    }

    var loadingSection: some View {
        SectionCard(title: "Loading Stay", subtitle: "Syncing the latest details from the hotel") {
            LoadingStateView(
                title: "Loading Stay",
                message: "Your stay summary is being prepared.",
                systemImage: "bed.double.circle.fill"
            )
        }
    }

    func errorSection(message: String) -> some View {
        ErrorStateCard(
            title: "Unable to Load Stay",
            subtitle: "Please try again in a moment",
            message: message,
            retryAction: {
                Task {
                    await viewModel.loadStay()
                }
            }
        )
    }

    var emptySection: some View {
        EmptyStateCard(
            title: "No Active Stay",
            subtitle: "Your reservation will appear here when available",
            message: "Once a hotel stay is linked to your account, room details, dates, and status updates will appear in this section.",
            systemImage: "moon.zzz.fill"
        )
    }

    var stayContent: some View {
        VStack(alignment: .leading, spacing: AppSpacing.large) {
            SectionCard(title: viewModel.hotelDisplayName, subtitle: viewModel.subtitle) {
                VStack(alignment: .leading, spacing: AppSpacing.medium) {
                    Text(viewModel.title)
                        .font(AppTypography.title)
                        .foregroundStyle(AppColors.primaryText)

                    Text(viewModel.highlightText)
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            SectionCard(title: "Stay Summary", subtitle: viewModel.statusTitle) {
                ViewThatFits(in: .horizontal) {
                    HStack(alignment: .top, spacing: AppSpacing.medium) {
                        stayMetricColumn
                    }

                    VStack(alignment: .leading, spacing: AppSpacing.medium) {
                        stayMetricColumn
                    }
                }
            }

            SectionCard(title: "Timing", subtitle: "Current stay schedule") {
                VStack(alignment: .leading, spacing: AppSpacing.medium) {
                    stayMetricRow(title: "Check-In", value: viewModel.checkInTimeText)
                    stayMetricRow(title: "Check-Out", value: viewModel.checkOutTimeText)
                }
            }
        }
    }

    func stayMetricRow(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
            Text(title)
                .font(AppTypography.footnote)
                .foregroundStyle(AppColors.secondaryText)

            Text(value)
                .font(AppTypography.bodyEmphasized)
                .foregroundStyle(AppColors.primaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppSpacing.medium)
        .background(AppColors.surfaceWarm.opacity(0.35))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
        .accessibilityValue(value)
    }

    @ViewBuilder
    var stayMetricColumn: some View {
        stayMetricRow(title: "Room", value: viewModel.roomDisplay)
        stayMetricRow(title: "Booking", value: viewModel.bookingDisplay)
        stayMetricRow(title: "Guests", value: viewModel.guestCountDisplay)

        if let wingDisplay = viewModel.wingDisplay {
            stayMetricRow(title: "Location", value: wingDisplay)
        }
    }
}

#Preview {
    NavigationStack {
        MyStayView()
    }
}
