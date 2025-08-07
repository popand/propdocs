//
//  BiometricErrorHandlerView.swift
//  PropDocs
//
//  Created by Andrei Pop on 2025-08-06.
//

import SwiftUI
import LocalAuthentication

struct BiometricErrorHandlerView: View {
    let error: BiometricAuthenticationError
    let onRetry: () -> Void
    let onFallback: () -> Void
    let onCancel: () -> Void
    let onSetup: () -> Void
    
    @State private var showingSetupGuidance = false
    @State private var animateError = false
    
    var body: some View {
        VStack(spacing: 24) {
            // Error icon with animation
            errorIconView
            
            // Error message
            errorMessageView
            
            // Guidance and actions
            errorActionsView
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 24)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 4)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                animateError = true
            }
        }
    }
    
    // MARK: - Error Icon View
    
    private var errorIconView: some View {
        ZStack {
            Circle()
                .fill(errorBackgroundColor)
                .frame(width: 80, height: 80)
                .scaleEffect(animateError ? 1.0 : 0.8)
                .animation(.spring(response: 0.5, dampingFraction: 0.7), value: animateError)
            
            Image(systemName: errorIcon)
                .font(.system(size: 32, weight: .medium))
                .foregroundColor(errorColor)
                .scaleEffect(animateError ? 1.0 : 0.6)
                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: animateError)
        }
    }
    
    // MARK: - Error Message View
    
    private var errorMessageView: some View {
        VStack(spacing: 12) {
            Text(errorTitle)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .opacity(animateError ? 1.0 : 0.0)
                .animation(.easeInOut.delay(0.2), value: animateError)
            
            Text(errorDescription)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .opacity(animateError ? 1.0 : 0.0)
                .animation(.easeInOut.delay(0.3), value: animateError)
        }
    }
    
    // MARK: - Error Actions View
    
    private var errorActionsView: some View {
        VStack(spacing: 16) {
            // Primary actions
            primaryActionButtons
            
            // Secondary actions
            secondaryActionButtons
            
            // Additional guidance
            if needsSetupGuidance {
                setupGuidanceButton
            }
        }
        .opacity(animateError ? 1.0 : 0.0)
        .animation(.easeInOut.delay(0.4), value: animateError)
    }
    
    private var primaryActionButtons: some View {
        VStack(spacing: 12) {
            ForEach(primaryActions, id: \.title) { action in
                Button(action: action.action) {
                    HStack {
                        if let icon = action.icon {
                            Image(systemName: icon)
                                .font(.body)
                        }
                        
                        Text(action.title)
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(action.color)
                    .cornerRadius(10)
                }
                .disabled(action.disabled)
            }
        }
    }
    
    private var secondaryActionButtons: some View {
        HStack(spacing: 12) {
            ForEach(secondaryActions, id: \.title) { action in
                Button(action: action.action) {
                    HStack {
                        if let icon = action.icon {
                            Image(systemName: icon)
                                .font(.caption)
                        }
                        
                        Text(action.title)
                            .font(.body)
                    }
                    .foregroundColor(action.color)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 16)
                    .background(action.color.opacity(0.1))
                    .cornerRadius(8)
                }
                .disabled(action.disabled)
            }
        }
    }
    
    private var setupGuidanceButton: some View {
        Button("Setup Guidance") {
            showingSetupGuidance = true
        }
        .font(.body)
        .foregroundColor(.blue)
        .padding(.vertical, 8)
        .sheet(isPresented: $showingSetupGuidance) {
            BiometricSetupGuidanceView(error: error)
        }
    }
    
    // MARK: - Computed Properties
    
    private var errorTitle: String {
        switch error {
        case .biometryNotAvailable:
            return "Biometrics Unavailable"
        case .biometryNotEnrolled:
            return "Setup Required"
        case .biometryLockout:
            return "Temporarily Locked"
        case .authenticationFailed:
            return "Authentication Failed"
        case .userCancel:
            return "Authentication Cancelled"
        case .userFallback:
            return "Passcode Required"
        case .systemCancel:
            return "System Interrupted"
        case .passcodeNotSet:
            return "Passcode Required"
        case .unknown:
            return "Authentication Error"
        }
    }
    
    private var errorDescription: String {
        switch error {
        case .biometryNotAvailable:
            return "This device doesn't support biometric authentication or it's currently disabled."
        case .biometryNotEnrolled:
            return "No biometric credentials are set up on this device. Please set up Face ID or Touch ID in Settings."
        case .biometryLockout:
            return "Biometric authentication is temporarily disabled due to too many failed attempts. Try again later or use your passcode."
        case .authenticationFailed:
            return "The biometric authentication attempt was not successful. Please try again."
        case .userCancel:
            return "You cancelled the authentication request."
        case .userFallback:
            return "Please authenticate using your device passcode instead."
        case .systemCancel:
            return "Authentication was interrupted by the system. Please try again."
        case .passcodeNotSet:
            return "Please set up a device passcode in Settings to use biometric authentication."
        case .unknown(let underlyingError):
            return "An unexpected error occurred: \(underlyingError.localizedDescription)"
        }
    }
    
    private var errorIcon: String {
        switch error {
        case .biometryNotAvailable:
            return "exclamationmark.triangle.fill"
        case .biometryNotEnrolled:
            return "person.crop.circle.badge.plus"
        case .biometryLockout:
            return "lock.circle.fill"
        case .authenticationFailed:
            return "xmark.circle.fill"
        case .userCancel:
            return "multiply.circle.fill"
        case .userFallback:
            return "key.fill"
        case .systemCancel:
            return "pause.circle.fill"
        case .passcodeNotSet:
            return "key.badge.exclamationmark"
        case .unknown:
            return "questionmark.circle.fill"
        }
    }
    
    private var errorColor: Color {
        switch error {
        case .biometryNotAvailable, .biometryNotEnrolled, .passcodeNotSet:
            return .orange
        case .biometryLockout, .authenticationFailed, .unknown:
            return .red
        case .userCancel, .systemCancel:
            return .gray
        case .userFallback:
            return .blue
        }
    }
    
    private var errorBackgroundColor: Color {
        errorColor.opacity(0.15)
    }
    
    private var needsSetupGuidance: Bool {
        switch error {
        case .biometryNotEnrolled, .biometryNotAvailable, .passcodeNotSet:
            return true
        default:
            return false
        }
    }
    
    // MARK: - Action Definitions
    
    private var primaryActions: [ErrorAction] {
        switch error {
        case .authenticationFailed:
            return [
                ErrorAction(title: "Try Again", icon: "arrow.clockwise", color: .blue, action: onRetry)
            ]
        case .biometryLockout:
            return [
                ErrorAction(title: "Use Passcode", icon: "key", color: .green, action: onFallback)
            ]
        case .biometryNotEnrolled:
            return [
                ErrorAction(title: "Set Up Biometrics", icon: "person.crop.circle.badge.plus", color: .blue, action: onSetup)
            ]
        case .userFallback:
            return [
                ErrorAction(title: "Use Passcode", icon: "key", color: .blue, action: onFallback)
            ]
        case .passcodeNotSet:
            return [
                ErrorAction(title: "Open Settings", icon: "gear", color: .blue, action: openSettings)
            ]
        default:
            return []
        }
    }
    
    private var secondaryActions: [ErrorAction] {
        switch error {
        case .authenticationFailed:
            return [
                ErrorAction(title: "Use Passcode", icon: "key", color: .green, action: onFallback),
                ErrorAction(title: "Cancel", icon: nil, color: .gray, action: onCancel)
            ]
        case .biometryNotEnrolled, .biometryNotAvailable:
            return [
                ErrorAction(title: "Skip", icon: nil, color: .gray, action: onCancel)
            ]
        default:
            return [
                ErrorAction(title: "Cancel", icon: nil, color: .gray, action: onCancel)
            ]
        }
    }
    
    private func openSettings() {
        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsURL)
        }
    }
}

