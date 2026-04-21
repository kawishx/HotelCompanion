//
//  SplashView.swift
//  HotelCompanion
//
//  File: Features/Auth/Views/SplashView.swift
//

import SwiftUI

struct SplashView: View {
    @StateObject private var viewModel: SplashViewModel
    let onFinish: () -> Void

    init(
        viewModel: SplashViewModel = SplashViewModel(),
        onFinish: @escaping () -> Void
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onFinish = onFinish
    }

    var body: some View {
        ZStack {
            AuthBackgroundView()

            VStack(spacing: AppSpacing.xLarge) {
                Spacer()

                VStack(spacing: AppSpacing.large) {
                    ZStack {
                        Circle()
                            .fill(AppColors.brandBrownDeep)
                            .frame(width: 108, height: 108)

                        Circle()
                            .stroke(AppColors.accentGoldSoft, lineWidth: 2)
                            .frame(width: 124, height: 124)

                        Image(systemName: "building.2.crop.circle.fill")
                            .font(.system(size: 48, weight: .medium))
                            .foregroundStyle(AppColors.accentGoldSoft)
                    }
                    .accessibilityHidden(true)

                    VStack(spacing: AppSpacing.small) {
                        Text(viewModel.brandTitle)
                            .font(AppTypography.display)
                            .foregroundStyle(AppColors.primaryText)
                            .multilineTextAlignment(.center)
                            .accessibilityAddTraits(.isHeader)

                        Text(viewModel.brandSubtitle)
                            .font(AppTypography.bodyEmphasized)
                            .foregroundStyle(AppColors.secondaryText)
                            .multilineTextAlignment(.center)

                        Text(viewModel.tagline)
                            .font(AppTypography.footnote)
                            .foregroundStyle(AppColors.secondaryText)
                            .multilineTextAlignment(.center)
                    }
                }

                Spacer()

                ProgressView()
                    .tint(AppColors.brandBrown)
                    .scaleEffect(1.1)
                    .accessibilityLabel("Loading Cinnamon Companion")

                Spacer()
            }
            .padding(AppSpacing.xxLarge)
        }
        .task {
            try? await Task.sleep(for: .seconds(1.8))
            guard !Task.isCancelled else { return }
            onFinish()
        }
    }
}

#Preview {
    SplashView { }
}

