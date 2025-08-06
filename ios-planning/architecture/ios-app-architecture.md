# PropDocs iOS Client Architecture

## Overview

PropDocs iOS client is built using modern iOS development practices with SwiftUI for the user interface and a clean architecture pattern optimized for API integration and offline-first functionality. This client-only architecture focuses on consuming RESTful APIs provided by the backend services.

## Architecture Pattern: MVVM + Repository + API Integration

```
┌─────────────────────────────────────────────────────────┐
│                    SwiftUI Views                        │
│  ┌─────────────────┐  ┌─────────────────────────────┐   │
│  │  Asset Views    │  │  Maintenance Views          │   │
│  │  - AssetList    │  │  - ScheduleView            │   │
│  │  - AssetDetail  │  │  - TaskView                 │   │
│  └─────────────────┘  └─────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
                           │
                           │ @ObservedObject / @StateObject
                           │
┌─────────────────────────────────────────────────────────┐
│                   View Models                           │
│  ┌─────────────────┐  ┌─────────────────────────────┐   │
│  │ AssetViewModel  │  │ MaintenanceViewModel        │   │
│  │ - @Published    │  │ - @Published                │   │
│  │ - API Calls     │  │ - Local Sync Logic          │   │
│  └─────────────────┘  └─────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
                           │
                           │ API Integration & Caching
                           │
┌─────────────────────────────────────────────────────────┐
│                   Repository Layer                      │
│  ┌─────────────────┐  ┌─────────────────────────────┐   │
│  │ AssetRepository │  │ MaintenanceRepository       │   │
│  │ - API + Cache   │  │ - API + Local Storage       │   │
│  │ UserRepository  │  │ PropertyRepository          │   │
│  └─────────────────┘  └─────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
                           │
                           │ Data Management
                           │
┌─────────────────────────────────────────────────────────┐
│                    Data Layer                           │
│  ┌─────────────────┐  ┌─────────────────────────────┐   │
│  │   Core Data     │  │    API Client               │   │
│  │ - Offline Cache │  │ - RESTful Endpoints         │   │
│  │ - Local Storage │  │ - Image Upload Service      │   │
│  └─────────────────┘  └─────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
                           │
                           │ External Services
                           │
┌─────────────────────────────────────────────────────────┐
│                 PropDocs API Backend                    │
│  - User Authentication    - Asset Management API        │
│  - AI Asset Identification - Maintenance Scheduling     │
│  - Property Report Generation - Push Notifications      │
└─────────────────────────────────────────────────────────┘
```

## Core Components

### 1. SwiftUI Views
- **Declarative UI**: SwiftUI for all user interface components
- **Reactive**: Views automatically update when data changes
- **Modular**: Reusable components for consistent design

### 2. View Models (ObservableObject)
- **State Management**: @Published properties for UI state
- **API Integration**: Coordinate with repositories for data fetching
- **Local State**: Handle offline state and loading indicators
- **Combine Integration**: Reactive programming for data flows

### 3. Repository Layer (API + Caching)
- **API Abstraction**: Clean interface for backend API consumption
- **Offline-First**: Cache API responses in Core Data for offline access
- **Sync Management**: Handle data synchronization between local and remote
- **Error Handling**: Robust error handling with fallback to cached data

### 4. Data Layer
- **Core Data**: Local persistence for offline-first architecture
- **API Client**: RESTful API integration with URLSession
- **Image Management**: Photo capture, processing, and upload to API
- **Background Sync**: Efficient data synchronization strategies

## Key Architectural Decisions

### API-First with Offline Support
- All business logic resides in the backend API
- Local Core Data serves as an intelligent cache
- Offline-first design ensures app functionality without network
- Background sync maintains data consistency

### SwiftUI + Combine
- Modern, reactive UI development
- Built-in state management with @Published properties
- Excellent performance and smooth animations
- Declarative approach reduces complexity

### Repository Pattern for API Integration
- Abstraction layer between ViewModels and data sources
- Handles both API calls and local caching
- Consistent error handling across all data operations
- Easy to mock for testing API interactions

### Protocol-Oriented Programming
- Mockable interfaces for all external dependencies
- Dependency injection friendly architecture
- Clean separation between API client and business logic
- Testable components throughout the stack

## Directory Structure

