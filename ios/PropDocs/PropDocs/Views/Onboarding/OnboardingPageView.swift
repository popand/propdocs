//
//  OnboardingPageView.swift
//  PropDocs
//
//  Created by Andrei Pop on 2025-08-07.
//

import SwiftUI

struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Icon/Image section
            iconSection

            // Content section
            contentSection

            Spacer()
            Spacer() // Extra spacer to push content up slightly
        }
        .padding(.horizontal, 32)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(page.title). \(page.subtitle). \(page.description)")
    }

    // MARK: - Icon Section

    private var iconSection: some View {
        ZStack {
            // Background circle with gradient
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: page.iconColors),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 140, height: 140)
                .shadow(color: page.iconColors.first?.opacity(0.3) ?? .clear, radius: 20, x: 0, y: 10)

            // Icon
            Image(systemName: page.iconName)
                .font(.system(size: 60, weight: .light))
                .foregroundColor(.white)
        }
        .scaleEffect(1.0)
        .animation(.spring(response: 0.8, dampingFraction: 0.6), value: page.iconName)
    }

    // MARK: - Content Section

    private var contentSection: some View {
        VStack(spacing: 16) {
            // Title
            Text(page.title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)

            // Subtitle
            if !page.subtitle.isEmpty {
                Text(page.subtitle)
                    .font(.title2)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
            }

            // Description
            Text(page.description)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .lineSpacing(4)
                .padding(.horizontal, 8)

            // Features list (if available)
            if !page.features.isEmpty {
                featuresSection
                    .padding(.top, 8)
            }
        }
    }

    // MARK: - Features Section

    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(page.features, id: \.self) { feature in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.system(size: 16))
                        .padding(.top, 2)

                    Text(feature)
                        .font(.body)
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer()
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

// MARK: - OnboardingPage Model

struct OnboardingPage {
    let id: String
    let title: String
    let subtitle: String
    let description: String
    let iconName: String
    let iconColors: [Color]
    let features: [String]

    init(
        id: String,
        title: String,
        subtitle: String = "",
        description: String,
        iconName: String,
        iconColors: [Color],
        features: [String] = []
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.description = description
        self.iconName = iconName
        self.iconColors = iconColors
        self.features = features
    }
}

// MARK: - Sample Pages

extension OnboardingPage {
    static let welcome = OnboardingPage(
        id: "welcome",
        title: "Welcome to PropDocs",
        subtitle: "Your Property Management Partner",
        description: "Streamline your property maintenance, track assets, and keep everything organized in one place.",
        iconName: "house.fill",
        iconColors: [.blue, .purple]
    )

    static let assetManagement = OnboardingPage(
        id: "assets",
        title: "Asset Management",
        subtitle: "Track Everything That Matters",
        description: "Document and organize all your property assets with photos, specifications, and maintenance history.",
        iconName: "list.clipboard.fill",
        iconColors: [.green, .teal],
        features: [
            "Photo documentation with detailed records",
            "Asset categorization and search",
            "Condition tracking over time",
            "QR code labeling system",
        ]
    )

    static let maintenance = OnboardingPage(
        id: "maintenance",
        title: "Maintenance Tracking",
        subtitle: "Stay Ahead of Repairs",
        description: "Schedule, track, and manage maintenance tasks to keep your property in top condition.",
        iconName: "wrench.and.screwdriver.fill",
        iconColors: [.orange, .red],
        features: [
            "Smart scheduling with reminders",
            "Service provider management",
            "Cost tracking and budgeting",
            "Before and after photos",
        ]
    )

    static let reports = OnboardingPage(
        id: "reports",
        title: "Property Reports",
        subtitle: "Professional Documentation",
        description: "Generate comprehensive property reports for insurance, sales, or rental purposes.",
        iconName: "doc.text.fill",
        iconColors: [.purple, .pink],
        features: [
            "Customizable report templates",
            "Secure sharing with QR codes",
            "Privacy controls for sensitive data",
            "Export to PDF or web links",
        ]
    )
}

// MARK: - Preview

struct OnboardingPageView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Welcome page
            OnboardingPageView(page: .welcome)
                .previewDisplayName("Welcome Page")

            // Asset management page
            OnboardingPageView(page: .assetManagement)
                .previewDisplayName("Asset Management")

            // Maintenance page
            OnboardingPageView(page: .maintenance)
                .previewDisplayName("Maintenance")

            // Reports page - Dark mode
            OnboardingPageView(page: .reports)
                .preferredColorScheme(.dark)
                .previewDisplayName("Reports - Dark Mode")
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}
