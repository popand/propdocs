//
//  SettingsView.swift
//  PropDocs
//
//  Settings view based on settings.html prototype
//

import SwiftUI

struct SettingsView: View {
    
    @EnvironmentObject private var propertyViewModel: PropertyViewModel
    @State private var showingEditProfile = false
    @State private var notificationsEnabled = true
    @State private var darkModeEnabled = false
    @State private var showingSignOutAlert = false
    
    // Mock user data - in real app this would come from authentication manager
    private let mockUser = MockUser(
        initials: "AP",
        name: "Andrei Pop",
        email: "andrei.pop@example.com",
        propertiesCount: 2,
        assetsCount: 24,
        dueTasksCount: 7
    )
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.lg) {
                // Profile Section
                ProfileSectionView(user: mockUser, showingEditProfile: $showingEditProfile)
                
                // Account Settings
                SettingsSection(title: "Account") {
                    SettingsRowView(
                        title: "Profile",
                        subtitle: "Edit personal information",
                        systemImage: "person.circle",
                        iconColor: .propDocsBlue
                    ) {
                        showingEditProfile = true
                    }
                    
                    SettingsRowView(
                        title: "Properties",
                        subtitle: "Manage your properties",
                        systemImage: "house",
                        iconColor: .propDocsGreen,
                        accessoryText: "\(mockUser.propertiesCount) properties"
                    ) {
                        // Handle properties tap
                    }
                }
                
                // App Settings
                SettingsSection(title: "App Settings") {
                    SettingsToggleRow(
                        title: "Notifications",
                        subtitle: "Maintenance reminders & alerts",
                        systemImage: "bell",
                        iconColor: .propDocsRed,
                        isOn: $notificationsEnabled
                    )
                    
                    SettingsRowView(
                        title: "Privacy & Security",
                        subtitle: "Data sharing and permissions",
                        systemImage: "lock.shield",
                        iconColor: .propdocsPurple
                    ) {
                        // Handle privacy tap
                    }
                    
                    SettingsToggleRow(
                        title: "Dark Mode",
                        subtitle: "Follow system setting",
                        systemImage: "moon",
                        iconColor: PropDocsColors.labelSecondary,
                        isOn: $darkModeEnabled
                    )
                }
                
                // Subscription
                SettingsSection(title: "Subscription") {
                    SettingsRowView(
                        title: "PropDocs Pro",
                        subtitle: "Unlimited properties & premium features",
                        systemImage: "crown",
                        iconColor: .propDocsOrange,
                        accessoryText: "Active"
                    ) {
                        // Handle subscription tap
                    }
                    
                    SettingsRowView(
                        title: "Billing",
                        subtitle: "Payment methods & history",
                        systemImage: "creditcard",
                        iconColor: PropDocsColors.labelSecondary
                    ) {
                        // Handle billing tap
                    }
                }
                
                // Support
                SettingsSection(title: "Support") {
                    SettingsRowView(
                        title: "Help Center",
                        subtitle: "FAQs and guides",
                        systemImage: "questionmark.circle",
                        iconColor: .propDocsTeal
                    ) {
                        // Handle help center tap
                    }
                    
                    SettingsRowView(
                        title: "Contact Support",
                        subtitle: "Get help from our team",
                        systemImage: "envelope",
                        iconColor: .propDocsTeal
                    ) {
                        // Handle contact support tap
                    }
                    
                    SettingsRowView(
                        title: "Rate PropDocs",
                        subtitle: "Help us improve",
                        systemImage: "star",
                        iconColor: PropDocsColors.labelSecondary,
                        accessoryType: .externalLink
                    ) {
                        // Handle rate app tap
                    }
                    
                    SettingsRowView(
                        title: "Send Feedback",
                        subtitle: "Share your thoughts",
                        systemImage: "text.bubble",
                        iconColor: PropDocsColors.labelSecondary,
                        badge: 2
                    ) {
                        // Handle feedback tap
                    }
                }
                
                // About
                SettingsSection(title: "About") {
                    SettingsRowView(
                        title: "Terms of Service",
                        subtitle: nil,
                        systemImage: "doc.text",
                        iconColor: PropDocsColors.labelSecondary,
                        accessoryType: .externalLink
                    ) {
                        // Handle terms tap
                    }
                    
                    SettingsRowView(
                        title: "Privacy Policy",
                        subtitle: nil,
                        systemImage: "hand.raised",
                        iconColor: PropDocsColors.labelSecondary,
                        accessoryType: .externalLink
                    ) {
                        // Handle privacy policy tap
                    }
                    
                    SettingsRowView(
                        title: "About PropDocs",
                        subtitle: "Version info & credits",
                        systemImage: "info.circle",
                        iconColor: PropDocsColors.labelSecondary
                    ) {
                        // Handle about tap
                    }
                }
                
                // Sign Out
                SettingsSection(title: nil) {
                    SettingsRowView(
                        title: "Sign Out",
                        subtitle: nil,
                        systemImage: "rectangle.portrait.and.arrow.right",
                        iconColor: .propDocsRed,
                        titleColor: .propDocsRed,
                        accessoryType: .none
                    ) {
                        showingSignOutAlert = true
                    }
                }
                
                // Version Info
                VStack(spacing: Spacing.xs) {
                    Text("PropDocs v1.0.0")
                        .font(.footnote(.regular))
                        .foregroundColor(PropDocsColors.labelTertiary)
                    
                    Text("Build 2024.11.8")
                        .font(.caption(.regular))
                        .foregroundColor(PropDocsColors.labelTertiary)
                }
                .padding(.top, Spacing.md)
            }
            .padding(.top, Spacing.md)
        }
        .background(PropDocsColors.groupedBackgroundPrimary)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                IconButton(systemImage: "pencil") {
                    showingEditProfile = true
                }
            }
        }
        .sheet(isPresented: $showingEditProfile) {
            EditProfileView(user: mockUser)
        }
        .alert("Sign Out", isPresented: $showingSignOutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Sign Out", role: .destructive) {
                // Handle sign out
            }
        } message: {
            Text("Are you sure you want to sign out?")
        }
    }
}