```
PropDocs/
├── App/
│   ├── PropDocsApp.swift           # App entry point
│   └── ContentView.swift           # Root content view
│
├── Views/
│   ├── Asset/
│   │   ├── AssetListView.swift
│   │   ├── AssetDetailView.swift
│   │   └── AddAssetView.swift
│   ├── Maintenance/
│   │   ├── MaintenanceScheduleView.swift
│   │   ├── TaskDetailView.swift
│   │   └── CalendarView.swift
│   ├── Property/
│   │   ├── PropertyDashboardView.swift
│   │   └── PropertyReportView.swift
│   └── Common/
│       ├── LoadingView.swift
│       └── ErrorView.swift
│
├── ViewModels/
│   ├── AssetViewModel.swift
│   ├── MaintenanceViewModel.swift
│   ├── PropertyViewModel.swift
│   └── UserViewModel.swift
│
├── Services/
│   ├── LocalNotificationService.swift
│   ├── PhotoService.swift
│   ├── SyncService.swift
│   └── ReportService.swift
│
├── Repositories/
│   ├── AssetRepository.swift
│   ├── MaintenanceRepository.swift
│   ├── PropertyRepository.swift
│   └── UserRepository.swift
│
├── Models/
│   ├── Asset.swift
│   ├── MaintenanceTask.swift
│   ├── Property.swift
│   └── User.swift
│
├── Network/
│   ├── APIClient.swift
│   ├── APIEndpoints.swift
│   ├── NetworkModels/
│   │   ├── AssetAPI.swift
│   │   ├── MaintenanceAPI.swift
│   │   └── PropertyAPI.swift
│   └── ImageUploadService.swift
│
├── CoreData/
│   ├── PropDocs.xcdatamodeld
│   ├── CoreDataStack.swift
│   └── Entities/
│
├── Utils/
│   ├── Extensions/
│   ├── Helpers/
│   └── Constants/
│
└── Resources/
    ├── Assets.xcassets
    ├── Localizable.strings
    └── Info.plist
```

## Performance Considerations

### Memory Management
- Weak references to prevent retain cycles
- Lazy loading for heavy content
- Image caching and resizing

### Network Optimization
- Background sync with API endpoints
- Efficient image upload with compression
- Retry logic for failed API requests
- Request batching for multiple operations

### Core Data Optimization
- NSFetchedResultsController for efficient lists
- Proper predicate and sort descriptor usage
- Background context for heavy operations

## Security Implementation

### Data Protection
- Keychain for API tokens and sensitive data storage
- App Transport Security (ATS) enabled for all API calls
- Certificate pinning for secure API communications
- Biometric authentication for app access

### User Privacy
- Granular permission requests (camera, photos, notifications)
- Local data encryption for cached API responses
- Privacy controls for property report sharing
- Secure token refresh and session management

## Testing Strategy

### Unit Tests
- ViewModels with mocked repositories
- Repository implementations with mocked API clients
- API client with mocked network responses
- Photo service and local notification logic

### Integration Tests
- Core Data caching of API responses
- API client with real network calls (test environment)
- Repository sync logic between API and Core Data
- End-to-end offline/online data flows

### UI Tests
- Critical user journeys (asset creation, task completion)
- API-dependent flows with network mocking
- Offline mode functionality
- Photo capture and upload workflows

## Scalability Considerations

### Modular Architecture
- Feature-based modules
- Protocol-driven interfaces
- Dependency injection container

### Performance Monitoring
- Analytics integration
- Crash reporting
- Performance metrics tracking

## API Integration Patterns

### Repository Pattern Implementation
```swift
protocol AssetRepositoryProtocol {
    func getAssets() async throws -> [Asset]
    func createAsset(_ asset: Asset) async throws -> Asset
    func updateAsset(_ asset: Asset) async throws -> Asset
    func deleteAsset(id: String) async throws
}

class AssetRepository: AssetRepositoryProtocol {
    private let apiClient: APIClient
    private let coreDataStack: CoreDataStack
    
    func getAssets() async throws -> [Asset] {
        // Try API first, fallback to cached data
        do {
            let assets = try await apiClient.getAssets()
            await cacheAssets(assets) // Cache in Core Data
            return assets
        } catch {
            return try await getCachedAssets() // Fallback to offline data
        }
    }
}
```

### Background Sync Strategy
- Use `BGAppRefreshTask` for periodic data synchronization
- Queue failed API requests for retry when network is available
- Conflict resolution for data modified offline
- Optimistic UI updates with rollback on API failure

This client-focused architecture provides a robust foundation for building a responsive, offline-capable iOS application that seamlessly integrates with the PropDocs API backend while maintaining excellent user experience even without network connectivity.