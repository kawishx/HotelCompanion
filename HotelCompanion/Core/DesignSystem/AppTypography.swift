//
//  AppTypography.swift
//  HotelCompanion
//
//  File: Core/DesignSystem/AppTypography.swift
//

import SwiftUI

enum AppTypography {
    static let display = Font.system(.largeTitle, design: .serif).weight(.bold)
    static let navigationTitle = Font.system(.largeTitle, design: .serif).weight(.semibold)
    static let title = Font.system(.title2, design: .serif).weight(.semibold)
    static let sectionTitle = Font.system(.title3, design: .default).weight(.semibold)
    static let sectionSubtitle = Font.system(.footnote, design: .default).weight(.medium)
    static let headline = Font.system(.headline, design: .default).weight(.semibold)
    static let body = Font.system(.body, design: .default)
    static let bodyEmphasized = Font.system(.body, design: .default).weight(.medium)
    static let footnote = Font.system(.footnote, design: .default)
    static let label = Font.system(.subheadline, design: .default).weight(.semibold)
    static let chip = Font.system(.footnote, design: .default).weight(.semibold)
    static let button = Font.system(.headline, design: .default).weight(.semibold)
}
