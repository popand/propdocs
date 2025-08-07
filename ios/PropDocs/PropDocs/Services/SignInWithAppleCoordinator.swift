//
//  SignInWithAppleCoordinator.swift
//  PropDocs
//
//  Created by Andrei Pop on 2025-08-06.
//

import AuthenticationServices
import CryptoKit
import Foundation
import UIKit

class SignInWithAppleCoordinator: NSObject, AuthenticationProviderProtocol {
    let provider: AuthenticationProvider = .apple

    private var currentNonce: String?
    private var continuation: CheckedContinuation<AuthenticationResult, Error>?

    // MARK: - AuthenticationProviderProtocol

    var isAvailable: Bool {
        // Sign in with Apple is available on iOS 13+ and when capability is enabled
        true // Will be false if capability is not configured
    }

    func signIn() async throws -> AuthenticationResult {
        try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation

            DispatchQueue.main.async {
                self.performAppleSignIn()
            }
        }
    }

    func signOut() async throws {
        // Apple doesn't provide a sign out method
        // Token invalidation is handled by the server
    }

    func refreshToken() async throws -> AuthenticationResult {
        // Apple doesn't provide token refresh
        // App should re-authenticate with Apple when needed
        throw AuthenticationError.failed("Apple Sign In doesn't support token refresh")
    }

    // MARK: - Private Methods

    private func performAppleSignIn() {
        let nonce = randomNonceString()
        currentNonce = nonce

        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }

    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }

            for random in randoms {
                if remainingLength == 0 {
                    continue
                }

                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }

        return result
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()

        return hashString
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension SignInWithAppleCoordinator: ASAuthorizationControllerDelegate {
    func authorizationController(
        controller _: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            continuation?.resume(throwing: AuthenticationError.failed("Invalid credential type"))
            return
        }

        guard let nonce = currentNonce else {
            continuation?
                .resume(throwing: AuthenticationError
                    .failed("Invalid state: A login callback was received, but no login request was sent."))
            return
        }

        guard let appleIDToken = appleIDCredential.identityToken else {
            continuation?.resume(throwing: AuthenticationError.failed("Unable to fetch identity token"))
            return
        }

        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            continuation?.resume(throwing: AuthenticationError.failed("Unable to serialize token string from data"))
            return
        }

        // Extract user information
        let userID = appleIDCredential.user
        let email = appleIDCredential.email
        let fullName = appleIDCredential.fullName

        // Combine first and last name
        var displayName: String?
        if let firstName = fullName?.givenName, let lastName = fullName?.familyName {
            displayName = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
            if displayName?.isEmpty == true {
                displayName = nil
            }
        }

        // Create authentication result
        let authenticatedUser = AuthenticationResult.AuthenticatedUser(
            id: userID,
            email: email,
            name: displayName,
            profileImageURL: nil, // Apple doesn't provide profile images
            provider: .apple
        )

        let result = AuthenticationResult(
            user: authenticatedUser,
            accessToken: idTokenString,
            refreshToken: nil, // Apple doesn't provide refresh tokens
            expiresIn: nil // Token expiration is handled by Apple
        )

        continuation?.resume(returning: result)
        continuation = nil
        currentNonce = nil
    }

    func authorizationController(controller _: ASAuthorizationController, didCompleteWithError error: Error) {
        let authError: AuthenticationError

        if let asError = error as? ASAuthorizationError {
            switch asError.code {
            case .canceled:
                authError = .cancelled
            case .failed:
                authError = .failed("Authentication failed")
            case .invalidResponse:
                authError = .failed("Invalid response from Apple")
            case .notHandled:
                authError = .failed("Request not handled")
            case .unknown:
                authError = .unknown
            @unknown default:
                authError = .unknown
            }
        } else {
            authError = .failed(error.localizedDescription)
        }

        continuation?.resume(throwing: authError)
        continuation = nil
        currentNonce = nil
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding

extension SignInWithAppleCoordinator: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for _: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first
        else {
            return ASPresentationAnchor()
        }
        return window
    }
}
