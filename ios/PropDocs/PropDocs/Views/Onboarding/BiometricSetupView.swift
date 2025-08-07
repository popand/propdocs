//
//  BiometricSetupView.swift
//  PropDocs
//
//  Created by Andrei Pop on 2025-08-06.
//

import SwiftUI
import LocalAuthentication

struct BiometricSetupView: View {
    @StateObject private var biometricManager = BiometricAuthenticationManager.shared
    @StateObject private var viewModel = BiometricSetupViewModel()
    
    // Navigation and state
    @Environment(\.dismiss) private var dismiss
    @Binding var isPresented: Bool
    
    // Animation states
    @State private var showSuccessAnimation = false
    @State private var showErrorAnimation = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                // Header Section
                headerSection
                
                // Status Section
                statusSection
                
                // Action Section
                actionSection
                
                Spacer()
                
                // Footer Section
                footerSection
            }
            .padding(.horizontal, 24)
            .padding(.top, 32)
            .navigationTitle("Secure Access")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Skip") {
                        isPresented = false
                    }
                    .foregroundColor(.secondary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                    .opacity(biometricManager.isEnabled ? 1 : 0)
                    .animation(.easeInOut, value: biometricManager.isEnabled)
                }
            }
        }
        .alert("Authentication Error", isPresented: $viewModel.showError) {
            Button("Try Again") {
                viewModel.showError = false
            }
            Button("Skip", role: .cancel) {
                isPresented = false
            }
        } message: {
            Text(viewModel.errorMessage)
        }
        .onAppear {
            biometricManager.updateBiometricAvailability()
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Biometric icon with animation
            ZStack {
                Circle()
                    .fill(biometricIconBackgroundColor)
                    .frame(width: 120, height: 120)
                    .scaleEffect(showSuccessAnimation ? 1.1 : 1.0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6), value: showSuccessAnimation)
                
                biometricManager.biometricIcon
                    .font(.system(size: 50))
                    .foregroundColor(biometricIconColor)
                    .scaleEffect(showSuccessAnimation ? 1.2 : 1.0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6), value: showSuccessAnimation)
                
                // Success checkmark overlay
                if showSuccessAnimation {
                    Image(systemName: "checkmark")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.green)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .animation(.easeInOut(duration: 0.3), value: showSuccessAnimation)
            
            // Title and subtitle
            VStack(spacing: 8) {
                Text(headerTitle)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                
                Text(headerSubtitle)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    // MARK: - Status Section
    
    private var statusSection: some View {
        VStack(spacing: 16) {
            // Current status indicator
            HStack(spacing: 12) {
                Image(systemName: statusIcon)
                    .foregroundColor(statusColor)
                    .font(.title3)
                
                Text(biometricManager.biometricStatusDescription)
                    .font(.body)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(statusBackgroundColor)
            .cornerRadius(12)
            
            // Benefits list
            if biometricManager.canUseBiometrics {
                benefitsList
            }
        }
    }
    
    private var benefitsList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Benefits of Biometric Authentication:")
                .font(.headline)
                .foregroundColor(.primary)
            
            ForEach(biometricBenefits, id: \.self) { benefit in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.system(size: 16))
                    
                    Text(benefit)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Spacer()
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    // MARK: - Action Section
    
    private var actionSection: some View {
        VStack(spacing: 16) {
            if biometricManager.canUseBiometrics {
                // Enable biometric authentication button
                Button(action: {
                    Task {
                        await enableBiometricAuthentication()
                    }
                }) {
                    HStack {
                        if viewModel.isLoading {
                            ProgressView()
                                .scaleEffect(0.8)
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Image(systemName: biometricManager.biometricType.icon)
                                .font(.title3)
                        }
                        
                        Text(biometricManager.isEnabled ? "Biometric Authentication Enabled" : "Enable \(biometricManager.biometricType.displayName)")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(biometricManager.isEnabled ? Color.green : Color.blue)
                    .cornerRadius(12)
                }
                .disabled(viewModel.isLoading || biometricManager.isEnabled)
                
                // Disable button (if already enabled)
                if biometricManager.isEnabled {
                    Button("Disable Biometric Authentication") {
                        disableBiometricAuthentication()
                    }
                    .foregroundColor(.red)
                    .font(.body)
                }
                
            } else {
                // Setup guidance for unavailable biometrics
                setupGuidanceView
            }
        }
    }
    
    private var setupGuidanceView: some View {
        VStack(spacing: 16) {
            Text("Setup Required")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(biometricManager.getBiometricSetupGuidance())
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Open Settings") {
                openSettings()
            }
            .foregroundColor(.blue)
            .font(.headline)
            .padding(.vertical, 12)
            .padding(.horizontal, 24)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(8)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.separator), lineWidth: 1)
        )
    }
    
    // MARK: - Footer Section
    
    private var footerSection: some View {
        VStack(spacing: 12) {
            Text("You can change this setting later in your account preferences.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            if !biometricManager.canUseBiometrics {
                Text("PropDocs will continue to work securely with your device passcode.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var headerTitle: String {
        if biometricManager.isEnabled {
            return "\(biometricManager.biometricType.displayName) Enabled"
        } else if biometricManager.canUseBiometrics {
            return "Secure Your Account"
        } else {
            return "Biometric Setup"
        }
    }
    
    private var headerSubtitle: String {
        if biometricManager.isEnabled {
            return "Your account is secured with \(biometricManager.biometricType.displayName)"
        } else if biometricManager.canUseBiometrics {
            return "Use \(biometricManager.biometricType.displayName) for quick and secure access to PropDocs"
        } else {
            return "Set up biometric authentication for enhanced security"
        }
    }
    
    private var statusIcon: String {
        if biometricManager.isEnabled {
            return "checkmark.shield.fill"
        } else if biometricManager.canUseBiometrics {
            return "shield"
        } else {
            return "exclamationmark.triangle"
        }
    }
    
    private var statusColor: Color {
        if biometricManager.isEnabled {
            return .green
        } else if biometricManager.canUseBiometrics {
            return .blue
        } else {
            return .orange
        }
    }
    
    private var statusBackgroundColor: Color {
        if biometricManager.isEnabled {
            return Color.green.opacity(0.1)
        } else if biometricManager.canUseBiometrics {
            return Color.blue.opacity(0.1)
        } else {
            return Color.orange.opacity(0.1)
        }
    }
    
    private var biometricIconBackgroundColor: Color {
        if biometricManager.isEnabled {
            return Color.green.opacity(0.2)
        } else if biometricManager.canUseBiometrics {
            return Color.blue.opacity(0.2)
        } else {
            return Color.gray.opacity(0.2)
        }
    }
    
    private var biometricIconColor: Color {
        if biometricManager.isEnabled {
            return .green
        } else if biometricManager.canUseBiometrics {
            return .blue
        } else {
            return .gray
        }
    }
    
    private var biometricBenefits: [String] {
        [
            "Quick access to your property information",
            "Enhanced security for sensitive data",
            "No need to remember passwords",
            "Works even when offline"
        ]
    }
    
    // MARK: - Actions
    
    private func enableBiometricAuthentication() async {
        await viewModel.enableBiometric()
        
        if biometricManager.isEnabled {
            withAnimation(.spring()) {
                showSuccessAnimation = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation(.easeInOut) {
                    showSuccessAnimation = false
                }
            }
        }
    }
    
    private func disableBiometricAuthentication() {
        biometricManager.disableBiometricAuthentication()
        
        withAnimation(.easeInOut) {
            showSuccessAnimation = false
        }
    }
    
    private func openSettings() {
        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsURL)
        }
    }
}

// MARK: - View Model

@MainActor
class BiometricSetupViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    
    private let biometricManager = BiometricAuthenticationManager.shared
    
    func enableBiometric() async {
        isLoading = true
        
        let result = await biometricManager.enableBiometricAuthentication()
        
        isLoading = false
        
        switch result {
        case .success:
            // Success handled by the manager
            break
        case .failure(let error):
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}

// MARK: - Preview

struct BiometricSetupView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Available but not enabled
            BiometricSetupView(isPresented: .constant(true))
                .previewDisplayName("Available - Not Enabled")
            
            // Enabled state
            BiometricSetupView(isPresented: .constant(true))
                .onAppear {
                    BiometricAuthenticationManager.shared.isEnabled = true
                    BiometricAuthenticationManager.shared.isAvailable = true
                    BiometricAuthenticationManager.shared.biometricType = .faceID
                }
                .previewDisplayName("Enabled State")
            
            // Dark mode
            BiometricSetupView(isPresented: .constant(true))
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
        }
    }
}