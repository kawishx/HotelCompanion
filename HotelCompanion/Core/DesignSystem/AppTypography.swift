//
//  AppTypography.swift
//  HotelCompanion
//
//  File: Core/DesignSystem/AppTypography.swift
//

import SwiftUI

enum AppTypography {
    static let display = Font.system(.largeTitle, design: .serif).weight(.bold)
    static let title = Font.system(.title2, design: .serif).weight(.semibold)
    static let sectionTitle = Font.system(.title3, design: .default).weight(.semibold)
    static let headline = Font.system(.headline, design: .default).weight(.semibold)
    static let body = Font.system(.body, design: .default)
    static let bodyEmphasized = Font.system(.body, design: .default).weight(.medium)
    static let footnote = Font.system(.footnote, design: .default)
    static let button = Font.system(.headline, design: .default).weight(.semibold)
}

