//
//  LoginView.swift
//  HotelCompanion
//
//  File: Features/Auth/Views/LoginView.swift
//

import SwiftUI

@MainActor
struct LoginView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @StateObject private var viewModel: LoginViewModel
    @FocusState private var focusedField: Field?

    private enum Field {
        case email
        case password
    }

    init(viewModel: LoginViewModel? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel ?? LoginViewModel())
    }

    var body: some View {
        ZStack {
            AuthBackgroundView()

            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.xLarge) {
                    heroSection
                    credentialsSection
                    actionsSection
                }
                .padding(.horizontal, AppSpacing.screenPadding)
                .padding(.vertical, AppSpacing.xxLarge)
                .frame(maxWidth: 560)
                .frame(maxWidth: .infinity)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .task {
            viewModel.refreshBiometricState()
        }
    }

    private var heroSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            Picker("Authentication mode", selection: $viewModel.mode) {
                ForEach(LoginMode.allCases) { mode in
                    Text(mode.title).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .accessibilityLabel("Authentication mode")
            .accessibilityValue(viewModel.mode.title)

            Text(viewModel.heroTitle)
                .font(AppTypography.display)
                .foregroundStyle(AppColors.primaryText)
                .accessibilityAddTraits(.isHeader)

            Text(viewModel.heroSubtitle)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
    }

    private var credentialsSection: some View {
        SectionCard(title: "Guest Access", subtitle: "Securely continue to your hospitality dashboard") {
            VStack(alignment: .leading, spacing: AppSpacing.large) {
                VStack(alignment: .leading, spacing: AppSpacing.small) {
                    Text("Email")
                        .font(AppTypography.headline)
                        .foregroundStyle(AppColors.primaryText)

                    TextField("name@example.com", text: $viewModel.email)
                        .textFieldStyle(AppTextFieldStyle())
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .submitLabel(.next)
                        .focused($focusedField, equals: .email)
                        .accessibilityLabel("Email address")
                        .accessibilityValue(viewModel.email.isEmpty ? "Empty" : viewModel.email)
                        .accessibilityHint("Enter the email address for your Cinnamon Companion account")
                        .onSubmit {
                            focusedField = .password
                        }
                }

                VStack(alignment: .leading, spacing: AppSpacing.small) {
                    Text("Password")
                        .font(AppTypography.headline)
                        .foregroundStyle(AppColors.primaryText)

                    SecureField("Enter your password", text: $viewModel.password)
                        .textFieldStyle(AppTextFieldStyle())
                        .textContentType(.password)
                        .submitLabel(.go)
                        .focused($focusedField, equals: .password)
                        .accessibilityLabel("Password")
                        .accessibilityValue(viewModel.password.isEmpty ? "Empty" : "Entered")
                        .accessibilityHint("Enter your account password")
                        .onSubmit {
                            if viewModel.canSignIn {
                                submitAuthentication()
                            }
                        }
                }

                if viewModel.mode == .signIn {
                    Button("Forgot Password?") {
                    }
                    .font(AppTypography.bodyEmphasized)
                    .foregroundStyle(AppColors.brandBrown)
                    .frame(minHeight: AppSpacing.minimumTouchTarget, alignment: .leading)
                    .contentShape(Rectangle())
                    .accessibilityHint("Opens password recovery when connected to your authentication service")
                }
            }
        }
    }

    private var actionsSection: some View {
        VStack(spacing: AppSpacing.large) {
            if authViewModel.isLoading {
                ProgressView("Authenticating...")
                    .tint(AppColors.brandBrown)
                    .font(AppTypography.body)
                    .accessibilityLabel("Authentication in progress")
            }

            if let successMessage = authViewModel.lastSuccessMessage {
                Text(successMessage)
                    .font(AppTypography.footnote)
                    .foregroundStyle(AppColors.brandBrown)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityLabel("Authentication status: \(successMessage)")
            }

            if let errorMessage = authViewModel.errorMessage {
                Text(errorMessage)
                    .font(AppTypography.footnote)
                    .foregroundStyle(.red.opacity(0.85))
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityLabel("Authentication error: \(errorMessage)")
            }

            if let biometricErrorMessage = viewModel.biometricErrorMessage {
                Text(biometricErrorMessage)
                    .font(AppTypography.footnote)
                    .foregroundStyle(AppColors.brandBrown)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityLabel("Biometric sign in message: \(biometricErrorMessage)")
            }

            PrimaryButton(title: viewModel.primaryActionTitle, systemImage: viewModel.primaryActionSystemImage) {
                submitAuthentication()
            }
            .disabled(!viewModel.canSignIn || authViewModel.isLoading)
            .opacity(viewModel.canSignIn && !authViewModel.isLoading ? 1 : 0.55)
            .accessibilityLabel("\(viewModel.primaryActionTitle) with email and password")
            .accessibilityHint(viewModel.canSignIn ? "Submits your credentials and continues into the app" : "Enter both email and password to continue")

            if viewModel.shouldShowBiometricButton {
                Button {
                    Task {
                        _ = await viewModel.authenticateWithBiometrics(using: authViewModel)
                    }
                } label: {
                    HStack(spacing: AppSpacing.small) {
                        Image(systemName: viewModel.biometricKind.systemImageName)
                            .font(.title3)

                        Text(viewModel.biometricButtonTitle)
                            .font(AppTypography.button)
                    }
                    .foregroundStyle(AppColors.brandBrown)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: AppSpacing.minimumTouchTarget)
                    .background(AppColors.surfaceCream.opacity(0.96))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppSpacing.buttonCornerRadius, style: .continuous)
                            .stroke(AppColors.border, lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: AppSpacing.buttonCornerRadius, style: .continuous))
                }
                .buttonStyle(.plain)
                .accessibilityLabel(viewModel.biometricButtonTitle)
                .accessibilityHint("Signs in with biometric authentication")
                .disabled(authViewModel.isLoading)
            }

            Button {
                Task {
                    _ = await authViewModel.continueAsGuest()
                }
            } label: {
                Text("Continue as Guest")
                    .font(AppTypography.bodyEmphasized)
                    .foregroundStyle(AppColors.primaryText)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: AppSpacing.minimumTouchTarget)
            }
            .background(AppColors.accentGoldSoft.opacity(0.35))
            .clipShape(RoundedRectangle(cornerRadius: AppSpacing.buttonCornerRadius, style: .continuous))
            .buttonStyle(.plain)
            .accessibilityLabel("Continue as guest")
            .accessibilityHint("Enter the app without signing in")
            .disabled(authViewModel.isLoading)
            .opacity(authViewModel.isLoading ? 0.55 : 1)

            ViewThatFits(in: .horizontal) {
                HStack(spacing: AppSpacing.small) {
                    Text(viewModel.mode.switchPrompt)
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.secondaryText)

                    modeSwitchButton
                }

                VStack(alignment: .center, spacing: AppSpacing.xSmall) {
                    Text(viewModel.mode.switchPrompt)
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.secondaryText)

                    modeSwitchButton
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var modeSwitchButton: some View {
        Button(viewModel.mode.switchActionTitle) {
            authViewModel.clearTransientMessages()
            viewModel.toggleMode()
        }
        .font(AppTypography.bodyEmphasized)
        .foregroundStyle(AppColors.brandBrown)
        .frame(minHeight: AppSpacing.minimumTouchTarget)
        .contentShape(Rectangle())
        .accessibilityHint("Switches authentication mode")
    }

    private func submitAuthentication() {
        authViewModel.clearTransientMessages()
        viewModel.biometricErrorMessage = nil

        Task {
            switch viewModel.mode {
            case .signIn:
                _ = await authViewModel.signIn(
                    email: viewModel.email,
                    password: viewModel.password
                )
            case .signUp:
                _ = await authViewModel.signUp(
                    email: viewModel.email,
                    password: viewModel.password
                )
            }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}