// MARK: - Error Action Model

private struct ErrorAction {
    let title: String
    let icon: String?
    let color: Color
    let action: () -> Void
    let disabled: Bool
    
    init(title: String, icon: String? = nil, color: Color, action: @escaping () -> Void, disabled: Bool = false) {
        self.title = title
        self.icon = icon
        self.color = color
        self.action = action
        self.disabled = disabled
    }
}

// MARK: - Setup Guidance View

struct BiometricSetupGuidanceView: View {
    let error: BiometricAuthenticationError
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    setupHeaderView
                    
                    // Step-by-step instructions
                    setupInstructionsView
                    
                    // Additional tips
                    setupTipsView
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .navigationTitle("Setup Guide")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var setupHeaderView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(setupTitle)
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(setupDescription)
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
    
    private var setupInstructionsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Setup Instructions")
                .font(.headline)
                .fontWeight(.semibold)
            
            ForEach(Array(setupSteps.enumerated()), id: \.offset) { index, step in
                HStack(alignment: .top, spacing: 12) {
                    Text("\(index + 1)")
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(width: 24, height: 24)
                        .background(Circle().fill(Color.blue))
                    
                    Text(step)
                        .font(.body)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
    
    private var setupTipsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tips for Best Results")
                .font(.headline)
                .fontWeight(.semibold)
            
            ForEach(setupTips, id: \.self) { tip in
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "lightbulb.fill")
                        .font(.caption)
                        .foregroundColor(.yellow)
                    
                    Text(tip)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    private var setupTitle: String {
        switch error {
        case .biometryNotEnrolled:
            return "Set Up Biometric Authentication"
        case .passcodeNotSet:
            return "Set Up Device Passcode"
        default:
            return "Setup Required"
        }
    }
    
    private var setupDescription: String {
        switch error {
        case .biometryNotEnrolled:
            return "Follow these steps to set up Face ID or Touch ID on your device for secure access to PropDocs."
        case .passcodeNotSet:
            return "A device passcode is required before you can use biometric authentication."
        default:
            return "Complete the setup process to enable secure authentication."
        }
    }
    
    private var setupSteps: [String] {
        switch error {
        case .biometryNotEnrolled:
            return [
                "Open the Settings app on your device",
                "Scroll down and tap 'Face ID & Passcode' or 'Touch ID & Passcode'",
                "Enter your device passcode when prompted",
                "Tap 'Set Up Face ID' or 'Add a Fingerprint'",
                "Follow the on-screen instructions to complete enrollment",
                "Return to PropDocs and try again"
            ]
        case .passcodeNotSet:
            return [
                "Open the Settings app on your device",
                "Scroll down and tap 'Face ID & Passcode' or 'Touch ID & Passcode'",
                "Tap 'Turn Passcode On'",
                "Choose a 6-digit passcode or tap 'Passcode Options' for other formats",
                "Enter and confirm your new passcode",
                "Return to PropDocs to set up biometric authentication"
            ]
        default:
            return ["Please check your device settings and try again"]
        }
    }
    
    private var setupTips: [String] {
        switch error {
        case .biometryNotEnrolled:
            return [
                "Ensure your face or finger is clean and dry for better recognition",
                "Hold the device at a comfortable distance during setup",
                "Make sure you have good lighting when setting up Face ID",
                "You can add multiple fingerprints for Touch ID"
            ]
        default:
            return [
                "Choose a passcode that's secure but easy for you to remember",
                "Avoid using common patterns or your birthday"
            ]
        }
    }
}

// MARK: - Error Alert Modifier

struct BiometricErrorAlert: ViewModifier {
    @Binding var isPresented: Bool
    let error: BiometricAuthenticationError?
    let onRetry: () -> Void
    let onFallback: () -> Void
    let onSetup: () -> Void
    
    func body(content: Content) -> some View {
        content
            .alert("Authentication Error", isPresented: $isPresented) {
                if let error = error {
                    switch error {
                    case .authenticationFailed:
                        Button("Try Again", action: onRetry)
                        Button("Use Passcode", action: onFallback)
                        Button("Cancel", role: .cancel) { }
                    case .biometryNotEnrolled:
                        Button("Set Up", action: onSetup)
                        Button("Cancel", role: .cancel) { }
                    case .biometryLockout:
                        Button("Use Passcode", action: onFallback)
                        Button("Cancel", role: .cancel) { }
                    default:
                        Button("OK", role: .cancel) { }
                    }
                }
            } message: {
                if let error = error {
                    Text(error.localizedDescription)
                }
            }
    }
}

extension View {
    func biometricErrorAlert(
        isPresented: Binding<Bool>,
        error: BiometricAuthenticationError?,
        onRetry: @escaping () -> Void = {},
        onFallback: @escaping () -> Void = {},
        onSetup: @escaping () -> Void = {}
    ) -> some View {
        modifier(BiometricErrorAlert(
            isPresented: isPresented,
            error: error,
            onRetry: onRetry,
            onFallback: onFallback,
            onSetup: onSetup
        ))
    }
}

// MARK: - Preview

struct BiometricErrorHandlerView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Authentication failed
            BiometricErrorHandlerView(
                error: .authenticationFailed,
                onRetry: {},
                onFallback: {},
                onCancel: {},
                onSetup: {}
            )
            .previewDisplayName("Authentication Failed")
            
            // Biometry not enrolled
            BiometricErrorHandlerView(
                error: .biometryNotEnrolled,
                onRetry: {},
                onFallback: {},
                onCancel: {},
                onSetup: {}
            )
            .previewDisplayName("Setup Required")
            
            // Biometry lockout
            BiometricErrorHandlerView(
                error: .biometryLockout,
                onRetry: {},
                onFallback: {},
                onCancel: {},
                onSetup: {}
            )
            .previewDisplayName("Locked Out")
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }
}