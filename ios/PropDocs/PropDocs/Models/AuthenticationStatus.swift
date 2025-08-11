//
//  AuthenticationStatus.swift
//  PropDocs
//
//  Created by Andrei Pop on 2025-08-06.
//

import Foundation

// Hooks are now properly configured and working!

enum AuthenticationStatus: Equatable {
    case authenticated(user: AppUser)
    case unauthenticated
    case loading

    static func == (lhs: AuthenticationStatus, rhs: AuthenticationStatus) -> Bool {
        switch (lhs, rhs) {
        case let (.authenticated(user1), .authenticated(user2)):
            return user1.id == user2.id
        case (.unauthenticated, .unauthenticated):
            return true
        case (.loading, .loading):
            return true
        default:
            return false
        }
    }

    var isAuthenticated: Bool {
        switch self {
        case .authenticated:
            return true
        case .unauthenticated, .loading:
            return false
        }
    }

    var user: AppUser? {
        switch self {
        case let .authenticated(user):
            return user
        case .unauthenticated, .loading:
            return nil
        }
    }
}

enum AuthenticationProvider: String, CaseIterable, Codable {
    case apple
    case google

    var displayName: String {
        switch self {
        case .apple:
            return "Apple"
        case .google:
            return "Google"
        }
    }
}

enum AuthenticationError: Error, LocalizedError {
    case cancelled
    case failed(String)
    case networkError
    case invalidCredentials
    case tokenExpired
    case unknown

    var errorDescription: String? {
        switch self {
        case .cancelled:
            return "Authentication was cancelled"
        case let .failed(message):
            return "Authentication failed: \(message)"
        case .networkError:
            return "Network error occurred during authentication"
        case .invalidCredentials:
            return "Invalid credentials provided"
        case .tokenExpired:
            return "Authentication token has expired"
        case .unknown:
            return "An unknown authentication error occurred"
        }
    }
}
