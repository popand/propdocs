# PropDocs iOS Client - Project Context

## Project Overview

PropDocs is a comprehensive property management iOS application built with SwiftUI and Core Data, designed to help users manage property assets, maintenance schedules, and documentation. The app follows a 16-week development timeline divided into 6 phases, with a focus on offline-first architecture and seamless user experience.


## Current Tech Stack
- iOS 17.0+ target
- SwiftUI primary framework
- Swift 5.9+
- Xcode 15+

## Key Requirements
- Comprehensive asset management system for property inventory, including:
  - Capture and storage of detailed asset information (type, make, model, specifications)
  - Photo documentation for each asset
  - Organization by category (HVAC, Plumbing, Electrical, Appliances, etc.)
  - Search and filter capabilities
  - Full offline functionality with automatic sync

- Intelligent maintenance scheduling:
  - AI-generated maintenance schedules based on asset type and manufacturer recommendations
  - Custom schedule creation and modification
  - Calendar view for upcoming tasks
  - Timely notifications and reminders
  - Task completion tracking with photos and notes
  - Offline task completion with sync

- Service history and documentation:
  - Tracking of all maintenance activities with detailed service records
  - Digital storage of receipts, warranties, and related documents
  - Service provider contact management and ratings
  - Generation of comprehensive property maintenance reports
  - Mobile document scanning and digitization
  - Export of service history for sales or insurance

- User management and property setup:
  - Secure authentication (Sign in with Apple, Google Sign In)
  - Biometric authentication (Face ID/Touch ID)
  - Property setup with address autocomplete and support for multiple properties
  - User preferences and profile management

- Property showcase and real estate integration:
  - Generation of professional property reports (asset inventory, maintenance history)
  - Secure, shareable links and QR code generation for listings
  - Customizable report content and privacy controls
  - Engagement analytics for shared reports
  - Public-facing property showcase interface

- Dashboard and analytics (P1):
  - Home dashboard with property health overview and recent activity
  - Visual charts for maintenance costs and trends
  - Health scores and color-coded indicators
  - iOS Calendar integration for maintenance tasks
  - Cost analytics and budget tracking

- Success criteria:
  - High user onboarding and engagement rates
  - Strong feature adoption (offline use, photo capture, report sharing)
  - Tangible business impact (reduced emergency costs, improved property sale outcomes, enhanced value demonstration)


## Agent Interaction Guidelines
- UX Engineer should be consulted for user flow and experience decisions
- UI Engineer should be consulted for visual design and component specifications  
- iOS Developer should be consulted for implementation and architecture decisions
- All agents should consider iOS Human Interface Guidelines
- Maintain consistency between agent recommendations


## Current Development Status

### ✅ **Completed Milestones**

#### **Milestone 1.1: Authentication & User Onboarding** (COMPLETE)
**Completed Components:**
- **Authentication System**: Full Sign in with Apple and Google Sign In integration
  - `AuthenticationManager.swift`: Central auth coordination with provider abstraction
  - `SignInWithAppleCoordinator.swift`: AuthenticationServices integration
  - `GoogleSignInManager.swift`: Google Sign In SDK implementation
  - `KeychainManager.swift`: Secure token storage with biometric protection
  - `AuthenticationRepository.swift`: API token exchange and management
  - `AuthenticationViewModel.swift`: Reactive state management

- **Biometric Authentication**: Complete Face ID/Touch ID system
  - `BiometricAuthenticationManager.swift`: LocalAuthentication framework integration
  - Policy configuration (default, strict, relaxed modes)
  - Fallback authentication and error handling
  - Lockout protection and retry mechanisms
  - Secure biometric preference storage

- **Onboarding Flow**: Multi-page welcome experience
  - `OnboardingFlowView.swift`: TabView-based page navigation
  - `OnboardingPageView.swift`: Reusable page components
  - `OnboardingViewModel.swift`: State management with completion tracking
  - Version-based tracking to prevent re-showing
  - Accessibility support with VoiceOver

- **Permissions Management**: Comprehensive permission handling
  - `PermissionsManager.swift`: Camera, photo library, and notifications
  - `PermissionsRequestView.swift`: Modern UI with clear explanations
  - `PermissionsViewModel.swift`: Reactive permission state management
  - Settings app navigation for denied permissions
  - Throttled permission checking for performance

