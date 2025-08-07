//
//  PermissionsViewModel.swift
//  PropDocs
//
//  Created by Andrei Pop on 2025-08-07.
//

import Foundation
import SwiftUI

@MainActor
class PermissionsViewModel: ObservableObject {
    @Published private(set) var isLoading = false
    @Published private(set) var error: String?
    
    private let permissionsManager = PermissionsManager.shared
    
    // MARK: - Computed Properties
    
    var allPermissionsGranted: Bool {
        return permissionsManager.allPermissionsGranted
    }
    
    var criticalPermissionsGranted: Bool {
        return permissionsManager.criticalPermissionsGranted
    }
    
    // MARK: - Permission Status
    
    func getStatus(for permission: PermissionType) -> PermissionStatus {
        return permissionsManager.getStatus(for: permission)
    }
    
    func getPermissionsSummary() -> [PermissionType: PermissionStatus] {
        return permissionsManager.getPermissionsSummary()
    }
    
    // MARK: - Permission Requests
    
    func requestPermission(_ permission: PermissionType) async -> PermissionResult {
        isLoading = true
        error = nil
        
        defer {
            isLoading = false
        }
        
        do {
            let result = await permissionsManager.requestPermission(for: permission)
            
            if let permissionError = result.error {
                handlePermissionError(permissionError, for: permission)
            }
            
            return result
        }
    }
    
    func requestAllPermissions() async -> [PermissionResult] {
        isLoading = true
        error = nil
        
        defer {
            isLoading = false
        }
        
        let results = await permissionsManager.requestAllPermissions()
        
        // Handle any errors
        let errors = results.compactMap { $0.error }
        if !errors.isEmpty {
            let hasSettingsRequired = errors.contains { $0 as? PermissionError == .settingsRequired }
            if hasSettingsRequired {
                error = "Some permissions require manual enabling in Settings"
            } else {
                error = "Failed to request some permissions"
            }
        }
        
        return results
    }
    
    func checkAllPermissions() async {
        isLoading = true
        error = nil
        
        await permissionsManager.checkAllPermissionStatuses()
        
        isLoading = false
    }
    
    // MARK: - Settings Navigation
    
    func openSettings() {
        permissionsManager.openAppSettings()
    }
    
    // MARK: - Utility Methods
    
    func canUseCamera() -> Bool {
        return permissionsManager.canUseCamera()
    }
    
    func canAccessPhotoLibrary() -> Bool {
        return permissionsManager.canAccessPhotoLibrary()
    }
    
    func canSendNotifications() -> Bool {
        return permissionsManager.canSendNotifications()
    }
    
    func shouldShowPermissionRationale(for permission: PermissionType) -> Bool {
        return permissionsManager.shouldShowPermissionRationale(for: permission)
    }
    
    func getPermissionActionTitle(for permission: PermissionType) -> String {
        return permissionsManager.getPermissionActionTitle(for: permission)
    }
    
    // MARK: - Error Handling
    
    private func handlePermissionError(_ permissionError: PermissionError, for permission: PermissionType) {
        switch permissionError {
        case .denied:
            error = "\(permission.displayName) permission was denied"
        case .restricted:
            error = "\(permission.displayName) permission is restricted by system policies"
        case .settingsRequired:
            error = "\(permission.displayName) permission must be enabled in Settings"
        case .unknown(let underlyingError):
            error = "Failed to request \(permission.displayName) permission: \(underlyingError.localizedDescription)"
        }
    }
    
    func clearError() {
        error = nil
    }
    
    // MARK: - Permission-Specific Methods
    
    func requestCameraPermission() async -> PermissionResult {
        return await requestPermission(.camera)
    }
    
    func requestPhotoLibraryPermission() async -> PermissionResult {
        return await requestPermission(.photoLibrary)
    }
    
    func requestNotificationPermission() async -> PermissionResult {
        return await requestPermission(.notifications)
    }
    
    // MARK: - Permission Status Helpers
    
    func isPermissionGranted(_ permission: PermissionType) -> Bool {
        return getStatus(for: permission).isGranted
    }
    
    func canRequestPermission(_ permission: PermissionType) -> Bool {
        return getStatus(for: permission).canRequest
    }
    
    func getPermissionDisplayStatus(_ permission: PermissionType) -> String {
        return getStatus(for: permission).displayName
    }
    
    // MARK: - Validation Methods
    
    func validateCriticalPermissions() -> Bool {
        let cameraGranted = isPermissionGranted(.camera)
        let photoLibraryGranted = isPermissionGranted(.photoLibrary)
        
        return cameraGranted && photoLibraryGranted
    }
    
    func getMissingCriticalPermissions() -> [PermissionType] {
        var missing: [PermissionType] = []
        
        if !isPermissionGranted(.camera) {
            missing.append(.camera)
        }
        
        if !isPermissionGranted(.photoLibrary) {
            missing.append(.photoLibrary)
        }
        
        return missing
    }
    
    func getOptionalPermissions() -> [PermissionType] {
        return [.notifications]
    }
    
    // MARK: - UI State Helpers
    
    func shouldShowPermissionsScreen() -> Bool {
        return !criticalPermissionsGranted
    }
    
    func getPermissionsCompletionPercentage() -> Double {
        let total = PermissionType.allCases.count
        let granted = PermissionType.allCases.filter { isPermissionGranted($0) }.count
        
        return Double(granted) / Double(total)
    }
    
    func getPermissionsStatusDescription() -> String {
        let granted = PermissionType.allCases.filter { isPermissionGranted($0) }.count
        let total = PermissionType.allCases.count
        
        if granted == total {
            return "All permissions granted"
        } else if granted == 0 {
            return "No permissions granted"
        } else {
            return "\(granted) of \(total) permissions granted"
        }
    }
}