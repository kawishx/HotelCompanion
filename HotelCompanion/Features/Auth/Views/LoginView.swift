//
//  LoginView.swift
//  HotelCompanion
//
//  File: Features/Auth/Views/LoginView.swift
//

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel: LoginViewModel
    @FocusState private var focusedField: Field?

    let onGuestContinue: () -> Void
    let onSignIn: () -> Void

    private enum Field {
        case email
        case password
    }

    init(
        viewModel: LoginViewModel = LoginViewModel(),
        onGuestContinue: @escaping () -> Void,
        onSignIn: @escaping () -> Void
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onGuestContinue = onGuestContinue
        self.onSignIn = onSignIn
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
    }

    private var heroSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            Text("Sign In")
                .font(AppTypography.display)
                .foregroundStyle(AppColors.primaryText)
                .accessibilityAddTraits(.isHeader)

            Text("Access your stay details, dining requests, and personalized travel moments.")
                .font(AppTypography.body)
                .foregroundStyle(AppColors.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
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
                        .onSubmit {
                            if viewModel.canSignIn {
                                onSignIn()
                            }
                        }
                }

                Button("Forgot Password?") {
                }
                .font(AppTypography.bodyEmphasized)
                .foregroundStyle(AppColors.brandBrown)
                .frame(minHeight: AppSpacing.minimumTouchTarget, alignment: .leading)
                .accessibilityHint("Opens password recovery when connected to your authentication service")
            }
        }
    }

    private var actionsSection: some View {
        VStack(spacing: AppSpacing.large) {
            PrimaryButton(title: "Sign In", systemImage: "arrow.right.circle.fill") {
                onSignIn()
            }
            .disabled(!viewModel.canSignIn)
            .opacity(viewModel.canSignIn ? 1 : 0.55)
            .accessibilityLabel("Sign in to Cinnamon Companion")

            Button {
            } label: {
                HStack(spacing: AppSpacing.small) {
                    Image(systemName: "faceid")
                        .font(.title3)

                    Text("Use Face ID / Touch ID")
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
            .accessibilityLabel("Use Face ID or Touch ID")
            .accessibilityHint("Biometric sign in placeholder")

            Button {
                onGuestContinue()
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
        }
    }
}

#Preview {
    LoginView(onGuestContinue: { }, onSignIn: { })
}

