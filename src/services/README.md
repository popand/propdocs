# iOS Services Structure

iOS-specific service classes for the PropDocs client:

## Core Services
- **AuthenticationService.swift**: Handle Apple/Google Sign In and token management
- **PhotoCaptureService.swift**: Camera integration and photo processing
- **LocalNotificationService.swift**: iOS UserNotifications framework integration
- **DocumentScanningService.swift**: VisionKit integration for receipt scanning

## API Integration Services  
- **APIClient.swift**: Core networking layer with URLSession
- **ImageUploadService.swift**: Photo and document upload to API
- **SyncService.swift**: Background synchronization with retry logic
- **TaskSyncService.swift**: Maintenance task sync with API

## Data Services
- **CoreDataStack.swift**: Core Data setup and management
- **KeychainService.swift**: Secure token and sensitive data storage
- **CacheService.swift**: Intelligent caching strategies

## Utility Services
- **QRCodeGenerationService.swift**: Core Image QR code generation
- **PDFGenerationService.swift**: PDFKit integration for reports
- **ShareService.swift**: iOS Share sheet integration
- **CalendarIntegrationService.swift**: EventKit integration