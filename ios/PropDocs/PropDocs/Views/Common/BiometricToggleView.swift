//
//  BiometricToggleView.swift
//  PropDocs
//
//  Created by Andrei Pop on 2025-08-06.
//

import SwiftUI

struct BiometricToggleView: View {
    @StateObject private var viewModel = BiometricViewModel()
    @State private var showingPolicySettings = false

    var body: some View {
        VStack(spacing: 0) {
            // Main toggle section
            mainToggleSection

            // Additional settings (when enabled)
            if viewModel.isEnabled {
                additionalSettingsSection
            }
        }
    }

    // MARK: - Main Toggle Section

    private var mainToggleSection: some View {
        VStack(spacing: 16) {
            // Toggle row
            HStack(spacing: 16) {
                // Biometric icon
                biometricIconView

                // Title and description
                VStack(alignment: .leading, spacing: 4) {
                    Text(biometricTitle)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)

                    Text(biometricDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                // Toggle switch or action button
                toggleControl
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            // Status indicator
            if viewModel.isEnabled || viewModel.isLockedOut {
                statusIndicator
                    .padding(.horizontal, 16)
            }
        }
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }

    private var biometricIconView: some View {
        ZStack {
            Circle()
                .fill(iconBackgroundColor)
                .frame(width: 40, height: 40)

            Image(systemName: iconSystemName)
                .font(.system(size: 20))
                .foregroundColor(iconColor)
        }
    }

    private var toggleControl: some View {
        Group {
            if viewModel.canUseBiometrics {
                Toggle("", isOn: Binding(
                    get: { viewModel.isEnabled },
                    set: { enabled in
                        if enabled {
                            Task {
                                _ = await viewModel.enableBiometricAuthentication()
                            }
                        } else {
                            viewModel.disableBiometricAuthentication()
                        }
                    }
                ))
                .disabled(viewModel.isLoading || viewModel.isLockedOut)
            } else {
                Button("Setup") {
                    viewModel.presentBiometricSetup()
                }
                .font(.body)
                .foregroundColor(.blue)
                .disabled(!viewModel.isAvailable)
            }
        }
    }

    private var statusIndicator: some View {
        HStack(spacing: 8) {
            Image(systemName: statusIcon)
                .font(.caption)
                .foregroundColor(statusColor)

            Text(statusText)
                .font(.caption)
                .foregroundColor(statusColor)

            Spacer()

            if viewModel.isLockedOut, viewModel.lockoutTimeRemaining != nil {
                Text(viewModel.lockoutStatusText)
                    .font(.caption)
                    .foregroundColor(.orange)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(statusBackgroundColor)
        .cornerRadius(8)
    }

    // MARK: - Additional Settings Section

    private var additionalSettingsSection: some View {
        VStack(spacing: 12) {
            Divider()
                .padding(.horizontal, 16)

            // Policy configuration
            policyConfigurationRow

            // Last authentication info
            if let lastAuth = viewModel.lastAuthenticationDate {
                lastAuthenticationRow(date: lastAuth)
            }

            // Reset lockout button (if applicable)
            if viewModel.isLockedOut {
                resetLockoutButton
            }
        }
        .padding(.vertical, 8)
        .background(Color(.secondarySystemGroupedBackground))
    }

    private var policyConfigurationRow: some View {
        Button(action: {
            showingPolicySettings = true
        }) {
            HStack {
                Image(systemName: "gear")
                    .foregroundColor(.blue)
                    .frame(width: 20)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Security Policy")
                        .font(.body)
                        .foregroundColor(.primary)

                    Text(policyDescriptionText)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }

    private func lastAuthenticationRow(date: Date) -> some View {
        HStack {
            Image(systemName: "clock")
                .foregroundColor(.green)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text("Last Authentication")
                    .font(.body)
                    .foregroundColor(.primary)

                Text(formatDate(date))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    private var resetLockoutButton: some View {
        Button("Reset Lockout") {
            viewModel.resetLockout()
        }
        .font(.body)
        .foregroundColor(.red)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    // MARK: - Computed Properties

    private var biometricTitle: String {
        if viewModel.isAvailable {
            return viewModel.biometricType.displayName
        } else {
            return "Biometric Authentication"
        }
    }

    private var biometricDescription: String {
        if !viewModel.isAvailable {
            return "Not available on this device"
        } else if viewModel.isEnabled {
            return "Secure access with \(viewModel.biometricType.displayName)"
        } else {
            return "Use \(viewModel.biometricType.displayName) for secure access"
        }
    }

    private var iconSystemName: String {
        if viewModel.isAvailable {
            return viewModel.biometricType.icon
        } else {
            return "faceid.fill"
        }
    }

    private var iconColor: Color {
        if !viewModel.isAvailable {
            return .gray
        } else if viewModel.isEnabled {
            return .green
        } else {
            return .blue
        }
    }

    private var iconBackgroundColor: Color {
        if !viewModel.isAvailable {
            return Color.gray.opacity(0.1)
        } else if viewModel.isEnabled {
            return Color.green.opacity(0.1)
        } else {
            return Color.blue.opacity(0.1)
        }
    }

    private var statusIcon: String {
        switch viewModel.authenticationStatus {
        case .authenticated:
            return "checkmark.circle.fill"
        case .requiresAuthentication:
            return "exclamationmark.circle.fill"
        case .lockedOut:
            return "lock.circle.fill"
        case .notAuthenticated:
            return "circle"
        }
    }

    private var statusColor: Color {
        switch viewModel.authenticationStatus {
        case .authenticated:
            return .green
        case .requiresAuthentication:
            return .orange
        case .lockedOut:
            return .red
        case .notAuthenticated:
            return .gray
        }
    }

    private var statusBackgroundColor: Color {
        statusColor.opacity(0.1)
    }

    private var statusText: String {
        switch viewModel.authenticationStatus {
        case .authenticated:
            return "Authentication verified"
        case .requiresAuthentication:
            return "Authentication required"
        case .lockedOut:
            return "Temporarily locked out"
        case .notAuthenticated:
            return "Not configured"
        }
    }

    private var policyDescriptionText: String {
        let config = viewModel.policyConfiguration
        if config.requireBiometrics {
            return "Strict security policy"
        } else if config.allowFallback {
            return "Standard security policy"
        } else {
            return "Custom security policy"
        }
    }

    // MARK: - Helper Methods

    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .named
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Policy Settings Sheet

struct BiometricPolicySettingsView: View {
    @ObservedObject var viewModel: BiometricViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var selectedPolicy: PolicyOption = .default

    private enum PolicyOption: String, CaseIterable {
        case relaxed = "Relaxed"
        case `default` = "Standard"
        case strict = "Strict"

        var description: String {
            switch self {
            case .relaxed:
                return "Allows fallback authentication, longer timeouts"
            case .default:
                return "Balanced security and usability"
            case .strict:
                return "Requires biometrics, shorter timeouts"
            }
        }

        var configuration: BiometricPolicyConfiguration {
            switch self {
            case .relaxed:
                return .relaxed
            case .default:
                return .default
            case .strict:
                return .strict
            }
        }
    }

    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach(PolicyOption.allCases, id: \.self) { option in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(option.rawValue)
                                    .font(.body)
                                    .fontWeight(.medium)

                                Spacer()

                                if selectedPolicy == option {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.blue)
                                }
                            }

                            Text(option.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedPolicy = option
                        }
                    }
                } header: {
                    Text("Security Policy")
                } footer: {
                    Text("Choose the security policy that best fits your needs. Changes take effect immediately.")
                }
            }
            .navigationTitle("Biometric Security")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        viewModel.setPolicyConfiguration(selectedPolicy.configuration)
                        dismiss()
                    }
                    .font(.body.weight(.semibold))
                }
            }
        }
        .onAppear {
            // Set current policy as selected
            let current = viewModel.policyConfiguration
            if current.requireBiometrics, !current.allowFallback {
                selectedPolicy = .strict
            } else if current.allowFallback, current.maxAttempts > 3 {
                selectedPolicy = .relaxed
            } else {
                selectedPolicy = .default
            }
        }
    }
}

// MARK: - Integration with Settings

struct BiometricSettingsSection: View {
    var body: some View {
        Section {
            BiometricToggleView()
        } header: {
            Text("Security")
        } footer: {
            Text("Use biometric authentication for quick and secure access to your property information.")
        }
    }
}

// MARK: - Preview

struct BiometricToggleView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Enabled state
            List {
                BiometricSettingsSection()
            }
            .previewDisplayName("Settings Integration")

            // Individual toggle
            VStack {
                BiometricToggleView()
                Spacer()
            }
            .padding()
            .background(Color(.systemGroupedBackground))
            .previewDisplayName("Standalone Toggle")

            // Dark mode
            List {
                BiometricSettingsSection()
            }
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")
        }
    }
}
