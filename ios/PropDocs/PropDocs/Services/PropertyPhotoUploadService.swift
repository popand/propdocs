//
//  PropertyPhotoUploadService.swift
//  PropDocs
//
//  Created by Andrei Pop on 2025-08-07.
//

import Foundation
import UIKit
import Combine
import CoreData

// MARK: - Property Photo Upload Service Protocol

protocol PropertyPhotoUploadServiceProtocol {
    func uploadPhoto(_ image: UIImage, for property: Property) async throws -> PropertyPhotoUploadResult
    func uploadPhotos(_ images: [UIImage], for property: Property) async throws -> [PropertyPhotoUploadResult]
    func deletePhoto(_ photoId: UUID) async throws
    func getUploadProgress(for photoId: UUID) -> AnyPublisher<UploadProgress, Never>
    func cancelUpload(for photoId: UUID)
    func retryFailedUpload(for photoId: UUID) async throws -> PropertyPhotoUploadResult
}

// MARK: - Upload Result Models

struct PropertyPhotoUploadResult {
    let photoId: UUID
    let localPath: String
    let thumbnailPath: String
    let remoteURL: String?
    let uploadStatus: UploadStatus
    let error: Error?
}

struct UploadProgress {
    let photoId: UUID
    let bytesUploaded: Int64
    let totalBytes: Int64
    let status: UploadStatus
    
    var percentage: Double {
        guard totalBytes > 0 else { return 0.0 }
        return min(Double(bytesUploaded) / Double(totalBytes), 1.0)
    }
}

enum UploadStatus: String, CaseIterable {
    case pending = "pending"
    case compressing = "compressing"
    case uploading = "uploading"
    case completed = "completed"
    case failed = "failed"
    case cancelled = "cancelled"
    
    var displayName: String {
        switch self {
        case .pending:
            return "Pending"
        case .compressing:
            return "Compressing"
        case .uploading:
            return "Uploading"
        case .completed:
            return "Completed"
        case .failed:
            return "Failed"
        case .cancelled:
            return "Cancelled"
        }
    }
}

// MARK: - Photo Compression Configuration

struct PhotoCompressionConfig {
    let maxFileSize: Int // in bytes
    let maxDimension: CGFloat
    let jpegQuality: CGFloat
    let thumbnailSize: CGSize
    let preserveMetadata: Bool
    
    static let `default` = PhotoCompressionConfig(
        maxFileSize: 5 * 1024 * 1024, // 5MB
        maxDimension: 2048,
        jpegQuality: 0.8,
        thumbnailSize: CGSize(width: 300, height: 300),
        preserveMetadata: false
    )
    
    static let highQuality = PhotoCompressionConfig(
        maxFileSize: 10 * 1024 * 1024, // 10MB
        maxDimension: 4096,
        jpegQuality: 0.9,
        thumbnailSize: CGSize(width: 400, height: 400),
        preserveMetadata: true
    )
    
    static let lowBandwidth = PhotoCompressionConfig(
        maxFileSize: 1 * 1024 * 1024, // 1MB
        maxDimension: 1024,
        jpegQuality: 0.6,
        thumbnailSize: CGSize(width: 200, height: 200),
        preserveMetadata: false
    )
}

// MARK: - Property Photo Upload Service Implementation

class PropertyPhotoUploadService: PropertyPhotoUploadServiceProtocol {
    
    // MARK: - Properties
    
    private let apiClient: APIClient
    private let fileManager = FileManager.default
    private let compressionConfig: PhotoCompressionConfig
    
    // Progress tracking
    private let progressSubject = PassthroughSubject<UploadProgress, Never>()
    private var activeUploads: [UUID: URLSessionUploadTask] = [:]
    private var uploadProgresses: [UUID: UploadProgress] = [:]
    
    // File paths
    private lazy var documentsDirectory: URL = {
        return fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    }()
    
    private lazy var photosDirectory: URL = {
        let url = documentsDirectory.appendingPathComponent("PropertyPhotos")
        try? fileManager.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }()
    
    private lazy var thumbnailsDirectory: URL = {
        let url = documentsDirectory.appendingPathComponent("PropertyThumbnails")
        try? fileManager.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }()
    
    // MARK: - Initialization
    
    init(
        apiClient: APIClient = APIClient.shared,
        compressionConfig: PhotoCompressionConfig = .default
    ) {
        self.apiClient = apiClient
        self.compressionConfig = compressionConfig
    }
    
    // MARK: - Public Methods
    
