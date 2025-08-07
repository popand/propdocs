//
//  BiometricViewModel.swift
//  PropDocs
//
//  Created by Andrei Pop on 2025-08-06.
//

import Foundation
import SwiftUI
import Combine
import LocalAuthentication

@MainActor
class BiometricViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var isEnabled: Bool = false
    @Published var isAvailable: Bool = false
    @Published var biometricType: BiometricType = .none
    @Published var lastAuthenticationDate: Date?
    @Published var isLoading: Bool = false
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    @Published var authenticationStatus: BiometricAuthenticationStatus = .notAuthenticated
    @Published var lockoutTimeRemaining: TimeInterval?
    @Published var failedAttempts: Int = 0
    @Published var policyConfiguration: BiometricPolicyConfiguration = .default
    
    // Authentication flow states
    @Published var showBiometricSetup: Bool = false
    @Published var showFallbackAuthentication: Bool = false
    @Published var requiresAuthentication: Bool = false
    
    // MARK: - Dependencies
    
    private let biometricManager: BiometricAuthenticationManager
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init(biometricManager: BiometricAuthenticationManager = BiometricAuthenticationManager.shared) {
        self.biometricManager = biometricManager
        setupObservers()
        updateState()
    }
    
    // MARK: - Setup
    
    private func setupObservers() {
        // Observe biometric manager state changes
        biometricManager.$isEnabled
            .receive(on: DispatchQueue.main)
            .assign(to: \.isEnabled, on: self)
            .store(in: &cancellables)
        
        biometricManager.$isAvailable
            .receive(on: DispatchQueue.main)
            .assign(to: \.isAvailable, on: self)
            .store(in: &cancellables)
        
        biometricManager.$biometricType
            .receive(on: DispatchQueue.main)
            .assign(to: \.biometricType, on: self)
            .store(in: &cancellables)
        
        biometricManager.$lastAuthenticationDate
            .receive(on: DispatchQueue.main)
            .assign(to: \.lastAuthenticationDate, on: self)
            .store(in: &cancellables)
        
        biometricManager.$failedAttempts
            .receive(on: DispatchQueue.main)
            .assign(to: \.failedAttempts, on: self)
            .store(in: &cancellables)
        
        biometricManager.$policyConfiguration
            .receive(on: DispatchQueue.main)
            .assign(to: \.policyConfiguration, on: self)
            .store(in: &cancellables)
        
        // Update lockout time remaining periodically
        Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateLockoutTimeRemaining()
            }
            .store(in: &cancellables)
        
        // Update authentication status based on state changes
        Publishers.CombineLatest3(
            biometricManager.$isEnabled,
            biometricManager.$lastAuthenticationDate,
            biometricManager.$lockoutEndTime
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] _, _, _ in
            self?.updateAuthenticationStatus()
        }
        .store(in: &cancellables)
    }
    
    private func updateState() {
        biometricManager.updateBiometricAvailability()
        updateAuthenticationStatus()
        updateLockoutTimeRemaining()
    }
    
    private func updateAuthenticationStatus() {
        if biometricManager.isLockedOut {
            authenticationStatus = .lockedOut
        } else if isRecentlyAuthenticated {
            authenticationStatus = .authenticated
        } else if isEnabled {
            authenticationStatus = .requiresAuthentication
        } else {
            authenticationStatus = .notAuthenticated
        }
    }
    
    private func updateLockoutTimeRemaining() {
        lockoutTimeRemaining = biometricManager.lockoutTimeRemaining
    }
    
    // MARK: - Authentication Actions
    
    func authenticate(reason: String = "Authenticate to access PropDocs") async {
        isLoading = true
        errorMessage = ""
        showError = false
        
        let result = await biometricManager.authenticate(reason: reason)
        
        switch result {
        case .success:
            authenticationStatus = .authenticated
        case .failure(let error):
            await handleAuthenticationError(error, reason: reason)
        }
        
        isLoading = false
    }
    
    func enableBiometricAuthentication() async -> Bool {
        isLoading = true
        errorMessage = ""
        showError = false
        
        let result = await biometricManager.enableBiometricAuthentication()
        
        isLoading = false
        
        switch result {
        case .success:
            return true
        case .failure(let error):
            await handleAuthenticationError(error)
            return false
        }
    }
    
    func disableBiometricAuthentication() {
        biometricManager.disableBiometricAuthentication()
        authenticationStatus = .notAuthenticated
    }
    
    func resetLockout() {
        biometricManager.resetLockout()
        updateAuthenticationStatus()
    }
    
    // MARK: - Policy Management
    
    func setPolicyConfiguration(_ configuration: BiometricPolicyConfiguration) {
        biometricManager.setPolicyConfiguration(configuration)
    }
    
    func setStrictPolicy() {
        setPolicyConfiguration(.strict)
    }
    
    func setRelaxedPolicy() {
        setPolicyConfiguration(.relaxed)
    }
    
    func setDefaultPolicy() {
        setPolicyConfiguration(.default)
    }
    
    // MARK: - UI Actions
    
    func presentBiometricSetup() {
        showBiometricSetup = true
    }
    
    func dismissBiometricSetup() {
        showBiometricSetup = false
    }
    
    func presentFallbackAuthentication() {
        showFallbackAuthentication = true
    }
    
    func dismissFallbackAuthentication() {
        showFallbackAuthentication = false
    }
    
    func dismissError() {
        showError = false
        errorMessage = ""
    }
    
    // MARK: - Error Handling
    
    private func handleAuthenticationError(_ error: BiometricAuthenticationError, reason: String? = nil) async {
        switch error {
        case .userCancel, .systemCancel:
            // User cancelled, don't show error but might need fallback
            if policyConfiguration.requireBiometrics {
                showFallbackAuthentication = true
            }
        case .userFallback:
            // User chose fallback, present fallback authentication
            showFallbackAuthentication = true
        case .biometryLockout:
            authenticationStatus = .lockedOut
            if policyConfiguration.allowFallback {
                showFallbackAuthentication = true
            } else {
                errorMessage = error.localizedDescription
                showError = true
            }
        case .biometryNotEnrolled:
            if isAvailable {
                showBiometricSetup = true
            } else {
                errorMessage = error.localizedDescription
                showError = true
            }
        case .authenticationFailed:
            if shouldShowFallback(after: error) {
                showFallbackAuthentication = true
            } else {
                errorMessage = error.localizedDescription
                showError = true
            }
        default:
            errorMessage = error.localizedDescription
            showError = true
        }
        
        authenticationStatus = .requiresAuthentication
    }
    
    private func shouldShowFallback(after error: BiometricAuthenticationError) -> Bool {
        return policyConfiguration.allowFallback && 
               !biometricManager.isLockedOut &&
               failedAttempts < policyConfiguration.maxAttempts
    }
    
    // MARK: - Computed Properties
    
    var canUseBiometrics: Bool {
        return biometricManager.canUseBiometrics
    }
    
    var isLockedOut: Bool {
        return biometricManager.isLockedOut
    }
    
    var isRecentlyAuthenticated: Bool {
        guard let lastAuth = lastAuthenticationDate else { return false }
        return Date().timeIntervalSince(lastAuth) < 300 // 5 minutes
    }
    
    var biometricStatusDescription: String {
        return biometricManager.biometricStatusDescription
    }
    
    var setupGuidanceText: String {
        return biometricManager.getBiometricSetupGuidance()
    }
    
    var lockoutStatusText: String {
        if let timeRemaining = lockoutTimeRemaining {
            let minutes = Int(timeRemaining / 60)
            let seconds = Int(timeRemaining.truncatingRemainder(dividingBy: 60))
            
            if minutes > 0 {
                return "Locked out for \(minutes)m \(seconds)s"
            } else {
                return "Locked out for \(seconds)s"
            }
        }
        return "Not locked out"
    }
    
    var authenticationButtonTitle: String {
        switch authenticationStatus {
        case .notAuthenticated:
            return "Enable \(biometricType.displayName)"
        case .requiresAuthentication:
            return "Authenticate with \(biometricType.displayName)"
        case .authenticated:
            return "\(biometricType.displayName) Verified"
        case .lockedOut:
            return "Locked Out"
        }
    }
    
    var authenticationButtonColor: Color {
        switch authenticationStatus {
        case .notAuthenticated:
            return .blue
        case .requiresAuthentication:
            return .orange
        case .authenticated:
            return .green
        case .lockedOut:
            return .red
        }
    }
    
    var canAuthenticate: Bool {
        return !isLoading && 
               isAvailable && 
               !isLockedOut && 
               authenticationStatus != .authenticated
    }
    
    // MARK: - Helper Methods
    
    func refreshAvailability() {
        biometricManager.updateBiometricAvailability()
        updateState()
    }
    
    func simulateLockout() {
        // For testing purposes only
        #if DEBUG
        biometricManager.lockoutEndTime = Date().addingTimeInterval(60) // 1 minute lockout
        updateAuthenticationStatus()
        #endif
    }
    
    func clearAuthentication() {
        authenticationStatus = .requiresAuthentication
    }
}

