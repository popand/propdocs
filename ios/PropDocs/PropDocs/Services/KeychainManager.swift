//
//  KeychainManager.swift
//  PropDocs
//
//  Created by Andrei Pop on 2025-08-06.
//

import Foundation
import LocalAuthentication
import Security

class KeychainManager {
    static let shared = KeychainManager()

    private init() {}

    // MARK: - Keychain Keys

    enum KeychainKey: String {
        case accessToken = "com.propdocs.app.access_token"
        case refreshToken = "com.propdocs.app.refresh_token"
        case userID = "com.propdocs.app.user_id"
        case biometricEnabled = "com.propdocs.app.biometric_enabled"
        case authProvider = "com.propdocs.app.auth_provider"
    }

    // MARK: - Generic Keychain Operations

    func save(_ value: String, for key: KeychainKey) -> Bool {
        let data = Data(value.utf8)
        return save(data, for: key)
    }

    func save(_ data: Data, for key: KeychainKey) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key.rawValue,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
        ]

        // Delete any existing item
        _ = delete(key)

        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }

    func retrieve(for key: KeychainKey) -> String? {
        guard let data = retrieveData(for: key) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    func retrieveData(for key: KeychainKey) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key.rawValue,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess else { return nil }
        return result as? Data
    }

    func delete(_ key: KeychainKey) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key.rawValue,
        ]

        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }

    func deleteAll() -> Bool {
        let queries: [[String: Any]] = [
            [kSecClass as String: kSecClassGenericPassword],
            [kSecClass as String: kSecClassInternetPassword],
            [kSecClass as String: kSecClassCertificate],
            [kSecClass as String: kSecClassKey],
            [kSecClass as String: kSecClassIdentity],
        ]

        var success = true
        for query in queries {
            let status = SecItemDelete(query as CFDictionary)
            if status != errSecSuccess, status != errSecItemNotFound {
                success = false
            }
        }

        return success
    }

    // MARK: - Secure Storage with Biometric Protection

    func saveBiometricProtected(_ value: String, for key: KeychainKey) -> Bool {
        let data = Data(value.utf8)
        return saveBiometricProtected(data, for: key)
    }

    func saveBiometricProtected(_ data: Data, for key: KeychainKey) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key.rawValue,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
        ]

        // Delete any existing item
        _ = delete(key)

        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }

    func retrieveBiometricProtected(for key: KeychainKey, prompt: String) async -> String? {
        guard let data = await retrieveBiometricProtectedData(for: key, prompt: prompt) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    func retrieveBiometricProtectedData(for key: KeychainKey, prompt: String) async -> Data? {
        let context = LAContext()
        context.localizedReason = prompt

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key.rawValue,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecUseAuthenticationContext as String: context,
        ]

        return await withCheckedContinuation { continuation in
            var result: AnyObject?
            let status = SecItemCopyMatching(query as CFDictionary, &result)

            if status == errSecSuccess {
                continuation.resume(returning: result as? Data)
            } else {
                continuation.resume(returning: nil)
            }
        }
    }
}

// MARK: - Authentication Token Management

extension KeychainManager {
    func saveTokens(accessToken: String, refreshToken: String?) -> Bool {
        let accessSaved = save(accessToken, for: .accessToken)
        let refreshSaved = refreshToken != nil ? save(refreshToken!, for: .refreshToken) : true
        return accessSaved && refreshSaved
    }

    var accessToken: String? {
        retrieve(for: .accessToken)
    }

    var refreshToken: String? {
        retrieve(for: .refreshToken)
    }

    func clearTokens() -> Bool {
        let accessDeleted = delete(.accessToken)
        let refreshDeleted = delete(.refreshToken)
        return accessDeleted && refreshDeleted
    }

    var userID: String? {
        get { retrieve(for: .userID) }
        set {
            if let value = newValue {
                _ = save(value, for: .userID)
            } else {
                _ = delete(.userID)
            }
        }
    }

    var authProvider: AuthenticationProvider? {
        get {
            guard let providerString = retrieve(for: .authProvider) else { return nil }
            return AuthenticationProvider(rawValue: providerString)
        }
        set {
            if let value = newValue {
                _ = save(value.rawValue, for: .authProvider)
            } else {
                _ = delete(.authProvider)
            }
        }
    }

    var isBiometricEnabled: Bool {
        get {
            guard let value = retrieve(for: .biometricEnabled) else { return false }
            return value == "true"
        }
        set {
            _ = save(newValue ? "true" : "false", for: .biometricEnabled)
        }
    }
}
