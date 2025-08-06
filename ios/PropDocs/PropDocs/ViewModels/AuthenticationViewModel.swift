//
//  AuthenticationViewModel.swift
//  PropDocs
//
//  Created by Andrei Pop on 2025-08-06.
//

import Foundation
import SwiftUI

@MainActor
class AuthenticationViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var authenticationStatus: AuthenticationStatus = .loading
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showError: Bool = false
    
    // MARK: - Dependencies
    
    private let authenticationManager: AuthenticationManager
    private let authenticationRepository: AuthenticationRepositoryProtocol
    
    // MARK: - Initialization
    
    init(
        authenticationManager: AuthenticationManager = AuthenticationManager.shared,
        authenticationRepository: AuthenticationRepositoryProtocol = AuthenticationRepository()
    ) {
        self.authenticationManager = authenticationManager
        self.authenticationRepository = authenticationRepository
        
        // Observe authentication status changes
        setupObservers()
    }
    
    // MARK: - Setup
    
    private func setupObservers() {
        // This would typically use Combine to observe authenticationManager.authenticationStatus
        // For now, we'll check periodically or use a different pattern
        Task {
            while !Task.isCancelled {
                let status = authenticationManager.authenticationStatus
                if status != authenticationStatus {
                    authenticationStatus = status
                }
                try? await Task.sleep(nanoseconds: 100_000_000) // Check every 0.1 seconds
            }
        }
    }
    
    // MARK: - Authentication Actions
    
    func signIn(with provider: AuthenticationProvider) async {
        isLoading = true
        errorMessage = nil
        showError = false
        
        do {
            // Step 1: Sign in with the provider (Apple/Google)
            try await authenticationManager.signIn(with: provider)
            
            // Step 2: Exchange token with backend (when implemented)
            // This will be implemented once the API client is ready
            /*
            if let authResult = getLastAuthResult() {
                let backendResult = try await authenticationRepository.exchangeTokenWithBackend(authResult)
                // Backend tokens are automatically stored in keychain
            }
            */
            
            isLoading = false
        } catch {
            await handleAuthenticationError(error)
        }
    }
    
    func signOut() async {
        isLoading = true
        errorMessage = nil
        showError = false
        
        // Sign out from backend first (when implemented)
        /*
        do {
            try await authenticationRepository.invalidateBackendSession()
        } catch {
            // Continue with local sign out even if backend fails
        }
        */
        
        // Then sign out locally
        await authenticationManager.signOut()
        
        isLoading = false
    }
    
    func refreshAuthentication() async {
        guard authenticationStatus.isAuthenticated else { return }
        
        do {
            try await authenticationManager.refreshAuthentication()
        } catch {
            await handleAuthenticationError(error)
        }
    }
    
    func validateToken() async {
        guard authenticationStatus.isAuthenticated else { return }
        
        do {
            let isValid = try await authenticationRepository.validateTokenWithBackend()
            if !isValid {
                await signOut()
            }
        } catch {
            // Token validation failed, sign out
            await signOut()
        }
    }
    
    // MARK: - Biometric Authentication
    
    func enableBiometricAuthentication() async -> Bool {
        guard authenticationStatus.isAuthenticated else { return false }
        
        return await authenticationManager.enableBiometricAuthentication()
    }
    
    func authenticateWithBiometrics() async -> Bool {
        guard authenticationManager.isBiometricEnabled else { return false }
        
        return await authenticationManager.authenticateWithBiometrics()
    }
    
    var isBiometricEnabled: Bool {
        authenticationManager.isBiometricEnabled
    }
    
    var isBiometricAvailable: Bool {
        // This should check if biometrics are available on the device
        // For now, we'll return true on supported devices
        return true
    }
    
    // MARK: - Error Handling
    
    private func handleAuthenticationError(_ error: Error) async {
        isLoading = false
        
        if let authError = error as? AuthenticationError {
            switch authError {
            case .cancelled:
                // User cancelled, don't show error
                return
            case .failed(let message):
                errorMessage = message
            case .networkError:
                errorMessage = "Network error. Please check your internet connection."
            case .invalidCredentials:
                errorMessage = "Invalid credentials. Please try signing in again."
            case .tokenExpired:
                errorMessage = "Your session has expired. Please sign in again."
            case .unknown:
                errorMessage = "An unknown error occurred. Please try again."
            }
        } else {
            errorMessage = error.localizedDescription
        }
        
        showError = true
    }
    
    // MARK: - Convenience Properties
    
    var isAuthenticated: Bool {
        authenticationStatus.isAuthenticated
    }
    
    var currentUser: User? {
        authenticationStatus.user
    }
    
    var isAppleSignInAvailable: Bool {
        // Check if Sign in with Apple is available
        return true // Will be properly implemented with capability
    }
    
    var isGoogleSignInAvailable: Bool {
        // Check if Google Sign In is configured
        return false // Currently not implemented
    }
    
    // MARK: - UI Helper Methods
    
    func dismissError() {
        showError = false
        errorMessage = nil
    }
    
    func getAuthenticationStatusText() -> String {
        switch authenticationStatus {
        case .authenticated(let user):
            return "Signed in as \(user.name ?? user.email ?? "User")"
        case .unauthenticated:
            return "Not signed in"
        case .loading:
            return "Loading..."
        }
    }
    
    func getProviderDisplayName(_ provider: AuthenticationProvider) -> String {
        return provider.displayName
    }
}

// MARK: - Preview Helpers

extension AuthenticationViewModel {
    
    static var preview: AuthenticationViewModel {
        let viewModel = AuthenticationViewModel()
        return viewModel
    }
    
    static var previewAuthenticated: AuthenticationViewModel {
        let viewModel = AuthenticationViewModel()
        let user = User()
        user.name = "John Doe"
        user.email = "john@example.com"
        viewModel.authenticationStatus = .authenticated(user: user)
        return viewModel
    }
    
    static var previewUnauthenticated: AuthenticationViewModel {
        let viewModel = AuthenticationViewModel()
        viewModel.authenticationStatus = .unauthenticated
        return viewModel
    }
}