// MARK: - Biometric Authentication Status

enum BiometricAuthenticationStatus: Equatable {
    case notAuthenticated
    case requiresAuthentication
    case authenticated
    case lockedOut
    
    var description: String {
        switch self {
        case .notAuthenticated:
            return "Not Authenticated"
        case .requiresAuthentication:
            return "Authentication Required"
        case .authenticated:
            return "Authenticated"
        case .lockedOut:
            return "Locked Out"
        }
    }
    
    var systemImage: String {
        switch self {
        case .notAuthenticated:
            return "person.crop.circle"
        case .requiresAuthentication:
            return "person.crop.circle.badge.exclamationmark"
        case .authenticated:
            return "person.crop.circle.badge.checkmark"
        case .lockedOut:
            return "person.crop.circle.badge.xmark"
        }
    }
}

// MARK: - Preview Helpers

extension BiometricViewModel {
    
    static var preview: BiometricViewModel {
        let viewModel = BiometricViewModel()
        return viewModel
    }
    
    static var previewEnabled: BiometricViewModel {
        let viewModel = BiometricViewModel()
        viewModel.isEnabled = true
        viewModel.isAvailable = true
        viewModel.biometricType = .faceID
        viewModel.authenticationStatus = .authenticated
        return viewModel
    }
    
    static var previewLockedOut: BiometricViewModel {
        let viewModel = BiometricViewModel()
        viewModel.isEnabled = true
        viewModel.isAvailable = true
        viewModel.biometricType = .touchID
        viewModel.authenticationStatus = .lockedOut
        viewModel.lockoutTimeRemaining = 120
        return viewModel
    }
}