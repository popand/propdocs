//
//  PropDocsButton.swift
//  PropDocs
//
//  Common button components based on the design system
//

import SwiftUI

// MARK: - Button Styles

enum PropDocsButtonStyle {
    case primary
    case secondary
    case destructive
    case ghost
}

enum PropDocsButtonSize {
    case small
    case compact
    case medium
    case large
    
    var height: CGFloat {
        switch self {
        case .small: return 32
        case .compact: return 36
        case .medium: return 44
        case .large: return 56
        }
    }
    
    var fontSize: Font {
        switch self {
        case .small: return .footnote(.medium)
        case .compact: return .footnote(.semibold)
        case .medium: return .body(.semibold)
        case .large: return .headline(.semibold)
        }
    }
    
    var horizontalPadding: CGFloat {
        switch self {
        case .small: return Spacing.md
        case .compact: return Spacing.md
        case .medium: return Spacing.lg
        case .large: return Spacing.xl
        }
    }
}

// MARK: - PropDocs Button

struct PropDocsButton: View {
    
    let title: String
    let style: PropDocsButtonStyle
    let size: PropDocsButtonSize
    let action: () -> Void
    let isLoading: Bool
    let isDisabled: Bool
    
    init(
        _ title: String,
        style: PropDocsButtonStyle = .primary,
        size: PropDocsButtonSize = .medium,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.style = style
        self.size = size
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.sm) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: textColor))
                        .scaleEffect(0.8)
                } else {
                    Text(title)
                        .font(size.fontSize)
                        .fontWeight(.semibold)
                }
            }
            .foregroundColor(textColor)
            .frame(height: size.height)
            .padding(.horizontal, size.horizontalPadding)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.button))
            .opacity(isDisabled || isLoading ? 0.6 : 1.0)
        }
        .disabled(isDisabled || isLoading)
    }
    
    private var backgroundColor: Color {
        switch style {
        case .primary:
            return .propDocsBlue
        case .secondary:
            return PropDocsColors.fillSecondary
        case .destructive:
            return .propDocsRed
        case .ghost:
            return .clear
        }
    }
    
    private var textColor: Color {
        switch style {
        case .primary, .destructive:
            return .white
        case .secondary:
            return PropDocsColors.labelPrimary
        case .ghost:
            return .propDocsBlue
        }
    }
}

// MARK: - Floating Action Button

struct FloatingActionButton: View {
    
    let systemImage: String
    let action: () -> Void
    
    init(
        systemImage: String = "plus",
        action: @escaping () -> Void
    ) {
        self.systemImage = systemImage
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.title2(.semibold))
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(.propDocsBlue)
                .clipShape(Circle())
                .shadow(
                    color: .black.opacity(0.2),
                    radius: Shadow.lg.radius,
                    x: Shadow.lg.x,
                    y: Shadow.lg.y
                )
        }
        .scaleEffect(1.0)
        .animation(.easeInOut(duration: 0.1), value: true)
        .buttonStyle(FabButtonStyle())
    }
}

// MARK: - FAB Button Style

struct FabButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Icon Button

struct IconButton: View {
    
    let systemImage: String
    let action: () -> Void
    let size: CGFloat
    let tintColor: Color
    
    init(
        systemImage: String,
        size: CGFloat = 24,
        tintColor: Color = PropDocsColors.labelSecondary,
        action: @escaping () -> Void
    ) {
        self.systemImage = systemImage
        self.size = size
        self.tintColor = tintColor
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: size, weight: .medium))
                .foregroundColor(tintColor)
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: Spacing.lg) {
        // Primary buttons
        VStack(spacing: Spacing.md) {
            PropDocsButton("Primary Button") {
                print("Primary tapped")
            }
            
            PropDocsButton("Loading", isLoading: true) {
                print("Loading tapped")
            }
            
            PropDocsButton("Disabled", isDisabled: true) {
                print("Disabled tapped")
            }
        }
        
        // Secondary and other styles
        HStack(spacing: Spacing.md) {
            PropDocsButton("Secondary", style: .secondary) {
                print("Secondary tapped")
            }
            
            PropDocsButton("Destructive", style: .destructive) {
                print("Destructive tapped")
            }
        }
        
        // Ghost button
        PropDocsButton("Ghost Button", style: .ghost) {
            print("Ghost tapped")
        }
        
        // Different sizes
        HStack(spacing: Spacing.md) {
            PropDocsButton("Small", size: .small) {
                print("Small tapped")
            }
            
            PropDocsButton("Medium", size: .medium) {
                print("Medium tapped")
            }
            
            PropDocsButton("Large", size: .large) {
                print("Large tapped")
            }
        }
        
        // Icon button and FAB
        HStack(spacing: Spacing.md) {
            IconButton(systemImage: "gear") {
                print("Settings tapped")
            }
            
            FloatingActionButton() {
                print("FAB tapped")
            }
        }
    }
    .padding()
    .background(PropDocsColors.groupedBackgroundPrimary)
}