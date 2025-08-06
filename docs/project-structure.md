# PropDocs iOS Client - Project Structure

## Current iOS Client Planning Structure

```
/Users/andreipop/Projects/propdocs/
├── README.md                 # Main project documentation
├── CLAUDE.md                # iOS client context for AI assistant
├── package.json             # Minimal Node.js setup for documentation tools
│
├── PRD/                     # Product Requirements Documents
│   ├── propdocs_prd.md
│   └── propdocs_prd2.md
│
├── docs/                    # Project documentation
│   └── project-structure.md
│
├── public/                  # Static assets and mockups
│   ├── images/
│   │   ├── dashboard-preview.png
│   │   └── modern-home.png
│   └── placeholder-*.{png,svg,jpg}
│
├── src/                     # iOS code structure planning
│   ├── components/          # SwiftUI view structure planning
│   ├── services/            # iOS services structure planning
│   ├── types/               # Swift model definitions planning
│   ├── utils/               # iOS utility functions planning
│   └── stores/              # State management planning
│
└── ios-planning/            # Comprehensive iOS development planning
    ├── architecture/        # iOS app architecture documents
    ├── data-models/         # Core Data models and schemas
    ├── screens/             # Screen layouts and navigation flows
    └── features/            # Detailed iOS implementation specifications
```

## iOS Development Structure

### `/PRD/` - Product Requirements
Contains all product requirement documents and specifications that guide iOS client development decisions.

### `/docs/` - Documentation
Technical documentation, architecture decisions, API integration guides, and iOS development guidelines.

### `/src/` - iOS Code Structure Planning
Planning structure for the future Xcode project organization:
- **components/**: SwiftUI view components and reusable UI elements  
- **services/**: iOS services (notifications, photo capture, API integration)
- **types/**: Swift model definitions and data structures
- **utils/**: Utility functions and extensions for iOS development
- **stores/**: State management and data flow (ObservableObject classes)

### `/ios-planning/` - Comprehensive iOS Planning
Detailed planning for native iOS development:
- **architecture/**: iOS-specific architecture documents with API integration patterns
- **data-models/**: Core Data models optimized for offline-first client architecture
- **screens/**: SwiftUI screen layouts and navigation flows
- **features/**: Detailed iOS client implementation specifications

### `/public/` - Assets and Mockups
Static assets that can be referenced during iOS development and design mockups.

## Development Workflow

### Current Phase: Planning & Documentation
- ✅ iOS architecture design with API integration patterns
- ✅ Core Data models for offline-first functionality  
- ✅ Feature breakdown focusing on client-side implementation
- ✅ Navigation flow and screen hierarchy planning

### Next Phase: iOS Development Setup
1. **Create Xcode Project**: Initialize new iOS project with SwiftUI
2. **Implement Architecture**: Set up MVVM + Repository pattern
3. **Core Data Setup**: Implement offline-first data layer
4. **API Integration**: Build networking layer with background sync
5. **Authentication**: Implement Apple/Google Sign In

### Implementation Phases

#### Phase 1: Foundation & API Integration (Weeks 1-4)
- iOS project setup with SwiftUI and Core Data
- Authentication implementation (Apple/Google Sign In)  
- API client architecture with offline caching
- Basic property setup and user management UI

#### Phase 2: Core Features & Sync (Weeks 5-10)
- Asset management UI with photo capture and API sync
- Maintenance scheduling with local notifications
- Service history tracking with document scanning
- Background sync implementation with retry logic

#### Phase 3: Real Estate & Sharing (Weeks 11-14)
- Property report generation and caching
- Share link creation with QR code generation
- Privacy controls and access management
- WKWebView integration for property showcase

#### Phase 4: Polish & Performance (Weeks 15-16)
- Dashboard and analytics with Swift Charts
- UI/UX optimization for iOS design guidelines
- Performance optimization for offline-first architecture
- App Store preparation and TestFlight distribution

## Key iOS Client Considerations

### Offline-First Architecture
- All data cached locally in Core Data
- Background sync with intelligent retry logic
- Optimistic UI updates with rollback capability
- Network-aware sync scheduling

### API Integration Strategy
- Repository pattern for clean API abstraction
- Robust error handling with offline fallbacks
- Background task management for data sync
- Secure token storage in iOS Keychain

### Native iOS Features
- UserNotifications framework for maintenance reminders
- PhotoKit/Camera integration for asset documentation
- VisionKit for document scanning
- EventKit for calendar integration
- Share sheet for report distribution

This structure provides a comprehensive roadmap for developing the PropDocs iOS client with proper planning, clear architecture, and native iOS integration patterns.