//
//  ServiceRequestView.swift
//  HotelCompanion
//
//  File: Features/Uploads/Views/ServiceRequestView.swift
//

import SwiftUI

struct ServiceRequestView: View {
    @StateObject private var viewModel = ServiceRequestViewModel()
    @StateObject private var uploadViewModel = PhotoUploadViewModel(context: .maintenanceIssue)

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.large) {
                SectionCard(
                    title: "Service Request",
                    subtitle: "Report a maintenance issue"
                ) {
                    VStack(alignment: .leading, spacing: AppSpacing.medium) {
                        Text("Share a few details and attach a photo so the maintenance team can identify the issue quickly.")
                            .font(AppTypography.body)
                            .foregroundStyle(AppColors.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)

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

                        NavigationLink {
                            ServiceRequestStatusView(viewModel: viewModel)
                        } label: {
                            HStack(spacing: AppSpacing.small) {
                                Text("View Request Status")
                                    .font(AppTypography.bodyEmphasized)
                                    .foregroundStyle(AppColors.brandBrown)

                                Image(systemName: "chevron.right.circle.fill")
                                    .foregroundStyle(AppColors.brandBrown)
                                    .accessibilityHidden(true)
                            }
                            .frame(minHeight: AppSpacing.minimumTouchTarget)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("View service request status")

                        VStack(alignment: .leading, spacing: AppSpacing.small) {
                            Text("Request Type")
                                .font(AppTypography.headline)
                                .foregroundStyle(AppColors.primaryText)

                            Picker("Request type", selection: $viewModel.selectedRequestType) {
                                Text("Maintenance").tag(ServiceRequestCategory.maintenance)
                                Text("Housekeeping").tag(ServiceRequestCategory.housekeeping)
                                Text("Amenities").tag(ServiceRequestCategory.amenities)
                                Text("Room Setup").tag(ServiceRequestCategory.roomSetup)
                                Text("Other").tag(ServiceRequestCategory.other)
                            }
                            .pickerStyle(.menu)
                            .tint(AppColors.brandBrown)
                            .frame(minHeight: AppSpacing.minimumTouchTarget)
                            .accessibilityLabel("Service request type")
                        }

                        VStack(alignment: .leading, spacing: AppSpacing.small) {
                            Text("Room Number")
                                .font(AppTypography.headline)
                                .foregroundStyle(AppColors.primaryText)

                            TextField("e.g. 408", text: $viewModel.roomNumber)
                                .textFieldStyle(AppTextFieldStyle())
                                .accessibilityLabel("Room number")
                        }

                        VStack(alignment: .leading, spacing: AppSpacing.small) {
                            Text("Priority")
                                .font(AppTypography.headline)
                                .foregroundStyle(AppColors.primaryText)

                            Picker("Priority", selection: $viewModel.priority) {
                                Text("Low").tag(ServiceRequestPriority.low)
                                Text("Normal").tag(ServiceRequestPriority.normal)
                                Text("High").tag(ServiceRequestPriority.high)
                                Text("Urgent").tag(ServiceRequestPriority.urgent)
                            }
                            .pickerStyle(.segmented)
                            .accessibilityLabel("Service request priority")
                        }

                        VStack(alignment: .leading, spacing: AppSpacing.small) {
                            Text("Note")
                                .font(AppTypography.headline)
                                .foregroundStyle(AppColors.primaryText)

                            TextField("Describe the issue briefly", text: $viewModel.note, axis: .vertical)
                                .lineLimit(3...5)
                                .textFieldStyle(AppTextFieldStyle())
                                .accessibilityLabel("Service request note")
                        }
                    }
                }

                PhotoUploadFieldView(viewModel: uploadViewModel)

                PrimaryButton(
                    title: viewModel.isSubmitting ? "Sending Request..." : "Submit Request",
                    systemImage: "paperplane.fill"
                ) {
                    Task {
                        var uploadedImageURL: URL?

                        if uploadViewModel.hasConfirmedUpload {
                            let didUpload = await uploadViewModel.uploadConfirmedImageIfNeeded()
                            guard didUpload else { return }
                            uploadedImageURL = uploadViewModel.uploadedDownloadURL
                        }

                        let didSubmit = await viewModel.submitRequest(uploadedImageURL: uploadedImageURL)

                        if didSubmit {
                            uploadViewModel.removeImage()
                        }
                    }
                }
                .disabled(!viewModel.canSubmit || uploadViewModel.isUploading)
                .opacity((viewModel.canSubmit && !uploadViewModel.isUploading) ? 1 : 0.6)
                .accessibilityLabel("Submit service request")

                recentRequestsSection
            }
            .padding(.horizontal, AppSpacing.screenPadding)
            .padding(.vertical, AppSpacing.large)
        }
        .background(AppColors.backgroundCream.ignoresSafeArea())
        .navigationTitle("Request Service")
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

private extension ServiceRequestView {
    @ViewBuilder
    var recentRequestsSection: some View {
        if !viewModel.recentRequests.isEmpty {
            SectionCard(title: "Recent Requests", subtitle: "Latest service activity") {
                VStack(alignment: .leading, spacing: AppSpacing.medium) {
                    ForEach(viewModel.recentRequests) { request in
                        VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
                            Text(viewModel.displayTitle(for: request.requestType))
                                .font(AppTypography.headline)
                                .foregroundStyle(AppColors.primaryText)

                            Text(request.note)
                                .font(AppTypography.body)
                                .foregroundStyle(AppColors.secondaryText)
                                .fixedSize(horizontal: false, vertical: true)

                            Text("\(viewModel.displayTitle(for: request.status)) • \(viewModel.formattedCreatedAt(for: request))")
                                .font(AppTypography.footnote)
                                .foregroundStyle(AppColors.secondaryText)
                        }
                        .accessibilityElement(children: .combine)
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ServiceRequestView()
    }
}
