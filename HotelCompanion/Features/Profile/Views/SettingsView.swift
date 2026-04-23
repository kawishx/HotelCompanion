//
//  SettingsView.swift
//  HotelCompanion
//
//  File: Features/Profile/Views/SettingsView.swift
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel: SettingsViewModel

    init(viewModel: SettingsViewModel = SettingsViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.large) {
                SectionCard(
                    title: "Security",
                    subtitle: "Secure sign-in preferences"
                ) {
                    VStack(alignment: .leading, spacing: AppSpacing.large) {
                        Toggle(isOn: biometricToggleBinding) {
                            VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
                                Label(toggleTitle, systemImage: viewModel.biometricKind.systemImageName)
                                    .font(AppTypography.headline)
                                    .foregroundStyle(AppColors.primaryText)

                                Text("Use biometrics for a faster and more secure sign-in experience.")
                                    .font(AppTypography.body)
                                    .foregroundStyle(AppColors.secondaryText)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        .tint(AppColors.accentGold)
                        .accessibilityHint("Turns biometric sign in on or off")

                        Text(viewModel.availabilityMessage)
                            .font(AppTypography.footnote)
                            .foregroundStyle(AppColors.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding(.horizontal, AppSpacing.screenPadding)
            .padding(.vertical, AppSpacing.large)
        }
        .background(AppColors.backgroundCream.ignoresSafeArea())
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            viewModel.refresh()
        }
    }

    private var toggleTitle: String {
        switch viewModel.biometricKind {
        case .faceID, .touchID:
            return "Enable \(viewModel.biometricKind.displayName)"
        case .none:
            return "Enable Biometric Login"
        }
    }

    private var biometricToggleBinding: Binding<Bool> {
        Binding(
            get: { viewModel.isBiometricLoginEnabled },
            set: { viewModel.updateBiometricPreference(isEnabled: $0) }
        )
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}