    func uploadPhoto(_ image: UIImage, for property: Property) async throws -> PropertyPhotoUploadResult {
        let photoId = UUID()
        
        // Update progress to compressing
        updateProgress(photoId: photoId, status: .compressing, bytesUploaded: 0, totalBytes: 0)
        
        do {
            // Compress and save image locally
            let (localPath, thumbnailPath, compressedData) = try await compressAndSaveImage(image, photoId: photoId)
            
            // Update progress to uploading
            updateProgress(photoId: photoId, status: .uploading, bytesUploaded: 0, totalBytes: Int64(compressedData.count))
            
            // Upload to server
            let remoteURL = try await uploadImageData(compressedData, photoId: photoId, propertyId: property.id!)
            
            // Update progress to completed
            updateProgress(photoId: photoId, status: .completed, bytesUploaded: Int64(compressedData.count), totalBytes: Int64(compressedData.count))
            
            return PropertyPhotoUploadResult(
                photoId: photoId,
                localPath: localPath,
                thumbnailPath: thumbnailPath,
                remoteURL: remoteURL,
                uploadStatus: .completed,
                error: nil
            )
            
        } catch {
            updateProgress(photoId: photoId, status: .failed, bytesUploaded: 0, totalBytes: 0)
            
            return PropertyPhotoUploadResult(
                photoId: photoId,
                localPath: "",
                thumbnailPath: "",
                remoteURL: nil,
                uploadStatus: .failed,
                error: error
            )
        }
    }
    
    func uploadPhotos(_ images: [UIImage], for property: Property) async throws -> [PropertyPhotoUploadResult] {
        var results: [PropertyPhotoUploadResult] = []
        
        for image in images {
            let result = try await uploadPhoto(image, for: property)
            results.append(result)
        }
        
        return results
    }
    
    func deletePhoto(_ photoId: UUID) async throws {
        // Cancel active upload if any
        cancelUpload(for: photoId)
        
        // Delete local files
        let photoPath = photosDirectory.appendingPathComponent("\(photoId.uuidString).jpg")
        let thumbnailPath = thumbnailsDirectory.appendingPathComponent("\(photoId.uuidString)_thumb.jpg")
        
        try? fileManager.removeItem(at: photoPath)
        try? fileManager.removeItem(at: thumbnailPath)
        
        // Delete from server (implement based on your API)
        // This would typically involve calling an API endpoint
        // try await apiClient.deletePropertyPhoto(photoId)
    }
    
    func getUploadProgress(for photoId: UUID) -> AnyPublisher<UploadProgress, Never> {
        return progressSubject
            .filter { $0.photoId == photoId }
            .eraseToAnyPublisher()
    }
    
    func cancelUpload(for photoId: UUID) {
        if let uploadTask = activeUploads[photoId] {
            uploadTask.cancel()
            activeUploads.removeValue(forKey: photoId)
            updateProgress(photoId: photoId, status: .cancelled, bytesUploaded: 0, totalBytes: 0)
        }
    }
    
    func retryFailedUpload(for photoId: UUID) async throws -> PropertyPhotoUploadResult {
        // Load the local image and retry upload
        let photoPath = photosDirectory.appendingPathComponent("\(photoId.uuidString).jpg")
        
        guard let imageData = try? Data(contentsOf: photoPath),
              let image = UIImage(data: imageData) else {
            throw PropertyPhotoUploadError.localFileNotFound
        }
        
        // For retry, we need to know which property this photo belongs to
        // This would typically be stored in your Core Data model
        throw PropertyPhotoUploadError.retryNotImplemented
    }
    
    // MARK: - Private Methods
    
    private func compressAndSaveImage(_ image: UIImage, photoId: UUID) async throws -> (String, String, Data) {
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                guard let self = self else {
                    continuation.resume(throwing: PropertyPhotoUploadError.compressionFailed)
                    return
                }
                
                do {
                    // Resize image if needed
                    let resizedImage = self.resizeImage(image, maxDimension: self.compressionConfig.maxDimension)
                    
                    // Compress to JPEG
                    guard let compressedData = resizedImage.jpegData(compressionQuality: self.compressionConfig.jpegQuality) else {
                        continuation.resume(throwing: PropertyPhotoUploadError.compressionFailed)
                        return
                    }
                    
                    // Check if we need further compression to meet file size limit
                    let finalData = self.compressToFileSize(compressedData, maxSize: self.compressionConfig.maxFileSize, originalImage: resizedImage)
                    
                    // Save full-size compressed image
                    let photoPath = self.photosDirectory.appendingPathComponent("\(photoId.uuidString).jpg")
                    try finalData.write(to: photoPath)
                    
                    // Create and save thumbnail
                    let thumbnail = self.createThumbnail(from: resizedImage, size: self.compressionConfig.thumbnailSize)
                    guard let thumbnailData = thumbnail.jpegData(compressionQuality: 0.8) else {
                        continuation.resume(throwing: PropertyPhotoUploadError.compressionFailed)
                        return
                    }
                    
                    let thumbnailPath = self.thumbnailsDirectory.appendingPathComponent("\(photoId.uuidString)_thumb.jpg")
                    try thumbnailData.write(to: thumbnailPath)
                    
                    continuation.resume(returning: (
                        photoPath.path,
                        thumbnailPath.path,
                        finalData
                    ))
                    
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    private func resizeImage(_ image: UIImage, maxDimension: CGFloat) -> UIImage {
        let size = image.size
        
        // Check if resizing is needed
        if size.width <= maxDimension && size.height <= maxDimension {
            return image
        }
        
        // Calculate new size maintaining aspect ratio
        let aspectRatio = size.width / size.height
        let newSize: CGSize
        
        if size.width > size.height {
            newSize = CGSize(width: maxDimension, height: maxDimension / aspectRatio)
        } else {
            newSize = CGSize(width: maxDimension * aspectRatio, height: maxDimension)
        }
        
        // Resize image
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage ?? image
    }
    
    private func compressToFileSize(_ data: Data, maxSize: Int, originalImage: UIImage) -> Data {
        if data.count <= maxSize {
            return data
        }
        
        // Gradually reduce quality until we meet the file size limit
        var quality: CGFloat = compressionConfig.jpegQuality
        var compressedData = data
        
        while compressedData.count > maxSize && quality > 0.1 {
            quality -= 0.1
            if let newData = originalImage.jpegData(compressionQuality: quality) {
                compressedData = newData
            }
        }
        
        return compressedData
    }
    
    private func createThumbnail(from image: UIImage, size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: size))
        let thumbnail = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return thumbnail ?? image
    }
    
