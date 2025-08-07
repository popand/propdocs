//
//  AuthenticationRepository.swift
//  PropDocs
//
//  Created by Andrei Pop on 2025-08-06.
//

import Foundation

protocol AuthenticationRepositoryProtocol {
    func exchangeTokenWithBackend(_ authResult: AuthenticationResult) async throws -> BackendAuthenticationResult
    func refreshBackendToken() async throws -> BackendAuthenticationResult
    func invalidateBackendSession() async throws
    func validateTokenWithBackend() async throws -> Bool
}

// MARK: - Backend Authentication Models

struct BackendAuthenticationResult {
    let accessToken: String
    let refreshToken: String
    let expiresIn: TimeInterval
    let user: BackendUser
}

struct BackendUser {
    let id: String
    let email: String
    let name: String?
    let profileImageURL: String?
    let createdAt: Date
    let updatedAt: Date
}

// MARK: - Authentication Repository Implementation

class AuthenticationRepository: AuthenticationRepositoryProtocol {
    private let apiClient: APIClient
    private let keychainManager = KeychainManager.shared

    init(apiClient: APIClient = APIClient.shared) {
        self.apiClient = apiClient
    }

    // MARK: - Backend Token Exchange

    func exchangeTokenWithBackend(_ authResult: AuthenticationResult) async throws -> BackendAuthenticationResult {
        let request = ExchangeTokenRequest(
            provider: authResult.user.provider.rawValue,
            idToken: authResult.accessToken,
            user: ExchangeTokenRequest.UserInfo(
                id: authResult.user.id,
                email: authResult.user.email,
                name: authResult.user.name,
                profileImageURL: authResult.user.profileImageURL
            )
        )

        let response = try await apiClient.post(
            endpoint: .exchangeAuthToken,
            body: request,
            responseType: ExchangeTokenResponse.self
        )

        let backendResult = BackendAuthenticationResult(
            accessToken: response.accessToken,
            refreshToken: response.refreshToken,
            expiresIn: response.expiresIn,
            user: BackendUser(
                id: response.user.id,
                email: response.user.email,
                name: response.user.name,
                profileImageURL: response.user.profileImageURL,
                createdAt: response.user.createdAt,
                updatedAt: response.user.updatedAt
            )
        )

        // Store backend tokens
        _ = keychainManager.saveTokens(
            accessToken: backendResult.accessToken,
            refreshToken: backendResult.refreshToken
        )

        return backendResult
    }

    func refreshBackendToken() async throws -> BackendAuthenticationResult {
        guard let refreshToken = keychainManager.refreshToken else {
            throw AuthenticationError.invalidCredentials
        }

        let request = RefreshTokenRequest(refreshToken: refreshToken)

        let response = try await apiClient.post(
            endpoint: .refreshToken,
            body: request,
            responseType: RefreshTokenResponse.self
        )

        let backendResult = BackendAuthenticationResult(
            accessToken: response.accessToken,
            refreshToken: response.refreshToken,
            expiresIn: response.expiresIn,
            user: BackendUser(
                id: response.user.id,
                email: response.user.email,
                name: response.user.name,
                profileImageURL: response.user.profileImageURL,
                createdAt: response.user.createdAt,
                updatedAt: response.user.updatedAt
            )
        )

        // Update stored tokens
        _ = keychainManager.saveTokens(
            accessToken: backendResult.accessToken,
            refreshToken: backendResult.refreshToken
        )

        return backendResult
    }

    func invalidateBackendSession() async throws {
        guard keychainManager.accessToken != nil else {
            return // Already signed out
        }

        let request = SignOutRequest()

        _ = try await apiClient.post(
            endpoint: .signOut,
            body: request,
            responseType: EmptyResponse.self,
            requiresAuth: true
        )

        // Clear stored tokens
        _ = keychainManager.clearTokens()
    }

    func validateTokenWithBackend() async throws -> Bool {
        guard keychainManager.accessToken != nil else {
            return false
        }

        do {
            let response = try await apiClient.get(
                endpoint: .validateToken,
                responseType: ValidateTokenResponse.self,
                requiresAuth: true
            )

            return response.isValid
        } catch {
            return false
        }
    }
}

// MARK: - API Request/Response Models

private struct ExchangeTokenRequest: Codable {
    let provider: String
    let idToken: String
    let user: UserInfo

    struct UserInfo: Codable {
        let id: String
        let email: String?
        let name: String?
        let profileImageURL: String?
    }
}

private struct ExchangeTokenResponse: Codable {
    let accessToken: String
    let refreshToken: String
    let expiresIn: TimeInterval
    let user: UserResponse

    struct UserResponse: Codable {
        let id: String
        let email: String
        let name: String?
        let profileImageURL: String?
        let createdAt: Date
        let updatedAt: Date
    }
}

private struct RefreshTokenRequest: Codable {
    let refreshToken: String
}

private struct RefreshTokenResponse: Codable {
    let accessToken: String
    let refreshToken: String
    let expiresIn: TimeInterval
    let user: ExchangeTokenResponse.UserResponse
}

private struct SignOutRequest: Codable {
    // Empty request body
}

private struct ValidateTokenResponse: Codable {
    let isValid: Bool
    let expiresAt: Date?
}

// MARK: - API Endpoints Extension

extension APIEndpoint {
    static let exchangeAuthToken = APIEndpoint(path: "/auth/exchange")
    static let refreshToken = APIEndpoint(path: "/auth/refresh")
    static let signOut = APIEndpoint(path: "/auth/signout")
    static let validateToken = APIEndpoint(path: "/auth/validate")
}

// MARK: - Error Handling Extension

extension AuthenticationRepository {
    private func handleAPIError(_ error: Error) -> AuthenticationError {
        if let apiError = error as? APIError {
            switch apiError {
            case .unauthorized:
                return .invalidCredentials
            case .networkError:
                return .networkError
            case let .serverError(message):
                return .failed(message)
            default:
                return .unknown
            }
        }

        return .failed(error.localizedDescription)
    }
}
