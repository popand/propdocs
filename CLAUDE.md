# CLAUDE.md - PropDocs iOS Client Project Context

## Project Overview

PropDocs iOS Client is the native mobile application for the PropDocs property asset management system. This project focuses exclusively on the client-side iOS implementation that interfaces with an existing API backend. The app helps homeowners track, maintain, and manage household assets through an intuitive mobile interface.

**Target Platform:** iOS 15.0+ Mobile Application (Swift/SwiftUI)  
**Project Scope:** Client-side iOS application only (API backend provided separately)  
**Current Status:** Planning and architecture phase (web prototype for UI/UX validation)

## Product Vision

To become the definitive platform for residential asset management, enabling homeowners to maximize asset lifespan, minimize maintenance costs, and maintain detailed property documentation that enhances home value and buyer confidence.

## Core Value Propositions

1. **Proactive Maintenance:** Transform reactive home maintenance into proactive, data-driven approach
2. **Asset Documentation:** Comprehensive record-keeping for warranties, service history, and specifications  
3. **Property Value Enhancement:** Professional maintenance records that support premium pricing
4. **Real Estate Integration:** Shareable property reports for agents and potential buyers

## MVP Feature Priorities

### P0 Features (Must Have)
1. **Asset Management System**
   - Asset registration via photo capture with AI identification
   - Comprehensive asset profiles (type, make, model, serial number, warranties)
   - Asset categorization (HVAC, Plumbing, Electrical, Appliances, etc.)
   - Photo gallery documentation

2. **Intelligent Maintenance Scheduling**
   - AI-generated maintenance schedules based on asset type
   - Custom schedule creation and modification
   - Task management with completion tracking
   - Push notification system with configurable timing

3. **Service History & Documentation**
   - Comprehensive service logs
   - Document storage (photos, receipts, warranties, manuals)
   - Service provider directory
   - Export capabilities for property reports

4. **User Management & Property Setup**
   - Apple/Google ID integration
   - Multi-property support
   - Profile and notification preferences

5. **Property Showcase & Real Estate Integration**
   - Private property report generation
   - Shareable property links with privacy controls
   - Public property dashboard for real estate
   - QR codes and PDF export for MLS listings

### P1 Features (Should Have)
6. **Dashboard & Analytics**
   - Home dashboard with maintenance overview
   - Calendar view of maintenance schedule
   - Cost analytics and spending trends
   - Asset and house health scores

## Target Audience

### Primary Users
- **Homeowners** (ages 30-65) with single-family homes or condominiums
- **Property Investors** managing multiple rental properties  
- **Home Service Professionals** managing client assets
- **Real Estate Agents** showcasing well-maintained properties

### User Personas
- **Meticulous Mike:** Detail-oriented homeowner wanting comprehensive tracking
- **Busy Beth:** Working parent needing automated reminders and simple scheduling
- **Investor Ian:** Property manager overseeing multiple properties

## iOS Client Architecture

### Client-Side Focus
- **Target Platform:** iOS 15.0+ with Swift/SwiftUI native development
- **API Integration:** RESTful API consumption for all backend services
- **Local Storage:** Core Data for offline caching and data persistence
- **Media Handling:** Local photo capture, processing, and upload to API
- **State Management:** Combine framework with MVVM pattern

### API Integration Points
- **Authentication:** User login/registration via API
- **Asset Management:** CRUD operations for assets via REST endpoints
- **Maintenance Scheduling:** Schedule data sync with backend
- **AI Services:** Photo upload for server-side asset identification
- **Real Estate Reports:** Report generation and sharing via API

### Performance Requirements
- App launch time: < 3 seconds
- Photo upload time: < 10 seconds per image
- Offline capability for basic asset viewing and task completion
- Real-time sync when online via background refresh

## Subscription Model

### Free Tier
- Up to 5 assets
- Basic maintenance reminders
- Limited photo storage (10 photos total)

### Premium Tier - $9.99/month or $99.99/year
- Unlimited assets
- AI-powered asset identification
- Advanced maintenance scheduling
- Unlimited photo storage
- Export capabilities

### Professional Tier - $19.99/month or $199.99/year
- Multi-property management
- Service provider integration
- Advanced analytics and reporting
- API access for property managers

## iOS Client Development Roadmap

### Phase 1: Foundation (Client Infrastructure)
- iOS project setup and architecture implementation
- API client and authentication integration
- Core Data setup for offline storage
- Basic asset management UI and photo capture

### Phase 2: Core Features (Client-Side Implementation)
- Maintenance scheduling UI and local notifications
- Service history tracking and documentation
- Property showcase views and sharing flows
- Offline-first data synchronization

### Phase 3: Polish & Launch (Client Optimization)
- UI/UX optimization and accessibility compliance
- Performance optimization and testing
- App Store submission and deployment
- Analytics integration and crash reporting

## Success Metrics

- **User Acquisition:** 10,000+ active users within 12 months
- **Engagement:** 80% monthly active user retention rate
- **Value Creation:** 25% reduction in emergency maintenance costs for users

## iOS Development Guidelines

### Code Quality
- Follow iOS development best practices for Swift/SwiftUI
- Implement comprehensive error handling and user feedback
- Ensure accessibility compliance (VoiceOver, Dynamic Type)
- Write unit tests for ViewModels and business logic

### API Integration
- Implement robust error handling for network requests
- Use URLSession with proper timeout and retry logic
- Secure token storage in iOS Keychain
- Background task handling for data synchronization

### Local Data Management
- Core Data for offline-first architecture
- Efficient caching strategies for API responses
- Data migration handling for app updates
- Privacy-conscious local data encryption

### Testing Strategy
- Unit tests for ViewModels and API clients
- Integration tests for Core Data operations
- UI tests for critical user flows
- Network layer testing with mock responses

## Key Commands

### Documentation and Planning
```bash
# View iOS project documentation
npm run docs

# Validate documentation structure  
npm run validate
```

### iOS Development
```bash
# Build iOS app
xcodebuild -project PropDocs.xcodeproj -scheme PropDocs build

# Run tests
xcodebuild test -project PropDocs.xcodeproj -scheme PropDocs

# Archive for App Store
xcodebuild archive -project PropDocs.xcodeproj -scheme PropDocs
```

## Important Notes - iOS Client Focus

1. **Client-Only Scope:** This project handles only the iOS client; API backend is provided separately
2. **API-First Design:** All business logic resides in the API; client handles presentation and local caching
3. **Offline-First:** Local Core Data storage enables offline viewing with sync when online
4. **Photo Handling:** Capture and process photos locally, upload to API for server-side AI processing
5. **Real Estate Integration:** Client displays API-generated reports with sharing capabilities
6. **Push Notifications:** Local notifications for offline reminders, server push for real-time updates

## API Expectations

The iOS client expects a RESTful API with the following capabilities:
- User authentication and session management
- Asset CRUD operations with photo upload endpoints
- Maintenance scheduling and task management
- AI-powered asset identification from uploaded photos
- Property report generation and sharing
- Push notification delivery services

## PRD Reference

Full Product Requirements Document available at: `/PRD/propdocs_prd2.md`

Last Updated: August 6, 2025