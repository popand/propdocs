//
//  PermissionsManager.swift
//  PropDocs
//
//  Created by Andrei Pop on 2025-08-07.
//

import Foundation
import AVFoundation
import Photos
import UserNotifications
import UIKit

// MARK: - Permission Types

enum PermissionType: String, CaseIterable {
    case camera = "camera"
    case photoLibrary = "photo_library"
    case notifications = "notifications"
    
    var displayName: String {
        switch self {
        case .camera:
            return "Camera"
        case .photoLibrary:
            return "Photo Library"
        case .notifications:
            return "Notifications"
        }
    }
    
    var description: String {
        switch self {
        case .camera:
            return "Take photos of your assets and property"
        case .photoLibrary:
            return "Select photos from your photo library"
        case .notifications:
            return "Receive maintenance reminders and alerts"
        }
    }
    
    var icon: String {
        switch self {
        case .camera:
            return "camera.fill"
        case .photoLibrary:
            return "photo.on.rectangle"
        case .notifications:
            return "bell.fill"
        }
    }
    
    var settingsMessage: String {
        switch self {
        case .camera:
            return "To use the camera, please enable Camera access in Settings > PropDocs > Camera"
        case .photoLibrary:
            return "To select photos, please enable Photo Library access in Settings > PropDocs > Photos"
        case .notifications:
            return "To receive notifications, please enable Notifications in Settings > PropDocs > Notifications"
        }
    }
}

// MARK: - Permission Status

enum PermissionStatus: String, Codable {
    case notDetermined = "not_determined"
    case denied = "denied"
    case authorized = "authorized"
    case limited = "limited"
    case restricted = "restricted"
    
    var isGranted: Bool {
        return self == .authorized || self == .limited
    }
    
    var canRequest: Bool {
        return self == .notDetermined
    }
    
    var displayName: String {
        switch self {
        case .notDetermined:
            return "Not Requested"
        case .denied:
            return "Denied"
        case .authorized:
            return "Authorized"
        case .limited:
            return "Limited Access"
        case .restricted:
            return "Restricted"
        }
    }
}

// MARK: - Permission Result

struct PermissionResult {
    let permission: PermissionType
    let status: PermissionStatus
    let error: PermissionError?
}

// MARK: - Permission Error

enum PermissionError: Error, LocalizedError {
    case denied
    case restricted
    case unknown(Error)
    case settingsRequired
    
    var errorDescription: String? {
        switch self {
        case .denied:
            return "Permission was denied by the user"
        case .restricted:
            return "Permission is restricted by system policies"
        case .unknown(let error):
            return "Unknown permission error: \(error.localizedDescription)"
        case .settingsRequired:
            return "Permission can only be changed in Settings"
        }
    }
}

// MARK: - Permissions Manager

@MainActor
class PermissionsManager: ObservableObject {
    static let shared = PermissionsManager()
    
    @Published private(set) var cameraStatus: PermissionStatus = .notDetermined
    @Published private(set) var photoLibraryStatus: PermissionStatus = .notDetermined
    @Published private(set) var notificationStatus: PermissionStatus = .notDetermined
    
    @Published private(set) var isCheckingPermissions = false
    
    // Throttling mechanism
    private var lastStatusCheckTime: Date?
    private let statusCheckThrottleInterval: TimeInterval = 5.0 // 5 seconds
    
    private init() {
        Task {
            await checkAllPermissionStatuses()
        }
    }
    
    // MARK: - Status Checking
    
    func getStatus(for permission: PermissionType) -> PermissionStatus {
        switch permission {
        case .camera:
            return cameraStatus
        case .photoLibrary:
            return photoLibraryStatus
        case .notifications:
            return notificationStatus
        }
    }
    
    func checkAllPermissionStatuses() async {
        // Check if we should throttle the status check
        if let lastCheck = lastStatusCheckTime,
           Date().timeIntervalSince(lastCheck) < statusCheckThrottleInterval {
            // Skip check if within throttle interval
            return
        }
        
        isCheckingPermissions = true
        lastStatusCheckTime = Date()
        
        async let camera = checkCameraStatus()
        async let photoLibrary = checkPhotoLibraryStatus()
        async let notifications = checkNotificationStatus()
        
        let (cameraResult, photoResult, notificationResult) = await (camera, photoLibrary, notifications)
        
        self.cameraStatus = cameraResult
        self.photoLibraryStatus = photoResult
        self.notificationStatus = notificationResult
        
        isCheckingPermissions = false
    }
    
    func forceRefreshPermissionStatuses() async {
        // Bypass throttling by clearing the last check time
        lastStatusCheckTime = nil
        await checkAllPermissionStatuses()
    }
    
    private func checkCameraStatus() async -> PermissionStatus {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        return mapAVAuthorizationStatus(status)
    }
    
    private func checkPhotoLibraryStatus() async -> PermissionStatus {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        return mapPHAuthorizationStatus(status)
    }
    
    private func checkNotificationStatus() async -> PermissionStatus {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return mapUNAuthorizationStatus(settings.authorizationStatus)
    }
    
    // MARK: - Permission Requests
    
    func requestPermission(for permission: PermissionType) async -> PermissionResult {
        switch permission {
        case .camera:
            return await requestCameraPermission()
        case .photoLibrary:
            return await requestPhotoLibraryPermission()
        case .notifications:
            return await requestNotificationPermission()
        }
    }
    