// MARK: - Profile Section View

struct ProfileSectionView: View {
    
    let user: MockUser
    @Binding var showingEditProfile: Bool
    
    var body: some View {
        PropDocsCard {
            VStack(spacing: Spacing.lg) {
                // Avatar and Basic Info
                VStack(spacing: Spacing.md) {
                    // Avatar
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.propDocsBlue, .propdocsPurple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 80, height: 80)
                        
                        Text(user.initials)
                            .font(.system(size: 32, weight: .semibold, design: .default))
                            .foregroundColor(.white)
                    }
                    
                    // Name and Email
                    VStack(spacing: Spacing.xs) {
                        Text(user.name)
                            .font(.title2(.bold))
                            .foregroundColor(PropDocsColors.labelPrimary)
                        
                        Text(user.email)
                            .font(.subheadline(.regular))
                            .foregroundColor(PropDocsColors.labelSecondary)
                    }
                }
                
                // Stats
                HStack(spacing: 0) {
                    ProfileStatView(
                        value: "\(user.propertiesCount)",
                        label: "Properties"
                    )
                    
                    Divider()
                        .frame(height: 40)
                    
                    ProfileStatView(
                        value: "\(user.assetsCount)",
                        label: "Assets"
                    )
                    
                    Divider()
                        .frame(height: 40)
                    
                    ProfileStatView(
                        value: "\(user.dueTasksCount)",
                        label: "Due Tasks"
                    )
                }
                .padding(.horizontal, -Spacing.md)
                .padding(.vertical, Spacing.md)
                .background(PropDocsColors.fillSecondary)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.sm))
            }
        }
        .padding(.horizontal, Spacing.md)
    }
}

// MARK: - Profile Stat View

struct ProfileStatView: View {
    
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.headline(.semibold))
                .foregroundColor(PropDocsColors.labelPrimary)
            
            Text(label)
                .font(.caption(.regular))
                .foregroundColor(PropDocsColors.labelSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Settings Section

struct SettingsSection<Content: View>: View {
    
    let title: String?
    let content: () -> Content
    
    init(title: String?, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            if let title = title {
                Text(title.uppercased())
                    .font(.footnote(.semibold))
                    .foregroundColor(PropDocsColors.labelSecondary)
                    .padding(.horizontal, Spacing.md)
                    .padding(.top, Spacing.lg)
            }
            
            LazyVStack(spacing: 0) {
                content()
            }
            .background(PropDocsColors.groupedBackgroundSecondary)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
            .padding(.horizontal, Spacing.md)
        }
    }
}

