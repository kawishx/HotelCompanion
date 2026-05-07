//
//  ServiceRequestStatusView.swift
//  HotelCompanion
//
//  File: Features/ServiceRequests/Views/ServiceRequestStatusView.swift
//

import SwiftUI

struct ServiceRequestStatusView: View {
    @ObservedObject var viewModel: ServiceRequestViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.large) {
                statusSummarySection
                requestsSection
            }
            .padding(.horizontal, AppSpacing.screenPadding)
            .padding(.vertical, AppSpacing.large)
        }
        .background(AppColors.backgroundCream.ignoresSafeArea())
        .navigationTitle("Request Status")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            Task {
                await viewModel.loadRequests()
            }
        }
        .refreshable {
            await viewModel.loadRequests()
        }
    }
}

private extension ServiceRequestStatusView {
    var statusSummarySection: some View {
        SectionCard(
            title: "Service Requests",
            subtitle: "Track hotel updates for submitted requests"
        ) {
            VStack(alignment: .leading, spacing: AppSpacing.medium) {
                if let successMessage = viewModel.successMessage {
                    Text(successMessage)
                        .font(AppTypography.footnote)
                        .foregroundStyle(AppColors.brandBrown)
                        .fixedSize(horizontal: false, vertical: true)
                }

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(AppTypography.footnote)
                        .foregroundStyle(.red.opacity(0.85))
                        .fixedSize(horizontal: false, vertical: true)
                }

                Text("Submitted requests are stored in Firestore and linked to the current guest and hotel.")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    @ViewBuilder
    var requestsSection: some View {
        if viewModel.isLoadingRequests {
            SectionCard(title: "Loading Requests", subtitle: "Syncing your latest request activity") {
                HStack(spacing: AppSpacing.medium) {
                    ProgressView()
                        .tint(AppColors.brandBrown)

                    Text("Your service requests are being prepared.")
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.secondaryText)
                }
                .frame(minHeight: AppSpacing.minimumTouchTarget)
            }
        } else if viewModel.isEmpty {
            SectionCard(title: "No Service Requests", subtitle: "Your requests will appear here after submission") {
                Text("Once you contact the hotel team through Cinnamon Companion, the request status history will be listed here.")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        } else {
            SectionCard(title: "Request History") {
                VStack(alignment: .leading, spacing: AppSpacing.large) {
                    ForEach(viewModel.requests) { request in
                        VStack(alignment: .leading, spacing: AppSpacing.medium) {
                            Text(viewModel.displayTitle(for: request.requestType))
                                .font(AppTypography.headline)
                                .foregroundStyle(AppColors.primaryText)

                            Text(request.note)
                                .font(AppTypography.body)
                                .foregroundStyle(AppColors.secondaryText)
                                .fixedSize(horizontal: false, vertical: true)

                            metadataRow(title: "Priority", value: viewModel.displayTitle(for: request.priority))
                            metadataRow(title: "Status", value: viewModel.displayTitle(for: request.status))
                            metadataRow(title: "Created", value: viewModel.formattedCreatedAt(for: request))

                            if let roomNumber = request.roomNumber {
                                metadataRow(title: "Room", value: roomNumber)
                            }

                            if let uploadedImageURL = request.uploadedImageURL {
                                metadataRow(title: "Image", value: uploadedImageURL.absoluteString)
                            }

                            if request.status == .open || request.status == .acknowledged {
                                Button {
                                    Task {
                                        let nextStatus: ServiceRequestStatus = request.status == .open ? .inProgress : .resolved
                                        await viewModel.updateStatus(for: request, to: nextStatus)
                                    }
                                } label: {
                                    actionLabel(
                                        title: request.status == .open ? "Mark In Progress" : "Mark Resolved",
                                        systemImage: request.status == .open ? "clock.badge.checkmark" : "checkmark.circle"
                                    )
                                }
                                .buttonStyle(.plain)
                                .disabled(viewModel.activeRequestID == request.id)
                                .opacity(viewModel.activeRequestID == request.id ? 0.6 : 1)
                            }
                        }
                        .padding(.bottom, AppSpacing.small)
                    }
                }
            }
        }
    }

    func metadataRow(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
            Text(title)
                .font(AppTypography.footnote)
                .foregroundStyle(AppColors.secondaryText)

            Text(value)
                .font(AppTypography.bodyEmphasized)
                .foregroundStyle(AppColors.primaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
    }

    func actionLabel(title: String, systemImage: String) -> some View {
        HStack(spacing: AppSpacing.small) {
            Image(systemName: systemImage)
                .font(.headline)

            Text(title)
                .font(AppTypography.bodyEmphasized)
        }
        .foregroundStyle(AppColors.brandBrown)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(minHeight: AppSpacing.minimumTouchTarget)
        .padding(.horizontal, AppSpacing.medium)
        .background(AppColors.surfaceCream)
        .overlay(
            RoundedRectangle(cornerRadius: AppSpacing.buttonCornerRadius, style: .continuous)
                .stroke(AppColors.border, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.buttonCornerRadius, style: .continuous))
    }
}

#Preview {
    NavigationStack {
        ServiceRequestStatusView(viewModel: ServiceRequestViewModel())
    }
}