#### **Milestone 1.2: Property Setup Infrastructure** (COMPLETE)
**Completed Components:**
- **Property Data Models**: 
  - `PropertyType.swift`: Comprehensive enum (house, condo, apartment, townhouse, commercial, land, other)
  - `PropertyAddress.swift`: Address validation, geocoding, and MapKit integration
  - `Property.swift`: Core Data extensions with computed properties and validation

- **Property Repository Layer**:
  - `PropertyRepository.swift`: Full CRUD operations with Combine publishers
  - Search functionality and sync status management
  - Active property switching with UserDefaults persistence
  - Comprehensive error handling and validation

- **Property State Management**:
  - `PropertyViewModel.swift`: Reactive view model with @Published properties
  - Form validation with real-time feedback
  - Search debouncing and multi-property support
  - Geocoding integration for address validation

- **Photo Upload Service**:
  - `PropertyPhotoUploadService.swift`: Image compression and progress tracking
  - Configurable compression settings (default, high-quality, low-bandwidth)
  - Thumbnail generation and local file management
  - Background upload support with retry mechanisms

### 🚧 **In Progress**

#### **Milestone 1.2: Property Setup & Profile Management** (PARTIAL)
**Remaining Tasks:**
- Address Autocomplete Implementation (0/8 tasks)
- Property Management Views (0/8 tasks) 
- User Profile Management (0/8 tasks)
- Settings Implementation (0/8 tasks)

### 📋 **Upcoming Milestones**

#### **Milestone 1.3: Core Data Setup & API Client Infrastructure**
- Core Data Foundation (0/8 tasks)
- API Client Architecture (0/8 tasks) 
- Network Monitoring (0/8 tasks)
- Background Sync Implementation (0/8 tasks)

## Architecture Overview

### **Project Structure**
```
ios/PropDocs/PropDocs/
├── Models/                    # Data models and enums
│   ├── PropertyType.swift     # Property categorization
│   ├── PropertyAddress.swift  # Address validation & geocoding
│   └── Property.swift         # Core Data extensions
├── Services/                  # Business logic services
│   ├── AuthenticationManager.swift
│   ├── BiometricAuthenticationManager.swift
│   ├── PermissionsManager.swift
│   └── PropertyPhotoUploadService.swift
├── Repositories/              # Data access layer
│   ├── AuthenticationRepository.swift
│   └── PropertyRepository.swift
├── ViewModels/               # State management
│   ├── AuthenticationViewModel.swift
│   ├── OnboardingViewModel.swift
│   ├── PermissionsViewModel.swift
│   └── PropertyViewModel.swift
├── Views/                    # SwiftUI views
│   ├── Onboarding/
│   └── Permissions/
├── Network/                  # API integration
│   └── APIClient.swift
└── PropDocsDataModel.xcdatamodeld
```

### **Design Patterns**
- **MVVM Architecture**: ViewModels with @Published properties for reactive UI
- **Repository Pattern**: Clean separation between data access and business logic
- **Service Layer**: Dedicated services for specific functionality (Auth, Permissions, etc.)
- **Combine Framework**: Reactive programming for data flow
- **Core Data**: Local persistence with sync status tracking

### **Key Technologies**
- **SwiftUI**: Primary UI framework (iOS 15.0+)
- **Core Data**: Local data persistence with offline-first approach
- **Combine**: Reactive programming and data binding
- **AuthenticationServices**: Sign in with Apple integration
- **LocalAuthentication**: Biometric authentication (Face ID/Touch ID)
- **Photos/PhotosUI**: Photo library and camera integration
- **UserNotifications**: Local and push notification support
- **MapKit**: Address autocomplete and location services

## Core Data Model

### **Entities**
- **User**: Authentication and profile information
- **Property**: Property details with address and type
- **Asset**: Property assets with photos and maintenance records
- **MaintenanceTask**: Scheduled and completed maintenance
- **ServiceProvider**: Contact information for service providers
- **AssetPhoto**: Photo storage with sync status

### **Relationships**
- User → Properties (one-to-many)
- Property → Assets (one-to-many)
- Property → MaintenanceTasks (one-to-many)
- Asset → AssetPhotos (one-to-many)
- Asset → MaintenanceTasks (one-to-many)
- MaintenanceTask → ServiceProvider (many-to-one)

## Authentication Flow

### **Supported Methods**
1. **Sign in with Apple**: Primary authentication method
2. **Google Sign In**: Secondary authentication option
3. **Biometric Authentication**: Optional Face ID/Touch ID

### **Security Features**
- Keychain secure token storage
- Automatic token refresh with background tasks
- Biometric authentication policies with lockout protection
- Backend token exchange for API integration

