//
//  StatusChip.swift
//  HotelCompanion
//
//  File: Core/Components/StatusChip.swift
//

import SwiftUI

struct StatusChip: View {
    enum Size {
        case compact
        case regular

        var horizontalPadding: CGFloat {
            switch self {
            case .compact:
                return AppSpacing.small
            case .regular:
                return AppSpacing.medium
            }
        }

        var verticalPadding: CGFloat {
            switch self {
            case .compact:
                return AppSpacing.xSmall
            case .regular:
                return AppSpacing.small
            }
        }

        var minHeight: CGFloat {
            switch self {
            case .compact:
                return 28
            case .regular:
                return AppSpacing.minimumTouchTarget
            }
        }
    }

    enum Tone {
        case neutral
        case accent
        case success
        case alert

        var foregroundColor: Color {
            switch self {
            case .neutral:
                return AppColors.primaryText
            case .accent:
                return AppColors.brandBrown
            case .success:
                return AppColors.successGreen
            case .alert:
                return AppColors.errorRed
            }
        }

        var backgroundColor: Color {
            switch self {
            case .neutral:
                return AppColors.surfaceWarm.opacity(0.35)
            case .accent:
                return AppColors.accentGoldSoft.opacity(0.35)
            case .success:
                return AppColors.successSurface
            case .alert:
                return AppColors.errorSurface
            }
        }

        var borderColor: Color {
            switch self {
            case .neutral:
                return AppColors.border
            case .accent:
                return AppColors.accentGoldSoft
            case .success:
                return AppColors.successGreen.opacity(0.25)
            case .alert:
                return AppColors.errorRed.opacity(0.25)
            }
        }
    }

    let title: String
    var systemImage: String?
    var tone: Tone = .neutral
    var size: Size = .regular

    var body: some View {
        HStack(spacing: AppSpacing.small) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(.subheadline)
                    .accessibilityHidden(true)
            }

            Text(title)
                .font(AppTypography.chip)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .foregroundStyle(tone.foregroundColor)
        .padding(.horizontal, size.horizontalPadding)
        .padding(.vertical, size.verticalPadding)
        .frame(minHeight: size.minHeight)
        .background(tone.backgroundColor)
        .overlay(
            RoundedRectangle(cornerRadius: AppSpacing.chipCornerRadius, style: .continuous)
                .stroke(tone.borderColor, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: AppSpacing.chipCornerRadius, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
    }
}

#Preview {
    VStack(spacing: 12) {
        StatusChip(title: "Confirmed", systemImage: "checkmark.circle.fill", tone: .success)
        StatusChip(title: "Awaiting confirmation", systemImage: "clock.fill", tone: .accent)
    }
    .padding()
    .background(AppColors.backgroundCream)
}
