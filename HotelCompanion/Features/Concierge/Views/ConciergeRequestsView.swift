//
//  ConciergeRequestsView.swift
//  HotelCompanion
//
//  File: Features/Concierge/Views/ConciergeRequestsView.swift
//

import SwiftUI

struct ConciergeRequestsView: View {
    @StateObject private var viewModel: ConciergeViewModel

    init(viewModel: ConciergeViewModel = ConciergeViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.large) {
                requestFormSection
                requestsSection
            }
            .padding(.horizontal, AppSpacing.screenPadding)
            .padding(.vertical, AppSpacing.large)
        }
        .background(AppColors.backgroundCream.ignoresSafeArea())
        .navigationTitle("Concierge")
        .navigationBarTitleDisplayMode(.large)
        .task {
            await viewModel.loadRequests()
        }
        .refreshable {
            await viewModel.loadRequests()
        }
    }
}

private extension ConciergeRequestsView {
    var requestFormSection: some View {
        SectionCard(
            title: "Concierge Request",
            subtitle: "Transport, reservations, celebrations, and local arrangements"
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

                Picker("Request Type", selection: $viewModel.selectedRequestType) {
                    ForEach(ConciergeRequestType.allCases, id: \.self) { type in
                        Text(viewModel.displayTitle(for: type)).tag(type)
                    }
                }
                .pickerStyle(.menu)
                .accessibilityLabel("Concierge request type")

                TextField("Title", text: $viewModel.title)
                    .textFieldStyle(AppTextFieldStyle())
                    .accessibilityLabel("Concierge request title")

                TextField("How can the concierge help?", text: $viewModel.detail, axis: .vertical)
                    .lineLimit(3...5)
                    .textFieldStyle(AppTextFieldStyle())
                    .accessibilityLabel("Concierge request details")

                DatePicker("Needed For", selection: $viewModel.requestedFor)
                    .accessibilityLabel("Requested date and time")

                Stepper(value: $viewModel.partySize, in: 1...12) {
                    Text("Party Size: \(viewModel.partySize)")
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.primaryText)
                }
                .frame(minHeight: AppSpacing.minimumTouchTarget)

                PrimaryButton(
                    title: viewModel.isSubmitting ? "Sending Request..." : "Send Concierge Request",
                    systemImage: "paperplane.fill"
                ) {
                    Task {
                        _ = await viewModel.submitRequest()
                    }
                }
                .disabled(!viewModel.canSubmit)
                .opacity(viewModel.canSubmit ? 1 : 0.6)
                .accessibilityLabel("Send concierge request")
            }
        }
    }

    var requestsSection: some View {
        SectionCard(
            title: "Recent Concierge Requests",
            subtitle: "Your current assistance requests and confirmations"
        ) {
            VStack(alignment: .leading, spacing: AppSpacing.large) {
                if viewModel.isLoading {
                    HStack(spacing: AppSpacing.medium) {
                        ProgressView()
                            .tint(AppColors.brandBrown)

                        Text("Loading concierge requests.")
                            .font(AppTypography.body)
                            .foregroundStyle(AppColors.secondaryText)
                    }
                    .frame(minHeight: AppSpacing.minimumTouchTarget)
                } else if viewModel.isEmpty {
                    Text("Your concierge requests will appear here once submitted.")
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    ForEach(viewModel.requests) { request in
                        VStack(alignment: .leading, spacing: AppSpacing.medium) {
                            Text(request.title)
                                .font(AppTypography.headline)
                                .foregroundStyle(AppColors.primaryText)

                            Text(request.detail)
                                .font(AppTypography.body)
                                .foregroundStyle(AppColors.secondaryText)
                                .fixedSize(horizontal: false, vertical: true)

                            Text("\(viewModel.displayTitle(for: request.status)) • \(viewModel.formattedDate(for: request))")
                                .font(AppTypography.footnote)
                                .foregroundStyle(AppColors.secondaryText)

                            if request.status == .submitted || request.status == .reviewing {
                                Button {
                                    Task {
                                        await viewModel.updateStatus(for: request, to: .confirmed)
                                    }
                                } label: {
                                    Text("Mark Confirmed")
                                        .font(AppTypography.bodyEmphasized)
                                        .foregroundStyle(AppColors.brandBrown)
                                        .frame(minHeight: AppSpacing.minimumTouchTarget)
                                }
                                .buttonStyle(.plain)
                            }
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
        ConciergeRequestsView()
    }
}