## Permission Management

### **Required Permissions**
- **Camera**: Asset photo capture and documentation
- **Photo Library**: Selecting existing photos for assets
- **Notifications**: Maintenance reminders and alerts

### **Features**
- Clear permission explanations with visual UI
- Settings app navigation for denied permissions
- Throttled permission checking for performance
- Real-time permission state updates

## Property Management

### **Property Types**
- House, Condominium, Apartment, Townhouse
- Commercial, Land, Other

### **Address Handling**
- Geocoding integration with CoreLocation
- MapKit placemark conversion
- Address validation and parsing
- Coordinate storage for mapping features

### **Multi-Property Support**
- Active property switching
- UserDefaults persistence for active selection
- Property statistics and overview

## Photo Upload System

### **Compression Settings**
- **Default**: 5MB max, 2048px, 0.8 quality
- **High Quality**: 10MB max, 4096px, 0.9 quality  
- **Low Bandwidth**: 1MB max, 1024px, 0.6 quality

### **Features**
- Automatic image resizing and compression
- Thumbnail generation (300x300px default)
- Progress tracking with upload status
- Local file management with cleanup utilities
- Background upload support

## Development Workflow

### **Git Workflow**
- Feature branches for each milestone/component
- Pull requests with comprehensive descriptions
- Automated code formatting with SwiftFormat
- SwiftLint integration for code quality

### **Code Quality**
- Claude Code hooks for automated formatting
- Comprehensive error handling and validation
- Accessibility support with VoiceOver
- iOS Human Interface Guidelines compliance

## API Integration Points

### **Authentication**
- User authentication and session management
- Token exchange and refresh operations
- Backend user profile synchronization

### **Property Management**
- Property CRUD operations with photo upload
- Multi-property support and active switching
- Address geocoding and validation

### **Future Integration**
- Asset CRUD operations with photo sync
- Maintenance schedule synchronization
- Property report generation and sharing
- Push notification delivery

## Testing Strategy

### **Unit Testing**
- Repository layer testing with mock data
- ViewModel testing with Combine publishers
- Service layer testing for business logic

### **Integration Testing**
- Core Data integration testing
- API client testing with mock responses
- Authentication flow testing

### **UI Testing**
- Onboarding flow automation
- Permission request flow testing
- Property creation and editing flows

## Performance Considerations

### **Targets**
- App launch time < 3 seconds
- 60fps scrolling in all list views
- Photo upload < 10 seconds
- Offline data access < 200ms
- 99.9% crash-free sessions

### **Optimizations**
- Lazy loading for large data sets
- Image caching and compression
- Background task management
- Memory management for photo operations

## Development Timeline

### **Phase 1: Foundation** (Weeks 1-3) - IN PROGRESS
- ✅ Authentication & Onboarding (Week 1) - COMPLETE
- 🚧 Property Setup & Profile (Week 2) - PARTIAL
- 📋 Core Data & API Infrastructure (Week 3) - PLANNED

### **Future Phases**
- **Phase 2**: Asset Management (Weeks 4-7)
- **Phase 3**: Maintenance System (Weeks 8-10)
- **Phase 4**: Service History (Weeks 11-12)
- **Phase 5**: Property Showcase (Weeks 13-14)
- **Phase 6**: Dashboard & Polish (Weeks 15-16)

## Recent Achievements

### **Pull Requests Created**
- **PR #3**: Onboarding Flow Implementation (MERGED)
- **PR #4**: Permissions Management System (OPEN)
- **PR #5**: Property Setup Infrastructure (OPEN)

### **Key Implementations**
- Complete authentication system with biometric support
- Comprehensive onboarding experience with accessibility
- Full permissions management with modern UI
- Property data models with Core Data integration
- Photo upload service with compression and progress tracking

## Next Steps

1. **Complete Milestone 1.2**: Finish Property Setup & Profile Management
   - Address Autocomplete with MapKit
   - Property Management Views (Setup, Type Selection, Multi-Property)
   - User Profile Management
   - Settings Implementation

2. **Begin Milestone 1.3**: Core Data & API Infrastructure
   - CoreDataStack setup with migration strategy
   - Comprehensive API client with retry logic
   - Network monitoring and offline support
   - Background sync implementation

3. **Asset Management Preparation**: Begin planning for Phase 2
   - Asset model design and repository
   - Camera integration and photo capture
   - Asset type classification and organization

This foundation provides a solid base for the comprehensive property management application, with scalable architecture and modern iOS development practices.