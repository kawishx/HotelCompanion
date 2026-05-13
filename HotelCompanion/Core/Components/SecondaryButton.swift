//
//  SecondaryButton.swift
//  HotelCompanion
//
//  File: Core/Components/SecondaryButton.swift
//

import SwiftUI

struct SecondaryButton: View {
    let title: String
    var systemImage: String?
    var alignment: Alignment = .center
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.small) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.headline)
                        .accessibilityHidden(true)
                }

                Text(title)
                    .font(AppTypography.button)
                    .multilineTextAlignment(alignment == .leading ? .leading : .center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .foregroundStyle(AppColors.brandBrown)
            .frame(maxWidth: .infinity, alignment: alignment)
            .frame(minHeight: AppSpacing.minimumTouchTarget)
            .padding(.horizontal, AppSpacing.large)
            .background(AppColors.surfaceCream.opacity(0.98))
            .overlay(
                RoundedRectangle(cornerRadius: AppSpacing.buttonCornerRadius, style: .continuous)
                    .stroke(AppColors.border, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: AppSpacing.buttonCornerRadius, style: .continuous))
            .shadow(color: AppColors.shadow, radius: 6, y: 2)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .accessibilityHint("Activates \(title.lowercased())")
    }
}

#Preview {
    SecondaryButton(title: "Open Digital Check-In", systemImage: "doc.text.viewfinder", alignment: .leading) { }
        .padding()
        .background(AppColors.backgroundCream)
}
