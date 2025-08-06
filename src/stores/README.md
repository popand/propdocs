# iOS State Management Structure

ObservableObject classes for SwiftUI state management:

## ViewModels (MVVM Pattern)
- **AssetViewModel.swift**: Asset management state and API integration
- **AssetListViewModel.swift**: Asset list filtering, searching, and pagination
- **MaintenanceViewModel.swift**: Maintenance scheduling and task management
- **TaskViewModel.swift**: Individual task completion and updates
- **PropertyReportViewModel.swift**: Report generation and sharing
- **ShareLinkViewModel.swift**: Link creation and privacy controls
- **AuthViewModel.swift**: Authentication state and user session
- **PropertyViewModel.swift**: Property setup and multi-property management
- **SettingsViewModel.swift**: User preferences and app settings

## Repository Classes
- **AssetRepository.swift**: Asset CRUD with API and Core Data integration
- **MaintenanceRepository.swift**: Maintenance schedules and task sync
- **PropertyRepository.swift**: Property data management
- **UserRepository.swift**: User profile and preferences
- **ServiceRepository.swift**: Service records and provider management
- **DocumentRepository.swift**: Document storage and sync
- **ReportRepository.swift**: Property report generation and caching

## State Stores
- **AppStateStore.swift**: Global app state (network status, sync status)
- **NotificationStore.swift**: Local notification management
- **CameraStore.swift**: Camera permissions and photo capture state