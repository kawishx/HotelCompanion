//
//  AppTextFieldStyle.swift
//  HotelCompanion
//
//  File: Core/Components/AppTextFieldStyle.swift
//

import SwiftUI

struct AppTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(AppTypography.body)
            .foregroundStyle(AppColors.primaryText)
            .padding(.horizontal, AppSpacing.large)
            .padding(.vertical, AppSpacing.small)
            .frame(minHeight: AppSpacing.minimumTouchTarget)
            .background(AppColors.surfaceCream.opacity(0.96))
            .overlay(
                RoundedRectangle(cornerRadius: AppSpacing.buttonCornerRadius, style: .continuous)
                    .stroke(AppColors.border, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: AppSpacing.buttonCornerRadius, style: .continuous))
            .shadow(color: AppColors.shadow.opacity(0.55), radius: 4, y: 1)
    }
}
