//
//  FallbackAuthenticationView.swift
//  PropDocs
//
//  Created by Andrei Pop on 2025-08-06.
//

import LocalAuthentication
import SwiftUI

struct FallbackAuthenticationView: View {
    @StateObject private var biometricManager = BiometricAuthenticationManager.shared
    @StateObject private var viewModel = FallbackAuthenticationViewModel()

    // Navigation and completion
    @Environment(\.dismiss) private var dismiss
    let onAuthenticationSuccess: () -> Void
    let onAuthenticationCancel: () -> Void

    // State
    @State private var showRetryBiometric = false

    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                // Header
                headerSection

                // Status and options
                authenticationOptionsSection

                Spacer()

                // Action buttons
                actionButtonsSection
            }
            .padding(.horizontal, 24)
            .padding(.top, 32)
            .navigationTitle("Authentication Required")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        onAuthenticationCancel()
                    }
                }
            }
        }
        .alert("Authentication Error", isPresented: $viewModel.showError) {
            Button("Try Again") {
                viewModel.showError = false
            }
            Button("Cancel", role: .cancel) {
                onAuthenticationCancel()
            }
        } message: {
            Text(viewModel.errorMessage)
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: 16) {
            // Error icon with animation
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.1))
                    .frame(width: 100, height: 100)

                Image(systemName: "exclamationmark.shield")
                    .font(.system(size: 40))
                    .foregroundColor(.red)
            }

            VStack(spacing: 8) {
                Text("Authentication Failed")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text(authenticationFailureReason)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }

    // MARK: - Authentication Options Section

    private var authenticationOptionsSection: some View {
        VStack(spacing: 20) {
            // Biometric retry option
            if canRetryBiometric {
                biometricRetryCard
            }

            // Passcode fallback option
            if biometricManager.policyConfiguration.allowFallback {
                passcodeAuthenticationCard
            }

            // Lockout information
            if biometricManager.isLockedOut {
                lockoutInformationCard
            }
        }
    }

    private var biometricRetryCard: some View {
        VStack(spacing: 16) {
            HStack {
                biometricManager.biometricIcon
                    .font(.title2)
                    .foregroundColor(.blue)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Retry \(biometricManager.biometricType.displayName)")
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text("Try biometric authentication again")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Button("Retry") {
                    Task {
                        await retryBiometricAuthentication()
                    }
                }
                .disabled(viewModel.isLoading)
            }
        }
        .padding()
        .background(Color.blue.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.blue.opacity(0.2), lineWidth: 1)
        )
    }

    private var passcodeAuthenticationCard: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "key")
                    .font(.title2)
                    .foregroundColor(.green)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Use Device Passcode")
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text("Authenticate with your device passcode")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Button("Use Passcode") {
                    Task {
                        await authenticateWithPasscode()
                    }
                }
                .disabled(viewModel.isLoading)
            }
        }
        .padding()
        .background(Color.green.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.green.opacity(0.2), lineWidth: 1)
        )
    }

    private var lockoutInformationCard: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "clock.badge.exclamationmark")
                    .font(.title2)
                    .foregroundColor(.orange)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Temporarily Locked")
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(lockoutMessage)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }
        }
        .padding()
        .background(Color.orange.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.orange.opacity(0.2), lineWidth: 1)
        )
    }

    // MARK: - Action Buttons Section

    private var actionButtonsSection: some View {
        VStack(spacing: 16) {
            if viewModel.isLoading {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)

                    Text("Authenticating...")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            }

            // Skip authentication (if allowed by policy)
            if canSkipAuthentication {
                Button("Skip for Now") {
                    onAuthenticationCancel()
                }
                .foregroundColor(.secondary)
                .font(.body)
            }
        }
    }

    // MARK: - Computed Properties

    private var authenticationFailureReason: String {
        if biometricManager.isLockedOut {
            return "Too many failed attempts. Biometric authentication is temporarily disabled."
        } else if !biometricManager.isAvailable {
            return "Biometric authentication is not available on this device."
        } else if !biometricManager.isEnabled {
            return "Biometric authentication is not enabled for this app."
        } else {
            return "Please try again or use an alternative authentication method."
        }
    }

    private var canRetryBiometric: Bool {
        biometricManager.isAvailable &&
            biometricManager.isEnabled &&
            !biometricManager.isLockedOut
    }

    private var canSkipAuthentication: Bool {
        !biometricManager.policyConfiguration.requireBiometrics
    }

    private var lockoutMessage: String {
        if let timeRemaining = biometricManager.lockoutTimeRemaining {
            let minutes = Int(timeRemaining / 60)
            let seconds = Int(timeRemaining.truncatingRemainder(dividingBy: 60))

            if minutes > 0 {
                return "Try again in \(minutes)m \(seconds)s"
            } else {
                return "Try again in \(seconds)s"
            }
        }
        return "Please try again later"
    }

    // MARK: - Actions

    private func retryBiometricAuthentication() async {
        let result = await biometricManager.authenticate(reason: "Authenticate to access PropDocs")

        switch result {
        case .success:
            onAuthenticationSuccess()
        case let .failure(error):
            await viewModel.handleAuthenticationError(error)
        }
    }

    private func authenticateWithPasscode() async {
        let result = await biometricManager
            .authenticateWithFallback(reason: "Authenticate with passcode to access PropDocs")

        switch result {
        case .success:
            onAuthenticationSuccess()
        case let .failure(error):
            await viewModel.handleAuthenticationError(error)
        }
    }
}

// MARK: - View Model

@MainActor
class FallbackAuthenticationViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""

    func handleAuthenticationError(_ error: BiometricAuthenticationError) async {
        switch error {
        case .userCancel, .systemCancel:
            // User cancelled, don't show error
            break
        default:
            errorMessage = error.localizedDescription
            showError = true
        }

        isLoading = false
    }
}

// MARK: - Preview

struct FallbackAuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Normal failure state
            FallbackAuthenticationView(
                onAuthenticationSuccess: {},
                onAuthenticationCancel: {}
            )
            .previewDisplayName("Authentication Failed")

            // Locked out state
            FallbackAuthenticationView(
                onAuthenticationSuccess: {},
                onAuthenticationCancel: {}
            )
            .onAppear {
                BiometricAuthenticationManager.shared.lockoutEndTime = Date().addingTimeInterval(300)
            }
            .previewDisplayName("Locked Out")

            // Dark mode
            FallbackAuthenticationView(
                onAuthenticationSuccess: {},
                onAuthenticationCancel: {}
            )
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")
        }
    }
}
