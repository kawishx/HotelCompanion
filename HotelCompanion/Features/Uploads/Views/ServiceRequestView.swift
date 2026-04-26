//
//  ServiceRequestView.swift
//  HotelCompanion
//
//  File: Features/Uploads/Views/ServiceRequestView.swift
//

import SwiftUI

struct ServiceRequestView: View {
    @StateObject private var uploadViewModel = PhotoUploadViewModel(context: .maintenanceIssue)
    @State private var issueSummary = ""
    @State private var roomNumber = ""

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

                        VStack(alignment: .leading, spacing: AppSpacing.small) {
                            Text("Room Number")
                                .font(AppTypography.headline)
                                .foregroundStyle(AppColors.primaryText)

                            TextField("e.g. 408", text: $roomNumber)
                                .textFieldStyle(AppTextFieldStyle())
                                .accessibilityLabel("Room number")
                        }

                        VStack(alignment: .leading, spacing: AppSpacing.small) {
                            Text("Issue Summary")
                                .font(AppTypography.headline)
                                .foregroundStyle(AppColors.primaryText)

                            TextField("Describe the issue briefly", text: $issueSummary, axis: .vertical)
                                .lineLimit(3...5)
                                .textFieldStyle(AppTextFieldStyle())
                                .accessibilityLabel("Issue summary")
                        }
                    }
                }

                PhotoUploadFieldView(viewModel: uploadViewModel)
            }
            .padding(.horizontal, AppSpacing.screenPadding)
            .padding(.vertical, AppSpacing.large)
        }
        .background(AppColors.backgroundCream.ignoresSafeArea())
        .navigationTitle("Request Service")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    NavigationStack {
        ServiceRequestView()
    }
}

