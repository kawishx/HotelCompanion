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
            .frame(minHeight: AppSpacing.minimumTouchTarget)
            .background(AppColors.surfaceCream.opacity(0.96))
            .overlay(
                RoundedRectangle(cornerRadius: AppSpacing.buttonCornerRadius, style: .continuous)
                    .stroke(AppColors.border, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: AppSpacing.buttonCornerRadius, style: .continuous))
    }
}

