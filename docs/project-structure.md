# PropDocs Project Structure

## Current Web Prototype Structure

```
/Users/andreipop/Projects/propdocs/
├── README.md                 # Main project documentation
├── CLAUDE.md                # Project context for AI assistant
├── package.json             # Node.js dependencies and scripts
├── tsconfig.json           # TypeScript configuration
├── tailwind.config.ts      # Tailwind CSS configuration
├── next.config.mjs         # Next.js configuration
├── components.json         # shadcn/ui component configuration
│
├── PRD/                    # Product Requirements Documents
│   ├── propdocs_prd.md
│   └── propdocs_prd2.md
│
├── docs/                   # Project documentation
│   └── project-structure.md
│
├── public/                 # Static assets
│   ├── images/
│   │   ├── dashboard-preview.png
│   │   └── modern-home.png
│   └── placeholder-*.{png,svg,jpg}
│
├── app/                    # Next.js App Router
│   ├── layout.tsx          # Root layout
│   ├── page.tsx            # Home page
│   ├── globals.css         # Global styles
│   └── loading.tsx         # Loading component
│
├── components/             # React components
│   ├── theme-provider.tsx
│   └── ui/                 # shadcn/ui components
│       ├── button.tsx
│       ├── card.tsx
│       ├── dialog.tsx
│       └── ...
│
├── hooks/                  # Custom React hooks
│   ├── use-mobile.tsx
│   └── use-toast.ts
│
├── lib/                    # Utility libraries
│   └── utils.ts
│
├── src/                    # Main source code (organized structure)
│   ├── components/         # Feature-specific components
│   ├── services/           # API and external service integrations
│   ├── types/              # TypeScript type definitions
│   ├── utils/              # Utility functions
│   └── stores/             # State management
│
└── ios-planning/           # iOS native development planning
    ├── architecture/       # iOS app architecture documents
    ├── data-models/        # Core Data models and schemas
    ├── screens/            # Screen layouts and navigation
    └── features/           # Feature specifications for iOS
```

## MVP Feature Organization

### Asset Management System
- `src/components/assets/` - Asset-related UI components
- `src/services/asset-service.ts` - Asset CRUD operations
- `src/types/asset.ts` - Asset type definitions
- `ios-planning/features/asset-management.md`

### Maintenance Scheduling
- `src/components/maintenance/` - Maintenance UI components
- `src/services/maintenance-service.ts` - Scheduling logic
- `src/types/maintenance.ts` - Maintenance type definitions
- `ios-planning/features/maintenance-scheduling.md`

### Property Showcase & Real Estate
- `src/components/property-showcase/` - Public dashboard components
- `src/services/property-report-service.ts` - Report generation
- `src/types/property-report.ts` - Report type definitions
- `ios-planning/features/real-estate-integration.md`

### User Management & Authentication
- `src/components/auth/` - Authentication components
- `src/services/auth-service.ts` - User authentication logic
- `src/types/user.ts` - User type definitions
- `ios-planning/features/user-management.md`

## Development Phases

### Phase 1: Web Prototype (Current)
- Next.js application for rapid prototyping
- shadcn/ui components for consistent design
- TypeScript for type safety
- Tailwind CSS for styling

### Phase 2: iOS Native Development
- Swift/SwiftUI native application
- Core Data for local storage
- CloudKit/Firebase for backend services
- Computer Vision APIs for asset identification

### Phase 3: Production & Scale
- App Store deployment
- Advanced analytics and monitoring
- Performance optimization
- Customer support integration

## Key Directories Explained

### `/PRD/` - Product Requirements
Contains all product requirement documents and specifications that guide development decisions.

### `/docs/` - Documentation
Technical documentation, architecture decisions, API specifications, and development guides.

### `/src/` - Organized Source Code
Clean, feature-based organization for scalable development:
- **components/**: Reusable UI components organized by feature
- **services/**: Business logic and external API integrations
- **types/**: TypeScript definitions for data models
- **utils/**: Helper functions and utilities
- **stores/**: State management (Context API, Zustand, or Redux)

### `/ios-planning/` - iOS Development Planning
Preparation for native iOS development:
- **architecture/**: iOS-specific architecture documents
- **data-models/**: Core Data models and relationships
- **screens/**: SwiftUI screen layouts and navigation flows
- **features/**: Detailed iOS implementation specifications

### `/components/ui/` - Design System
shadcn/ui components providing consistent design patterns across the application.

## Next Steps

1. **Complete web prototype** with core MVP features
2. **Validate user flows** and gather feedback
3. **Plan iOS architecture** based on web prototype learnings
4. **Begin iOS development** with Swift/SwiftUI
5. **Migrate and enhance** features for mobile-first experience

This structure supports both current web development and future iOS native development while maintaining clear separation of concerns and scalable organization.