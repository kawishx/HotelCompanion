//
//  SettingsView.swift
//  HotelCompanion
//
//  File: Features/Profile/Views/SettingsView.swift
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
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

                SectionCard(
                    title: authViewModel.sessionTitle,
                    subtitle: authViewModel.sessionSubtitle
                ) {
                    VStack(alignment: .leading, spacing: AppSpacing.medium) {
                        Text("Biometric login works alongside your active Firebase session. Signing out clears the current session and returns you to the login flow.")
                            .font(AppTypography.body)
                            .foregroundStyle(AppColors.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)

                        if let successMessage = authViewModel.lastSuccessMessage {
                            Text(successMessage)
                                .font(AppTypography.footnote)
                                .foregroundStyle(AppColors.brandBrown)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        if let errorMessage = authViewModel.errorMessage {
                            Text(errorMessage)
                                .font(AppTypography.footnote)
                                .foregroundStyle(.red.opacity(0.85))
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        if authViewModel.isAuthenticated {
                            PrimaryButton(title: "Sign Out", systemImage: "rectangle.portrait.and.arrow.right") {
                                _ = authViewModel.signOut()
                            }
                            .accessibilityLabel("Sign out of Cinnamon Companion")
                        }
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
    .environmentObject(AuthViewModel())
}