    private func uploadImageData(_ data: Data, photoId: UUID, propertyId: UUID) async throws -> String {
        // This is a placeholder implementation
        // In a real app, you would implement the actual upload logic using your API client
        
        // Simulate upload progress
        let totalBytes = Int64(data.count)
        let chunkSize: Int64 = max(totalBytes / 10, 1024) // 10% chunks or 1KB minimum
        
        for uploaded in stride(from: Int64(0), through: totalBytes, by: chunkSize) {
            let bytesUploaded = min(uploaded + chunkSize, totalBytes)
            updateProgress(photoId: photoId, status: .uploading, bytesUploaded: bytesUploaded, totalBytes: totalBytes)
            
            // Simulate network delay
            try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        }
        
        // For now, return a mock URL
        // In a real implementation, this would be the actual server response
        return "https://api.propdocs.com/photos/\(photoId.uuidString).jpg"
    }
    
    private func updateProgress(photoId: UUID, status: UploadStatus, bytesUploaded: Int64, totalBytes: Int64) {
        let progress = UploadProgress(
            photoId: photoId,
            bytesUploaded: bytesUploaded,
            totalBytes: totalBytes,
            status: status
        )
        
        uploadProgresses[photoId] = progress
        progressSubject.send(progress)
    }
}

// MARK: - Property Photo Upload Errors

enum PropertyPhotoUploadError: Error, LocalizedError {
    case compressionFailed
    case localFileNotFound
    case uploadFailed(Error)
    case networkError
    case serverError(String)
    case retryNotImplemented
    case invalidImage
    case fileSizeTooLarge
    case diskSpaceFull
    
    var errorDescription: String? {
        switch self {
        case .compressionFailed:
            return "Failed to compress image"
        case .localFileNotFound:
            return "Local image file not found"
        case .uploadFailed(let error):
            return "Upload failed: \(error.localizedDescription)"
        case .networkError:
            return "Network error occurred during upload"
        case .serverError(let message):
            return "Server error: \(message)"
        case .retryNotImplemented:
            return "Retry functionality not implemented"
        case .invalidImage:
            return "Invalid image format"
        case .fileSizeTooLarge:
            return "Image file size is too large"
        case .diskSpaceFull:
            return "Not enough disk space to save image"
        }
    }
}

// MARK: - Utility Extensions

extension PropertyPhotoUploadService {
    
    // Get disk usage for property photos
    func getDiskUsage() -> (totalSize: Int64, photoCount: Int) {
        let photoFiles = (try? fileManager.contentsOfDirectory(at: photosDirectory, includingPropertiesForKeys: [.fileSizeKey])) ?? []
        let thumbnailFiles = (try? fileManager.contentsOfDirectory(at: thumbnailsDirectory, includingPropertiesForKeys: [.fileSizeKey])) ?? []
        
        let allFiles = photoFiles + thumbnailFiles
        let totalSize = allFiles.compactMap { url in
            try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize
        }.reduce(0, +)
        
        return (Int64(totalSize), photoFiles.count)
    }
    
    // Clean up old temporary files
    func cleanupTemporaryFiles() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                self.cleanupDirectory(self.photosDirectory, olderThan: 30) // 30 days
            }
            group.addTask {
                self.cleanupDirectory(self.thumbnailsDirectory, olderThan: 30)
            }
        }
    }
    
    private func cleanupDirectory(_ directory: URL, olderThan days: Int) {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        
        guard let files = try? fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: [.creationDateKey]) else {
            return
        }
        
        for file in files {
            guard let creationDate = try? file.resourceValues(forKeys: [.creationDateKey]).creationDate,
                  creationDate < cutoffDate else {
                continue
            }
            
            try? fileManager.removeItem(at: file)
        }
    }
}