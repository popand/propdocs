# iOS Data Models Structure

Swift model definitions and data structures:

## Core Models (Mirror API Structure)
- **User.swift**: User profile and subscription information
- **Property.swift**: Property details and metadata
- **Asset.swift**: Asset specifications and condition tracking
- **MaintenanceSchedule.swift**: Maintenance schedules from API
- **MaintenanceTask.swift**: Individual maintenance tasks
- **ServiceRecord.swift**: Service history and documentation
- **ServiceProvider.swift**: Service provider contact information

## API Models (Codable for JSON)
- **AssetAPI.swift**: Asset API request/response models
- **MaintenanceAPI.swift**: Maintenance API request/response models
- **PropertyAPI.swift**: Property API request/response models
- **AuthAPI.swift**: Authentication API models
- **ReportAPI.swift**: Property report API models

## Local Models (Core Data)
- **LocalNotification.swift**: iOS notification models
- **SyncQueue.swift**: Pending API operation tracking
- **CachedImage.swift**: Local image storage models

## Enums & Constants
- **AssetCategory.swift**: Asset type and category enums
- **TaskStatus.swift**: Maintenance task status enums
- **SyncStatus.swift**: Data synchronization status
- **NotificationType.swift**: Local notification types
- **APIError.swift**: API error handling enums