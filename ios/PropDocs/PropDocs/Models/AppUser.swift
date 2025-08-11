//
//  AppUser.swift
//  PropDocs
//
//  Created by Andrei Pop on 2025-08-11.
//

import Foundation

struct AppUser: Codable, Equatable {
    let id: String
    let email: String?
    let name: String?
    let profileImageURL: String?
    let provider: AuthenticationProvider?
    let createdAt: Date
    let updatedAt: Date
    
    init(
        id: String,
        email: String? = nil,
        name: String? = nil,
        profileImageURL: String? = nil,
        provider: AuthenticationProvider? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.email = email
        self.name = name
        self.profileImageURL = profileImageURL
        self.provider = provider
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    // Mock user for onboarding completion
    static let mockOnboardingUser = AppUser(
        id: "mock_user_\(UUID().uuidString)",
        email: "demo@propdocs.com",
        name: "Demo User",
        profileImageURL: nil,
        provider: nil
    )
}