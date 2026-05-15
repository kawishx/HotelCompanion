//
//  BiometricUnlockView.swift
//  HotelCompanion
//
//  File: Features/Auth/Views/BiometricUnlockView.swift
//

import SwiftUI

@MainActor
struct BiometricUnlockView: View {
    let sessionTitle: String
    let biometricKind: BiometricKind
    let onUnlock: () -> Void
    let onUseAnotherAccount: () -> Void

    @State private var isAuthenticating = false
    @State private var errorMessage: String?

    private let biometricAuthManager = BiometricAuthManager.shared

    var body: some View {
        ZStack {
            AuthBackgroundView()

            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.xLarge) {
                    VStack(alignment: .leading, spacing: AppSpacing.medium) {
                        Text("Welcome Back")
                            .font(AppTypography.navigationTitle)
                            .foregroundStyle(AppColors.primaryText)

                        Text(sessionTitle)
                            .font(AppTypography.body)
                            .foregroundStyle(AppColors.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    SectionCard(
                        title: "Unlock Cinnamon Companion",
                        subtitle: "Use \(biometricKind.displayName) to continue to your stay"
                    ) {
                        VStack(alignment: .leading, spacing: AppSpacing.large) {
                            StatusChip(
                                title: "\(biometricKind.displayName) is protecting your saved session on this device.",
                                systemImage: biometricKind.systemImageName,
                                tone: .accent
                            )

                            if let errorMessage {
                                ErrorStateCard(
                                    title: "Biometric Unlock Failed",
                                    subtitle: "Please try again",
                                    message: errorMessage,
                                    retryTitle: "Try \(biometricKind.displayName) Again",
                                    retryAction: authenticate
                                )
                            }

                            PrimaryButton(
                                title: isAuthenticating ? "Checking \(biometricKind.displayName)..." : "Continue with \(biometricKind.displayName)",
                                systemImage: biometricKind.systemImageName
                            ) {
                                authenticate()
                            }
                            .disabled(isAuthenticating)
                            .opacity(isAuthenticating ? 0.6 : 1)

                            SecondaryButton(
                                title: "Use Another Account",
                                systemImage: "person.crop.circle.badge.xmark",
                                alignment: .center
                            ) {
                                onUseAnotherAccount()
                            }
                        }
                    }
                }
                .padding(.horizontal, AppSpacing.screenPadding)
                .padding(.vertical, AppSpacing.xxLarge)
                .frame(maxWidth: 560)
                .frame(maxWidth: .infinity)
            }
        }
    }
}

private extension BiometricUnlockView {
    func authenticate() {
        guard !isAuthenticating else { return }

        isAuthenticating = true
        errorMessage = nil

        Task {
            let result = await biometricAuthManager.authenticateUser(
                reason: "Unlock Cinnamon Companion securely."
            )

            isAuthenticating = false

            switch result {
            case .success:
                onUnlock()
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
    }
}

#Preview {
    BiometricUnlockView(
        sessionTitle: "guest@example.com",
        biometricKind: .faceID,
        onUnlock: {},
        onUseAnotherAccount: {}
    )
}
