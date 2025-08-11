//
//  Spacing.swift
//  PropDocs
//
//  SwiftUI Design System - Spacing
//  Based on ios-design-system.css (8pt grid system)
//

import SwiftUI

// MARK: - Spacing Constants

struct Spacing {
    
    // 8pt grid system based on iOS design guidelines
    static let xs: CGFloat = 4      // Extra small
    static let sm: CGFloat = 8      // Small
    static let md: CGFloat = 16     // Medium (base unit)
    static let lg: CGFloat = 24     // Large
    static let xl: CGFloat = 32     // Extra large
    static let xxl: CGFloat = 48    // 2x Extra large
    static let xxxl: CGFloat = 64   // 3x Extra large
    
    // Common specific spacing values
    static let navigationBarHeight: CGFloat = 52
    static let tabBarHeight: CGFloat = 83
    static let buttonHeight: CGFloat = 44
    
    // Card and layout spacing
    static let cardPadding: CGFloat = md
    static let sectionSpacing: CGFloat = lg
    static let listItemSpacing: CGFloat = md
}

// MARK: - Border Radius

struct CornerRadius {
    
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 20
    static let pill: CGFloat = 999  // For fully rounded buttons/pills
    
    // Specific component radius
    static let button: CGFloat = md
    static let card: CGFloat = md
    static let searchBar: CGFloat = sm
    static let badge: CGFloat = 10
}

// MARK: - Shadow

struct Shadow {
    
    static let sm = (radius: CGFloat(1), x: CGFloat(0), y: CGFloat(1))
    static let md = (radius: CGFloat(3), x: CGFloat(0), y: CGFloat(4))
    static let lg = (radius: CGFloat(8), x: CGFloat(0), y: CGFloat(10))
    
    // Card shadows
    static let card = md
    static let fab = lg  // Floating Action Button
}

// MARK: - View Modifiers

struct SpacingModifiers {
    
    struct PaddingXS: ViewModifier {
        func body(content: Content) -> some View {
            content.padding(Spacing.xs)
        }
    }
    
    struct PaddingSM: ViewModifier {
        func body(content: Content) -> some View {
            content.padding(Spacing.sm)
        }
    }
    
    struct PaddingMD: ViewModifier {
        func body(content: Content) -> some View {
            content.padding(Spacing.md)
        }
    }
    
    struct PaddingLG: ViewModifier {
        func body(content: Content) -> some View {
            content.padding(Spacing.lg)
        }
    }
    
    struct PaddingXL: ViewModifier {
        func body(content: Content) -> some View {
            content.padding(Spacing.xl)
        }
    }
    
    struct CardPadding: ViewModifier {
        func body(content: Content) -> some View {
            content.padding(Spacing.cardPadding)
        }
    }
    
    struct ListItemPadding: ViewModifier {
        func body(content: Content) -> some View {
            content.padding(.horizontal, Spacing.md)
                   .padding(.vertical, Spacing.md)
        }
    }
}

// MARK: - Corner Radius Modifiers

struct CornerRadiusModifiers {
    
    struct SmallCorners: ViewModifier {
        func body(content: Content) -> some View {
            content.clipShape(RoundedRectangle(cornerRadius: CornerRadius.sm))
        }
    }
    
    struct MediumCorners: ViewModifier {
        func body(content: Content) -> some View {
            content.clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
        }
    }
    
    struct LargeCorners: ViewModifier {
        func body(content: Content) -> some View {
            content.clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg))
        }
    }
    
    struct CardCorners: ViewModifier {
        func body(content: Content) -> some View {
            content.clipShape(RoundedRectangle(cornerRadius: CornerRadius.card))
        }
    }
    
    struct ButtonCorners: ViewModifier {
        func body(content: Content) -> some View {
            content.clipShape(RoundedRectangle(cornerRadius: CornerRadius.button))
        }
    }
    
    struct PillCorners: ViewModifier {
        func body(content: Content) -> some View {
            content.clipShape(Capsule())
        }
    }
}

// MARK: - Shadow Modifiers

struct ShadowModifiers {
    
    struct SmallShadow: ViewModifier {
        func body(content: Content) -> some View {
            content.shadow(radius: Shadow.sm.radius, x: Shadow.sm.x, y: Shadow.sm.y)
        }
    }
    
    struct MediumShadow: ViewModifier {
        func body(content: Content) -> some View {
            content.shadow(radius: Shadow.md.radius, x: Shadow.md.x, y: Shadow.md.y)
        }
    }
    
    struct LargeShadow: ViewModifier {
        func body(content: Content) -> some View {
            content.shadow(radius: Shadow.lg.radius, x: Shadow.lg.x, y: Shadow.lg.y)
        }
    }
    
    struct CardShadow: ViewModifier {
        func body(content: Content) -> some View {
            content.shadow(radius: Shadow.card.radius, x: Shadow.card.x, y: Shadow.card.y)
        }
    }
}

// MARK: - View Extensions

extension View {
    
    // Padding
    func paddingXS() -> some View {
        modifier(SpacingModifiers.PaddingXS())
    }
    
    func paddingSM() -> some View {
        modifier(SpacingModifiers.PaddingSM())
    }
    
    func paddingMD() -> some View {
        modifier(SpacingModifiers.PaddingMD())
    }
    
    func paddingLG() -> some View {
        modifier(SpacingModifiers.PaddingLG())
    }
    
    func paddingXL() -> some View {
        modifier(SpacingModifiers.PaddingXL())
    }
    
    func cardPadding() -> some View {
        modifier(SpacingModifiers.CardPadding())
    }
    
    func listItemPadding() -> some View {
        modifier(SpacingModifiers.ListItemPadding())
    }
    
    // Corner Radius
    func smallCorners() -> some View {
        modifier(CornerRadiusModifiers.SmallCorners())
    }
    
    func mediumCorners() -> some View {
        modifier(CornerRadiusModifiers.MediumCorners())
    }
    
    func largeCorners() -> some View {
        modifier(CornerRadiusModifiers.LargeCorners())
    }
    
    func cardCorners() -> some View {
        modifier(CornerRadiusModifiers.CardCorners())
    }
    
    func buttonCorners() -> some View {
        modifier(CornerRadiusModifiers.ButtonCorners())
    }
    
    func pillCorners() -> some View {
        modifier(CornerRadiusModifiers.PillCorners())
    }
    
    // Shadows
    func smallShadow() -> some View {
        modifier(ShadowModifiers.SmallShadow())
    }
    
    func mediumShadow() -> some View {
        modifier(ShadowModifiers.MediumShadow())
    }
    
    func largeShadow() -> some View {
        modifier(ShadowModifiers.LargeShadow())
    }
    
    func cardShadow() -> some View {
        modifier(ShadowModifiers.CardShadow())
    }
}