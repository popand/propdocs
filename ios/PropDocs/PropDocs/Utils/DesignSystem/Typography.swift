//
//  Typography.swift
//  PropDocs
//
//  SwiftUI Design System - Typography
//  Based on ios-design-system.css
//

import SwiftUI

// MARK: - Font Extensions

extension Font {
    
    // MARK: - Typography Scale (based on iOS Human Interface Guidelines)
    
    static let largeTitle = Font.largeTitle // 34px
    static let title1 = Font.title // 28px
    static let title2 = Font.title2 // 22px
    static let title3 = Font.title3 // 20px
    static let headline = Font.headline // 17px
    static let body = Font.body // 17px
    static let callout = Font.callout // 16px
    static let subheadline = Font.subheadline // 15px
    static let footnote = Font.footnote // 13px
    static let caption = Font.caption // 12px
    static let caption2 = Font.caption2 // 11px
    
    // MARK: - Custom Font Weights
    
    static func largeTitle(_ weight: Font.Weight = .regular) -> Font {
        return Font.largeTitle.weight(weight)
    }
    
    static func title1(_ weight: Font.Weight = .bold) -> Font {
        return Font.title.weight(weight)
    }
    
    static func title2(_ weight: Font.Weight = .bold) -> Font {
        return Font.title2.weight(weight)
    }
    
    static func title3(_ weight: Font.Weight = .semibold) -> Font {
        return Font.title3.weight(weight)
    }
    
    static func headline(_ weight: Font.Weight = .semibold) -> Font {
        return Font.headline.weight(weight)
    }
    
    static func body(_ weight: Font.Weight = .regular) -> Font {
        return Font.body.weight(weight)
    }
    
    static func callout(_ weight: Font.Weight = .regular) -> Font {
        return Font.callout.weight(weight)
    }
    
    static func subheadline(_ weight: Font.Weight = .regular) -> Font {
        return Font.subheadline.weight(weight)
    }
    
    static func footnote(_ weight: Font.Weight = .regular) -> Font {
        return Font.footnote.weight(weight)
    }
    
    static func caption(_ weight: Font.Weight = .regular) -> Font {
        return Font.caption.weight(weight)
    }
    
    static func caption2(_ weight: Font.Weight = .regular) -> Font {
        return Font.caption2.weight(weight)
    }
}

// MARK: - Typography Styles

struct TypographyStyles {
    
    struct LargeTitle: ViewModifier {
        func body(content: Content) -> some View {
            content
                .font(.largeTitle(.regular))
                .lineLimit(nil)
        }
    }
    
    struct Title1: ViewModifier {
        func body(content: Content) -> some View {
            content
                .font(.title1(.bold))
                .lineLimit(nil)
        }
    }
    
    struct Title2: ViewModifier {
        func body(content: Content) -> some View {
            content
                .font(.title2(.bold))
                .lineLimit(nil)
        }
    }
    
    struct Title3: ViewModifier {
        func body(content: Content) -> some View {
            content
                .font(.title3(.semibold))
                .lineLimit(nil)
        }
    }
    
    struct Headline: ViewModifier {
        func body(content: Content) -> some View {
            content
                .font(.headline(.semibold))
                .lineLimit(nil)
        }
    }
    
    struct Body: ViewModifier {
        func body(content: Content) -> some View {
            content
                .font(.body(.regular))
                .lineLimit(nil)
        }
    }
    
    struct Callout: ViewModifier {
        func body(content: Content) -> some View {
            content
                .font(.callout(.regular))
                .lineLimit(nil)
        }
    }
    
    struct Subheadline: ViewModifier {
        func body(content: Content) -> some View {
            content
                .font(.subheadline(.regular))
                .lineLimit(nil)
        }
    }
    
    struct Footnote: ViewModifier {
        func body(content: Content) -> some View {
            content
                .font(.footnote(.regular))
                .lineLimit(nil)
        }
    }
    
    struct Caption: ViewModifier {
        func body(content: Content) -> some View {
            content
                .font(.caption(.regular))
                .lineLimit(nil)
        }
    }
    
    struct Caption2: ViewModifier {
        func body(content: Content) -> some View {
            content
                .font(.caption2(.regular))
                .lineLimit(nil)
        }
    }
}

// MARK: - View Extensions

extension View {
    
    func largeTitle() -> some View {
        modifier(TypographyStyles.LargeTitle())
    }
    
    func title1() -> some View {
        modifier(TypographyStyles.Title1())
    }
    
    func title2() -> some View {
        modifier(TypographyStyles.Title2())
    }
    
    func title3() -> some View {
        modifier(TypographyStyles.Title3())
    }
    
    func headline() -> some View {
        modifier(TypographyStyles.Headline())
    }
    
    func bodyText() -> some View {
        modifier(TypographyStyles.Body())
    }
    
    func callout() -> some View {
        modifier(TypographyStyles.Callout())
    }
    
    func subheadline() -> some View {
        modifier(TypographyStyles.Subheadline())
    }
    
    func footnote() -> some View {
        modifier(TypographyStyles.Footnote())
    }
    
    func caption() -> some View {
        modifier(TypographyStyles.Caption())
    }
    
    func caption2() -> some View {
        modifier(TypographyStyles.Caption2())
    }
}