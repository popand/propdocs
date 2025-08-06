//
//  AuthenticationManager.swift
//  PropDocs
//
//  Created by Andrei Pop on 2025-08-06.
//

import Foundation

// MARK: - Authentication Provider Protocol

protocol AuthenticationProviderProtocol {
    var provider: AuthenticationProvider { get }
    
    func signIn() async throws -> AuthenticationResult
    func signOut() async throws
    func refreshToken() async throws -> AuthenticationResult
    var isAvailable: Bool { get }
}

// MARK: - Authentication Result

struct AuthenticationResult {
    let user: AuthenticatedUser
    let accessToken: String
    let refreshToken: String?
    let expiresIn: TimeInterval?
    
    struct AuthenticatedUser {
        let id: String
        let email: String?
        let name: String?
        let profileImageURL: String?
        let provider: AuthenticationProvider
    }
}

// MARK: - Main Authentication Manager

class AuthenticationManager: ObservableObject {
    static let shared = AuthenticationManager()
    
    @Published private(set) var authenticationStatus: AuthenticationStatus = .loading
    
    private let keychainManager = KeychainManager.shared
    private var authProviders: [AuthenticationProvider: AuthenticationProviderProtocol] = [:]
    private var tokenRefreshTask: Task<Void, Never>?
    
    private init() {
        setupAuthProviders()
        checkStoredAuthentication()
    }
    
    deinit {
        tokenRefreshTask?.cancel()
    }
    
    // MARK: - Setup
    
    private func setupAuthProviders() {
        // Register authentication providers
        let appleProvider = SignInWithAppleCoordinator()
        let googleProvider = GoogleSignInManager()
        
        authProviders[.apple] = appleProvider
        authProviders[.google] = googleProvider
    }
    
    private func checkStoredAuthentication() {
        Task {
            await checkExistingAuthentication()
        }
    }
    
    // MARK: - Public Authentication Methods
    
    func signIn(with provider: AuthenticationProvider) async throws {
        guard let authProvider = authProviders[provider] else {
            throw AuthenticationError.failed("Provider \(provider.displayName) not available")
        }
        
        guard authProvider.isAvailable else {
            throw AuthenticationError.failed("Provider \(provider.displayName) is not configured")
        }
        
        DispatchQueue.main.async {
            self.authenticationStatus = .loading
        }
        
        do {
            let result = try await authProvider.signIn()
            await handleAuthenticationSuccess(result)
        } catch {
            DispatchQueue.main.async {
                self.authenticationStatus = .unauthenticated
            }
            throw error
        }
    }
    
    func signOut() async {
        // Cancel any ongoing token refresh
        tokenRefreshTask?.cancel()
        
        // Sign out from current provider
        if let provider = keychainManager.authProvider,
           let authProvider = authProviders[provider] {
            try? await authProvider.signOut()
        }
        
        // Clear stored credentials
        _ = keychainManager.clearTokens()
        keychainManager.userID = nil
        keychainManager.authProvider = nil
        
        DispatchQueue.main.async {
            self.authenticationStatus = .unauthenticated
        }
    }
    
    func refreshAuthentication() async throws {
        guard let provider = keychainManager.authProvider,
              let authProvider = authProviders[provider] else {
            throw AuthenticationError.invalidCredentials
        }
        
        do {
            let result = try await authProvider.refreshToken()
            await handleAuthenticationSuccess(result)
        } catch {
            await signOut()
            throw error
        }
    }
    
    // MARK: - Private Methods
    
    @MainActor
    private func checkExistingAuthentication() async {
        // Check if we have stored tokens
        guard let accessToken = keychainManager.accessToken,
              let userID = keychainManager.userID,
              let provider = keychainManager.authProvider else {
            authenticationStatus = .unauthenticated
            return
        }
        
        // Create user from stored data
        let user = User()
        user.id = UUID(uuidString: userID) ?? UUID()
        user.authProvider = provider.rawValue
        
        authenticationStatus = .authenticated(user: user)
        
        // Start automatic token refresh
        startAutomaticTokenRefresh()
    }
    
    private func handleAuthenticationSuccess(_ result: AuthenticationResult) async {
        // Store tokens in keychain
        let tokensSaved = keychainManager.saveTokens(
            accessToken: result.accessToken,
            refreshToken: result.refreshToken
        )
        
        guard tokensSaved else {
            DispatchQueue.main.async {
                self.authenticationStatus = .unauthenticated
            }
            return
        }
        
        // Store user information
        keychainManager.userID = result.user.id
        keychainManager.authProvider = result.user.provider
        
        // Create or update user in Core Data
        let user = User()
        user.id = UUID(uuidString: result.user.id) ?? UUID()
        user.email = result.user.email
        user.name = result.user.name
        user.profileImageURL = result.user.profileImageURL
        user.authProvider = result.user.provider.rawValue
        user.updatedAt = Date()
        
        DispatchQueue.main.async {
            self.authenticationStatus = .authenticated(user: user)
        }
        
        // Start automatic token refresh
        startAutomaticTokenRefresh()
    }
    
    private func startAutomaticTokenRefresh() {
        // Cancel any existing refresh task
        tokenRefreshTask?.cancel()
        
        tokenRefreshTask = Task {
            // Refresh token every 30 minutes
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 30 * 60 * 1_000_000_000) // 30 minutes
                
                if !Task.isCancelled {
                    try? await refreshAuthentication()
                }
            }
        }
    }
}

// MARK: - Convenience Properties

extension AuthenticationManager {
    
    var isAuthenticated: Bool {
        authenticationStatus.isAuthenticated
    }
    
    var currentUser: User? {
        authenticationStatus.user
    }
    
    var accessToken: String? {
        keychainManager.accessToken
    }
}

// MARK: - Biometric Authentication Support

extension AuthenticationManager {
    
    var isBiometricEnabled: Bool {
        get { keychainManager.isBiometricEnabled }
        set { keychainManager.isBiometricEnabled = newValue }
    }
    
    func enableBiometricAuthentication() async -> Bool {
        guard let accessToken = keychainManager.accessToken else { return false }
        
        let success = keychainManager.saveBiometricProtected(accessToken, for: .accessToken)
        if success {
            keychainManager.isBiometricEnabled = true
        }
        return success
    }
    
    func authenticateWithBiometrics() async -> Bool {
        guard isBiometricEnabled else { return false }
        
        let prompt = "Use Face ID to access PropDocs"
        let token = await keychainManager.retrieveBiometricProtected(for: .accessToken, prompt: prompt)
        return token != nil
    }
}