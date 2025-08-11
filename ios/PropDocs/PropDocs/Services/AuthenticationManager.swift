//
//  AuthenticationManager.swift
//  PropDocs
//
//  Created by Andrei Pop on 2025-08-06.
//

import Foundation
import CoreData

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

class AuthenticationManager: ObservableObject, @unchecked Sendable {
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
        guard let _ = keychainManager.accessToken,
              let userID = keychainManager.userID,
              let provider = keychainManager.authProvider else {
            authenticationStatus = .unauthenticated
            return
        }
        
        // Create AppUser from stored data
        let user = AppUser(
            id: userID,
            email: nil, // TODO: Store and retrieve user email from keychain
            name: nil,  // TODO: Store and retrieve user name from keychain
            profileImageURL: nil,
            provider: AuthenticationProvider(rawValue: provider.rawValue)
        )
        
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
        
        // Create AppUser for authentication state
        let appUser = AppUser(
            id: result.user.id,
            email: result.user.email,
            name: result.user.name,
            profileImageURL: result.user.profileImageURL,
            provider: result.user.provider
        )
        
        // TODO: Later, create or update Core Data User entity separately if needed
        
        DispatchQueue.main.async {
            self.authenticationStatus = .authenticated(user: appUser)
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
    
    // MARK: - Mock Authentication for Onboarding
    
    @MainActor
    func setMockAuthenticationForOnboarding() {
        authenticationStatus = .authenticated(user: AppUser.mockOnboardingUser)
    }
    
    // MARK: - Core Data User Management
    
    func getCoreDataUser() -> User? {
        guard let appUser = currentUser else { return nil }
        
        let context = CoreDataStack.shared.context
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        let userId = UUID(uuidString: appUser.id) ?? UUID()
        fetchRequest.predicate = NSPredicate(format: "id == %@", userId as CVarArg)
        
        do {
            let existingUsers = try context.fetch(fetchRequest)
            if let existingUser = existingUsers.first {
                return existingUser
            }
            
            // Create new Core Data User entity
            let coreDataUser = User(context: context)
            coreDataUser.id = UUID(uuidString: appUser.id) ?? UUID()
            coreDataUser.email = appUser.email
            coreDataUser.name = appUser.name
            coreDataUser.profileImageURL = appUser.profileImageURL
            coreDataUser.createdAt = appUser.createdAt
            coreDataUser.updatedAt = appUser.updatedAt
            
            try context.save()
            return coreDataUser
        } catch {
            print("Error creating or fetching Core Data User: \(error)")
            return nil
        }
    }
}

// MARK: - Convenience Properties

extension AuthenticationManager {
    
    var isAuthenticated: Bool {
        authenticationStatus.isAuthenticated
    }
    
    var currentUser: AppUser? {
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