// MARK: - Settings Row View

struct SettingsRowView: View {
    
    let title: String
    let subtitle: String?
    let systemImage: String
    let iconColor: Color
    let titleColor: Color
    let accessoryText: String?
    let accessoryType: AccessoryType
    let badge: Int?
    let action: () -> Void
    
    enum AccessoryType {
        case chevron
        case externalLink
        case none
    }
    
    init(
        title: String,
        subtitle: String?,
        systemImage: String,
        iconColor: Color,
        titleColor: Color = PropDocsColors.labelPrimary,
        accessoryText: String? = nil,
        accessoryType: AccessoryType = .chevron,
        badge: Int? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.iconColor = iconColor
        self.titleColor = titleColor
        self.accessoryText = accessoryText
        self.accessoryType = accessoryType
        self.badge = badge
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.md) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(iconColor)
                        .frame(width: 28, height: 28)
                    
                    Image(systemName: systemImage)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body(.regular))
                        .foregroundColor(titleColor)
                        .multilineTextAlignment(.leading)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.footnote(.regular))
                            .foregroundColor(PropDocsColors.labelSecondary)
                            .multilineTextAlignment(.leading)
                    }
                }
                
                Spacer()
                
                // Badge
                if let badge = badge {
                    Badge(badge)
                }
                
                // Accessory Text
                if let accessoryText = accessoryText {
                    Text(accessoryText)
                        .font(.body(.regular))
                        .foregroundColor(PropDocsColors.labelSecondary)
                }
                
                // Accessory Icon
                switch accessoryType {
                case .chevron:
                    Image(systemName: "chevron.right")
                        .font(.footnote(.medium))
                        .foregroundColor(PropDocsColors.labelTertiary)
                case .externalLink:
                    Image(systemName: "arrow.up.right")
                        .font(.footnote(.medium))
                        .foregroundColor(PropDocsColors.labelTertiary)
                case .none:
                    EmptyView()
                }
            }
            .padding(Spacing.md)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .background(
            Rectangle()
                .fill(Color.clear)
                .contentShape(Rectangle())
                .onTapGesture(perform: action)
        )
        .overlay(
            // Separator
            VStack {
                Spacer()
                HStack {
                    Spacer()
                        .frame(width: 28 + Spacing.md * 2) // Icon width + padding
                    Rectangle()
                        .fill(PropDocsColors.separator)
                        .frame(height: 0.5)
                }
            }
        )
    }
}

// MARK: - Settings Toggle Row

struct SettingsToggleRow: View {
    
    let title: String
    let subtitle: String?
    let systemImage: String
    let iconColor: Color
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(iconColor)
                    .frame(width: 28, height: 28)
                
                Image(systemName: systemImage)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body(.regular))
                    .foregroundColor(PropDocsColors.labelPrimary)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.footnote(.regular))
                        .foregroundColor(PropDocsColors.labelSecondary)
                }
            }
            
            Spacer()
            
            // Toggle
            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
        .padding(Spacing.md)
        .overlay(
            // Separator
            VStack {
                Spacer()
                HStack {
                    Spacer()
                        .frame(width: 28 + Spacing.md * 2) // Icon width + padding
                    Rectangle()
                        .fill(PropDocsColors.separator)
                        .frame(height: 0.5)
                }
            }
        )
    }
}

// MARK: - Edit Profile View (Placeholder)

struct EditProfileView: View {
    
    let user: MockUser
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Edit Profile")
                    .font(.title.weight(.bold))
                
                Text("Profile editing form would go here")
                    .font(.body)
                    .foregroundColor(PropDocsColors.labelSecondary)
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

// MARK: - Mock User Model

struct MockUser {
    let initials: String
    let name: String
    let email: String
    let propertiesCount: Int
    let assetsCount: Int
    let dueTasksCount: Int
}

#Preview {
    NavigationView {
        SettingsView()
            .environmentObject(PropertyViewModel())
    }
}