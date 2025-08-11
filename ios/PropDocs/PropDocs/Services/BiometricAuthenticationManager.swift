//
//  BiometricAuthenticationManager.swift
//  PropDocs
//
//  Created by Andrei Pop on 2025-08-06.
//

import Foundation
import LocalAuthentication
import SwiftUI

// MARK: - Biometric Authentication Types

enum BiometricType {
    case none
    case touchID
    case faceID
    case opticID
    
    var displayName: String {
        switch self {
        case .none:
            return "None Available"
        case .touchID:
            return "Touch ID"
        case .faceID:
            return "Face ID"
        case .opticID:
            return "Optic ID"
        }
    }
    
    var icon: String {
        switch self {
        case .none:
            return "lock"
        case .touchID:
            return "touchid"
        case .faceID:
            return "faceid"
        case .opticID:
            return "opticid"
        }
    }
}

enum BiometricAuthenticationError: Error, LocalizedError {
    case biometryNotAvailable
    case biometryNotEnrolled
    case biometryLockout
    case authenticationFailed
    case userCancel
    case userFallback
    case systemCancel
    case passcodeNotSet
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .biometryNotAvailable:
            return "Biometric authentication is not available on this device"
        case .biometryNotEnrolled:
            return "No biometric credentials are enrolled on this device"
        case .biometryLockout:
            return "Biometric authentication is locked out due to too many failed attempts"
        case .authenticationFailed:
            return "Biometric authentication failed"
        case .userCancel:
            return "User cancelled biometric authentication"
        case .userFallback:
            return "User chose to use fallback authentication"
        case .systemCancel:
            return "System cancelled biometric authentication"
        case .passcodeNotSet:
            return "Device passcode is not set"
        case .unknown(let error):
            return "Unknown biometric error: \(error.localizedDescription)"
        }
    }
}

// MARK: - Biometric Policy Configuration

struct BiometricPolicyConfiguration: Codable {
    let requireBiometrics: Bool
    let allowFallback: Bool
    let invalidateOnBiometryChange: Bool
    let touchIDTimeout: TimeInterval
    let maxAttempts: Int
    let lockoutDuration: TimeInterval
    
    static let `default` = BiometricPolicyConfiguration(
        requireBiometrics: false,
        allowFallback: true,
        invalidateOnBiometryChange: true,
        touchIDTimeout: 30.0,
        maxAttempts: 3,
        lockoutDuration: 300.0 // 5 minutes
    )
    
    static let strict = BiometricPolicyConfiguration(
        requireBiometrics: true,
        allowFallback: false,
        invalidateOnBiometryChange: true,
        touchIDTimeout: 15.0,
        maxAttempts: 2,
        lockoutDuration: 600.0 // 10 minutes
    )
    
    static let relaxed = BiometricPolicyConfiguration(
        requireBiometrics: false,
        allowFallback: true,
        invalidateOnBiometryChange: false,
        touchIDTimeout: 60.0,
        maxAttempts: 5,
        lockoutDuration: 180.0 // 3 minutes
    )
}

// MARK: - Biometric Authentication Manager

class BiometricAuthenticationManager: ObservableObject, @unchecked Sendable {
    static let shared = BiometricAuthenticationManager()
    
    @Published var isEnabled: Bool = false
    @Published var isAvailable: Bool = false
    @Published var biometricType: BiometricType = .none
    @Published var lastAuthenticationDate: Date?
    @Published var policyConfiguration: BiometricPolicyConfiguration = .default
    @Published var failedAttempts: Int = 0
    @Published var lockoutEndTime: Date?
    
    private let keychainManager = KeychainManager.shared
    
    // MARK: - Authentication Policies
    
    private var primaryPolicy: LAPolicy {
        return policyConfiguration.requireBiometrics 
            ? .deviceOwnerAuthenticationWithBiometrics 
            : .deviceOwnerAuthentication
    }
    
    private var fallbackPolicy: LAPolicy {
        return .deviceOwnerAuthentication
    }
    
    // MARK: - Policy Settings Keys
    
    private enum PolicyKeys {
        static let configuration = "biometric_policy_configuration"
        static let failedAttempts = "biometric_failed_attempts"
        static let lockoutEndTime = "biometric_lockout_end_time"
    }
    
    // MARK: - Initialization
    
