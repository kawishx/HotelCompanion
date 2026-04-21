//
//  OnboardingView.swift
//  HotelCompanion
//
//  File: Features/Auth/Views/OnboardingView.swift
//

import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel: OnboardingViewModel
    let onComplete: () -> Void

    init(
        viewModel: OnboardingViewModel = OnboardingViewModel(),
        onComplete: @escaping () -> Void
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onComplete = onComplete
    }

    var body: some View {
        ZStack {
            AuthBackgroundView()

            VStack(spacing: AppSpacing.xLarge) {
                HStack {
                    Text("Welcome")
                        .font(AppTypography.headline)
                        .foregroundStyle(AppColors.secondaryText)

                    Spacer()

                    Button("Skip") {
                        onComplete()
                    }
                    .font(AppTypography.bodyEmphasized)
                    .foregroundStyle(AppColors.brandBrown)
                    .frame(minHeight: AppSpacing.minimumTouchTarget)
                    .accessibilityLabel("Skip onboarding")
                }
                .padding(.horizontal, AppSpacing.screenPadding)
                .padding(.top, AppSpacing.large)

                TabView(selection: $viewModel.selectedIndex) {
                    ForEach(Array(viewModel.pages.enumerated()), id: \.element.id) { index, page in
                        OnboardingPageCard(page: page)
                            .padding(.horizontal, AppSpacing.screenPadding)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .accessibilityLabel("Onboarding pages")

                VStack(spacing: AppSpacing.large) {
                    HStack(spacing: AppSpacing.small) {
                        ForEach(Array(viewModel.pages.enumerated()), id: \.element.id) { index, _ in
                            Capsule()
                                .fill(index == viewModel.selectedIndex ? AppColors.brandBrown : AppColors.border)
                                .frame(width: index == viewModel.selectedIndex ? 28 : 10, height: 10)
                                .animation(.easeInOut(duration: 0.25), value: viewModel.selectedIndex)
                        }
                    }
                    .accessibilityElement()
                    .accessibilityLabel("Page \(viewModel.selectedIndex + 1) of \(viewModel.pages.count)")

                    PrimaryButton(
                        title: viewModel.isLastPage ? "Continue to Sign In" : "Next",
                        systemImage: viewModel.isLastPage ? "arrow.right.circle.fill" : "arrow.right"
                    ) {
                        if viewModel.isLastPage {
                            onComplete()
                        } else {
                            viewModel.advance()
                        }
                    }
                    .padding(.horizontal, AppSpacing.screenPadding)
                    .accessibilityLabel(viewModel.isLastPage ? "Continue to sign in" : "Go to next onboarding page")
                }
                .padding(.bottom, AppSpacing.xxLarge)
            }
        }
    }
}

private struct OnboardingPageCard: View {
    let page: OnboardingPage

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xLarge) {
            Spacer(minLength: 0)

            ZStack {
                RoundedRectangle(cornerRadius: 34, style: .continuous)
                    .fill(AppColors.brandBrownDeep)
                    .frame(width: 140, height: 140)

                RoundedRectangle(cornerRadius: 40, style: .continuous)
                    .stroke(AppColors.accentGoldSoft, lineWidth: 2)
                    .frame(width: 160, height: 160)

                Image(systemName: page.systemImage)
                    .font(.system(size: 56, weight: .medium))
                    .foregroundStyle(AppColors.accentGoldSoft)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .accessibilityHidden(true)

            SectionCard(title: page.title, subtitle: page.subtitle) {
                Text(page.detail)
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .accessibilityElement(children: .combine)

            Spacer(minLength: AppSpacing.large)
        }
        .padding(.vertical, AppSpacing.large)
    }
}

#Preview {
    OnboardingView { }
}

