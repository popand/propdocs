//
//  Colors.swift
//  PropDocs
//
//  SwiftUI Design System - Colors
//  Based on ios-design-system.css
//

import SwiftUI

extension Color {
    
    // MARK: - iOS Color System
    static let propDocsBlue = Color(red: 0/255, green: 122/255, blue: 255/255) // #007AFF
    static let propDocsGreen = Color(red: 52/255, green: 199/255, blue: 89/255) // #34C759
    static let propDocsOrange = Color(red: 255/255, green: 149/255, blue: 0/255) // #FF9500
    static let propDocsRed = Color(red: 255/255, green: 59/255, blue: 48/255) // #FF3B30
    static let propdocsPurple = Color(red: 175/255, green: 82/255, blue: 222/255) // #AF52DE
    static let propDocsTeal = Color(red: 90/255, green: 200/255, blue: 250/255) // #5AC8FA
    static let propDocsPink = Color(red: 255/255, green: 45/255, blue: 146/255) // #FF2D92
    static let propDocsIndigo = Color(red: 88/255, green: 86/255, blue: 214/255) // #5856D6
    
    // MARK: - System Colors (Light Mode)
    static let labelPrimary = Color.primary
    static let labelSecondary = Color(red: 60/255, green: 60/255, blue: 67/255, opacity: 0.6)
    static let labelTertiary = Color(red: 60/255, green: 60/255, blue: 67/255, opacity: 0.3)
    static let labelQuaternary = Color(red: 60/255, green: 60/255, blue: 67/255, opacity: 0.18)
    
    // MARK: - Fill Colors
    static let fillPrimary = Color(red: 120/255, green: 120/255, blue: 128/255, opacity: 0.2)
    static let fillSecondary = Color(red: 120/255, green: 120/255, blue: 128/255, opacity: 0.16)
    static let fillTertiary = Color(red: 120/255, green: 120/255, blue: 128/255, opacity: 0.12)
    static let fillQuaternary = Color(red: 120/255, green: 120/255, blue: 128/255, opacity: 0.08)
    
    // MARK: - Background Colors
    static let backgroundPrimary = Color(UIColor.systemBackground)
    static let backgroundSecondary = Color(UIColor.secondarySystemBackground)
    static let backgroundTertiary = Color(UIColor.tertiarySystemBackground)
    
    // MARK: - Grouped Background Colors
    static let groupedBackgroundPrimary = Color(UIColor.systemGroupedBackground)
    static let groupedBackgroundSecondary = Color(UIColor.secondarySystemGroupedBackground)
    static let groupedBackgroundTertiary = Color(UIColor.tertiarySystemGroupedBackground)
    
    // MARK: - Separator Colors
    static let separator = Color(UIColor.separator)
    static let opaqueSeparator = Color(UIColor.opaqueSeparator)
    
    // MARK: - Asset Status Colors
    static let statusGood = propDocsGreen
    static let statusWarning = propDocsOrange
    static let statusCritical = propDocsRed
    
    // MARK: - Priority Colors
    static let priorityHigh = propDocsRed
    static let priorityMedium = propDocsOrange
    static let priorityLow = propDocsBlue
    
    // MARK: - Category Colors
    static let categoryHVAC = propDocsOrange
    static let categoryPlumbing = propDocsBlue
    static let categoryElectrical = propdocsPurple
    static let categoryAppliances = propDocsGreen
    static let categorySecurity = propDocsRed
    static let categoryGeneral = labelSecondary
}

// MARK: - Dynamic Color Support

struct PropDocsColors {
    
    // Colors that adapt to light/dark mode automatically through UIColor
    static var labelPrimary: Color { Color(UIColor.label) }
    static var labelSecondary: Color { Color(UIColor.secondaryLabel) }
    static var labelTertiary: Color { Color(UIColor.tertiaryLabel) }
    static var labelQuaternary: Color { Color(UIColor.quaternaryLabel) }
    
    static var backgroundPrimary: Color { Color(UIColor.systemBackground) }
    static var backgroundSecondary: Color { Color(UIColor.secondarySystemBackground) }
    static var backgroundTertiary: Color { Color(UIColor.tertiarySystemBackground) }
    
    static var groupedBackgroundPrimary: Color { Color(UIColor.systemGroupedBackground) }
    static var groupedBackgroundSecondary: Color { Color(UIColor.secondarySystemGroupedBackground) }
    static var groupedBackgroundTertiary: Color { Color(UIColor.tertiarySystemGroupedBackground) }
    
    static var fillPrimary: Color { Color(UIColor.systemFill) }
    static var fillSecondary: Color { Color(UIColor.secondarySystemFill) }
    static var fillTertiary: Color { Color(UIColor.tertiarySystemFill) }
    static var fillQuaternary: Color { Color(UIColor.quaternarySystemFill) }
    
    static var separator: Color { Color(UIColor.separator) }
    static var opaqueSeparator: Color { Color(UIColor.opaqueSeparator) }
}