    private func requestCameraPermission() async -> PermissionResult {
        let currentStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        guard currentStatus == .notDetermined else {
            let status = mapAVAuthorizationStatus(currentStatus)
            cameraStatus = status
            
            if status == .denied || status == .restricted {
                return PermissionResult(permission: .camera, status: status, error: .settingsRequired)
            }
            
            return PermissionResult(permission: .camera, status: status, error: nil)
        }
        
        let granted = await AVCaptureDevice.requestAccess(for: .video)
        let newStatus: PermissionStatus = granted ? .authorized : .denied
        cameraStatus = newStatus
        
        let error: PermissionError? = granted ? nil : .denied
        return PermissionResult(permission: .camera, status: newStatus, error: error)
    }
    
    private func requestPhotoLibraryPermission() async -> PermissionResult {
        let currentStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        
        guard currentStatus == .notDetermined else {
            let status = mapPHAuthorizationStatus(currentStatus)
            photoLibraryStatus = status
            
            if status == .denied || status == .restricted {
                return PermissionResult(permission: .photoLibrary, status: status, error: .settingsRequired)
            }
            
            return PermissionResult(permission: .photoLibrary, status: status, error: nil)
        }
        
        return await withCheckedContinuation { continuation in
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                Task { @MainActor in
                    let mappedStatus = self.mapPHAuthorizationStatus(status)
                    self.photoLibraryStatus = mappedStatus
                    
                    let error: PermissionError?
                    switch status {
                    case .denied, .restricted:
                        error = .denied
                    default:
                        error = nil
                    }
                    
                    let result = PermissionResult(permission: .photoLibrary, status: mappedStatus, error: error)
                    continuation.resume(returning: result)
                }
            }
        }
    }
    
    private func requestNotificationPermission() async -> PermissionResult {
        let center = UNUserNotificationCenter.current()
        let currentSettings = await center.notificationSettings()
        
        guard currentSettings.authorizationStatus == .notDetermined else {
            let status = mapUNAuthorizationStatus(currentSettings.authorizationStatus)
            notificationStatus = status
            
            if status == .denied {
                return PermissionResult(permission: .notifications, status: status, error: .settingsRequired)
            }
            
            return PermissionResult(permission: .notifications, status: status, error: nil)
        }
        
        do {
            let options: UNAuthorizationOptions = [.alert, .badge, .sound, .provisional]
            let granted = try await center.requestAuthorization(options: options)
            
            let newStatus: PermissionStatus = granted ? .authorized : .denied
            notificationStatus = newStatus
            
            let error: PermissionError? = granted ? nil : .denied
            return PermissionResult(permission: .notifications, status: newStatus, error: error)
            
        } catch {
            notificationStatus = .denied
            return PermissionResult(permission: .notifications, status: .denied, error: .unknown(error))
        }
    }
    
    // MARK: - Settings Navigation
    
    func openAppSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(settingsUrl) else {
            return
        }
        
        UIApplication.shared.open(settingsUrl)
    }
    
    // MARK: - Convenience Methods
    
    var allPermissionsGranted: Bool {
        return cameraStatus.isGranted && 
               photoLibraryStatus.isGranted && 
               notificationStatus.isGranted
    }
    
    var criticalPermissionsGranted: Bool {
        return cameraStatus.isGranted && photoLibraryStatus.isGranted
    }
    
    func getPermissionsSummary() -> [PermissionType: PermissionStatus] {
        return [
            .camera: cameraStatus,
            .photoLibrary: photoLibraryStatus,
            .notifications: notificationStatus
        ]
    }
    
    func requestAllPermissions() async -> [PermissionResult] {
        var results: [PermissionResult] = []
        
        for permission in PermissionType.allCases {
            let result = await requestPermission(for: permission)
            results.append(result)
        }
        
        return results
    }
    
    // MARK: - Status Mapping
    
    private func mapAVAuthorizationStatus(_ status: AVAuthorizationStatus) -> PermissionStatus {
        switch status {
        case .notDetermined:
            return .notDetermined
        case .denied:
            return .denied
        case .authorized:
            return .authorized
        case .restricted:
            return .restricted
        @unknown default:
            return .denied
        }
    }
    
    private func mapPHAuthorizationStatus(_ status: PHAuthorizationStatus) -> PermissionStatus {
        switch status {
        case .notDetermined:
            return .notDetermined
        case .denied:
            return .denied
        case .authorized:
            return .authorized
        case .limited:
            return .limited
        case .restricted:
            return .restricted
        @unknown default:
            return .denied
        }
    }
    
    private func mapUNAuthorizationStatus(_ status: UNAuthorizationStatus) -> PermissionStatus {
        switch status {
        case .notDetermined:
            return .notDetermined
        case .denied:
            return .denied
        case .authorized, .provisional, .ephemeral:
            return .authorized
        @unknown default:
            return .denied
        }
    }
}

// MARK: - Permission Check Extensions

extension PermissionsManager {
    
    func canUseCamera() -> Bool {
        return cameraStatus.isGranted
    }
    
    func canAccessPhotoLibrary() -> Bool {
        return photoLibraryStatus.isGranted
    }
    
    func canSendNotifications() -> Bool {
        return notificationStatus.isGranted
    }
    
    func shouldShowPermissionRationale(for permission: PermissionType) -> Bool {
        let status = getStatus(for: permission)
        return status == .denied
    }
    
    func getPermissionActionTitle(for permission: PermissionType) -> String {
        let status = getStatus(for: permission)
        
        switch status {
        case .notDetermined:
            return "Grant Permission"
        case .denied, .restricted:
            return "Open Settings"
        case .authorized, .limited:
            return "Permission Granted"
        }
    }
}