    private init() {
        loadPolicyConfiguration()
        loadBiometricPreferences()
        updateBiometricAvailability()
    }
    
    // MARK: - Availability Check
    
    func updateBiometricAvailability() {
        let context = LAContext()
        var error: NSError?
        let isAvailable = context.canEvaluatePolicy(primaryPolicy, error: &error)
        
        DispatchQueue.main.async {
            self.isAvailable = isAvailable
            self.biometricType = self.getCurrentBiometricType()
        }
    }
    
    private func getCurrentBiometricType() -> BiometricType {
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(primaryPolicy, error: &error) else {
            return .none
        }
        
        switch context.biometryType {
        case .none:
            return .none
        case .touchID:
            return .touchID
        case .faceID:
            return .faceID
        case .opticID:
            if #available(iOS 17.0, *) {
                return .opticID
            } else {
                return .none
            }
        @unknown default:
            return .none
        }
    }
    
    // MARK: - Authentication Methods
    
    func authenticate(reason: String) async -> Result<Bool, BiometricAuthenticationError> {
        // Check if we're in lockout period
        if let lockoutEnd = lockoutEndTime, Date() < lockoutEnd {
            return .failure(.biometryLockout)
        }
        
        guard isAvailable else {
            return .failure(.biometryNotAvailable)
        }
        
        guard isEnabled else {
            return .failure(.biometryNotEnrolled)
        }
        
        // Create a fresh context for each authentication attempt
        let authContext = LAContext()
        authContext.localizedReason = reason
        authContext.localizedCancelTitle = "Cancel"
        
        // Configure fallback based on policy
        if policyConfiguration.allowFallback {
            authContext.localizedFallbackTitle = "Use Passcode"
        } else {
            authContext.localizedFallbackTitle = ""
        }
        
        // Configure timeout for Touch ID
        if biometricType == .touchID {
            authContext.touchIDAuthenticationAllowableReuseDuration = policyConfiguration.touchIDTimeout
        }
        
        do {
            let success = try await authContext.evaluatePolicy(primaryPolicy, localizedReason: reason)
            
            if success {
                await handleSuccessfulAuthentication()
                return .success(true)
            } else {
                await handleFailedAuthentication()
                return .failure(.authenticationFailed)
            }
        } catch {
            await handleFailedAuthentication()
            return .failure(mapLAError(error))
        }
    }
    
    func authenticateWithFallback(reason: String) async -> Result<Bool, BiometricAuthenticationError> {
        let authContext = LAContext()
        authContext.localizedReason = reason
        authContext.localizedCancelTitle = "Cancel"
        
        do {
            let success = try await authContext.evaluatePolicy(fallbackPolicy, localizedReason: reason)
            
            if success {
                DispatchQueue.main.async {
                    self.lastAuthenticationDate = Date()
                }
                return .success(true)
            } else {
                return .failure(.authenticationFailed)
            }
        } catch {
            return .failure(mapLAError(error))
        }
    }
    
    // MARK: - Authentication State Management
    
    @MainActor
    private func handleSuccessfulAuthentication() {
        lastAuthenticationDate = Date()
        failedAttempts = 0
        lockoutEndTime = nil
        savePolicyState()
    }
    
    @MainActor
    private func handleFailedAuthentication() {
        failedAttempts += 1
        
        if failedAttempts >= policyConfiguration.maxAttempts {
            lockoutEndTime = Date().addingTimeInterval(policyConfiguration.lockoutDuration)
        }
        
        savePolicyState()
    }
    
    // MARK: - Policy Configuration Management
    
    func setPolicyConfiguration(_ configuration: BiometricPolicyConfiguration) {
        DispatchQueue.main.async {
            self.policyConfiguration = configuration
            self.updateBiometricAvailability()
        }
        savePolicyConfiguration()
    }
    
    func resetLockout() {
        DispatchQueue.main.async {
            self.failedAttempts = 0
            self.lockoutEndTime = nil
        }
        savePolicyState()
    }
    
    var isLockedOut: Bool {
        if let lockoutEnd = lockoutEndTime {
            return Date() < lockoutEnd
        }
        return false
    }
    
    var lockoutTimeRemaining: TimeInterval? {
        if let lockoutEnd = lockoutEndTime, Date() < lockoutEnd {
            return lockoutEnd.timeIntervalSince(Date())
        }
        return nil
    }
    
    // MARK: - Settings Management
    
    func enableBiometricAuthentication() async -> Result<Bool, BiometricAuthenticationError> {
        guard isAvailable else {
            return .failure(.biometryNotAvailable)
        }
        
        // Test authentication first
        let result = await authenticate(reason: "Enable biometric authentication for secure access to PropDocs")
        
        switch result {
        case .success:
            DispatchQueue.main.async {
                self.isEnabled = true
            }
            saveBiometricPreferences()
            return .success(true)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func disableBiometricAuthentication() {
        DispatchQueue.main.async {
            self.isEnabled = false
            self.lastAuthenticationDate = nil
        }
        saveBiometricPreferences()
    }
    
    // MARK: - Persistence
    
    private func loadBiometricPreferences() {
        DispatchQueue.main.async {
            self.isEnabled = self.keychainManager.isBiometricEnabled
        }
    }
    
    private func saveBiometricPreferences() {
        keychainManager.isBiometricEnabled = isEnabled
    }
    
    private func loadPolicyConfiguration() {
        // Load policy configuration from UserDefaults
        if let data = UserDefaults.standard.data(forKey: PolicyKeys.configuration),
           let configuration = try? JSONDecoder().decode(BiometricPolicyConfiguration.self, from: data) {
            DispatchQueue.main.async {
                self.policyConfiguration = configuration
            }
        }
        
        // Load policy state
        let attempts = UserDefaults.standard.integer(forKey: PolicyKeys.failedAttempts)
        let lockoutTime = UserDefaults.standard.object(forKey: PolicyKeys.lockoutEndTime) as? Date
        
        DispatchQueue.main.async {
            self.failedAttempts = attempts
            self.lockoutEndTime = lockoutTime
        }
    }
    
    private func savePolicyConfiguration() {
        if let data = try? JSONEncoder().encode(policyConfiguration) {
            UserDefaults.standard.set(data, forKey: PolicyKeys.configuration)
        }
    }
    
    private func savePolicyState() {
        UserDefaults.standard.set(failedAttempts, forKey: PolicyKeys.failedAttempts)
        UserDefaults.standard.set(lockoutEndTime, forKey: PolicyKeys.lockoutEndTime)
    }
    
    // MARK: - Error Mapping
    
    private func mapLAError(_ error: Error) -> BiometricAuthenticationError {
        guard let laError = error as? LAError else {
            return .unknown(error)
        }
        
        switch laError.code {
        case .biometryNotAvailable:
            return .biometryNotAvailable
        case .biometryNotEnrolled:
            return .biometryNotEnrolled
        case .biometryLockout:
            return .biometryLockout
        case .authenticationFailed:
            return .authenticationFailed
        case .userCancel:
            return .userCancel
        case .userFallback:
            return .userFallback
        case .systemCancel:
            return .systemCancel
        case .passcodeNotSet:
            return .passcodeNotSet
        default:
            return .unknown(error)
        }
    }
    
    // MARK: - Utility Methods
    
    var canUseBiometrics: Bool {
        return isAvailable && biometricType != .none
    }
    
    var biometricStatusDescription: String {
        if !isAvailable {
            return "Biometric authentication is not available"
        }
        
        if !isEnabled {
            return "\(biometricType.displayName) is available but not enabled"
        }
        
        return "\(biometricType.displayName) is enabled and ready"
    }
    
    func getBiometricSetupGuidance() -> String {
        switch biometricType {
        case .none:
            return "Biometric authentication is not available on this device"
        case .touchID:
            return "To use Touch ID, go to Settings > Touch ID & Passcode and add your fingerprint"
        case .faceID:
            return "To use Face ID, go to Settings > Face ID & Passcode and set up face recognition"
        case .opticID:
            return "To use Optic ID, go to Settings > Optic ID & Passcode and set up eye recognition"
        }
    }
}

// MARK: - SwiftUI Integration

extension BiometricAuthenticationManager {
    
    func authenticateForUI(reason: String) async -> Bool {
        let result = await authenticate(reason: reason)
        switch result {
        case .success(let success):
            return success
        case .failure:
            return false
        }
    }
    
    var biometricIcon: Image {
        return Image(systemName: biometricType.icon)
    }
}