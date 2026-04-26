//
//  DigitalCheckInView.swift
//  HotelCompanion
//
//  File: Features/Uploads/Views/DigitalCheckInView.swift
//

import SwiftUI

struct DigitalCheckInView: View {
    @StateObject private var uploadViewModel = PhotoUploadViewModel(context: .idDocument)

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.large) {
                SectionCard(
                    title: "Digital Check-In",
                    subtitle: "Fast arrival preparation"
                ) {
                    Text("Upload a clear photo of your passport or national ID to speed up arrival processing before you reach the hotel.")
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }

                PhotoUploadFieldView(viewModel: uploadViewModel)
            }
            .padding(.horizontal, AppSpacing.screenPadding)
            .padding(.vertical, AppSpacing.large)
        }
        .background(AppColors.backgroundCream.ignoresSafeArea())
        .navigationTitle("Check-In")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    NavigationStack {
        DigitalCheckInView()
    }
}

