//
//  PropDocsCard.swift
//  PropDocs
//
//  Common card component based on the design system
//

import SwiftUI

struct PropDocsCard<Content: View>: View {
    
    let content: () -> Content
    var padding: CGFloat = Spacing.md
    var backgroundColor: Color = PropDocsColors.groupedBackgroundSecondary
    var cornerRadius: CGFloat = CornerRadius.card
    var showShadow: Bool = true
    
    init(
        padding: CGFloat = Spacing.md,
        backgroundColor: Color = PropDocsColors.groupedBackgroundSecondary,
        cornerRadius: CGFloat = CornerRadius.card,
        showShadow: Bool = true,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.padding = padding
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.showShadow = showShadow
        self.content = content
    }
    
    var body: some View {
        content()
            .padding(padding)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .conditionalModifier(showShadow) { view in
                view.shadow(
                    color: .black.opacity(0.1),
                    radius: Shadow.card.radius,
                    x: Shadow.card.x,
                    y: Shadow.card.y
                )
            }
    }
}

// MARK: - Card Header Component

struct PropDocsCardHeader: View {
    
    let title: String
    let subtitle: String?
    let action: (() -> Void)?
    let actionTitle: String?
    
    init(
        title: String,
        subtitle: String? = nil,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(title)
                    .font(.headline(.semibold))
                    .foregroundColor(PropDocsColors.labelPrimary)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.subheadline(.regular))
                        .foregroundColor(PropDocsColors.labelSecondary)
                }
            }
            
            Spacer()
            
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.subheadline(.medium))
                        .foregroundColor(.propDocsBlue)
                }
            }
        }
    }
}

// MARK: - Conditional Modifier Helper

extension View {
    @ViewBuilder
    func conditionalModifier<Content: View>(
        _ condition: Bool,
        modifier: (Self) -> Content
    ) -> some View {
        if condition {
            modifier(self)
        } else {
            self
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: Spacing.md) {
        PropDocsCard {
            PropDocsCardHeader(
                title: "Sample Card",
                subtitle: "This is a subtitle"
            )
        }
        
        PropDocsCard {
            PropDocsCardHeader(
                title: "Card with Action",
                subtitle: "This card has an action button",
                actionTitle: "View All"
            ) {
                print("Action tapped")
            }
        }
        
        PropDocsCard(showShadow: false) {
            VStack(alignment: .leading) {
                Text("No Shadow Card")
                    .font(.headline(.semibold))
                Text("This card has no shadow")
                    .font(.caption(.regular))
                    .foregroundColor(PropDocsColors.labelSecondary)
            }
        }
    }
    .padding()
    .background(PropDocsColors.groupedBackgroundPrimary)
}