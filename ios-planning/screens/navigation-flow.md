# PropDocs iOS Navigation Flow & Screen Hierarchy

## App Navigation Structure

### Tab Bar Navigation (Primary Navigation)
```
┌─────────────────────────────────────────────────────────────┐
│                    Tab Bar Controller                       │
├─────────────────────────────────────────────────────────────┤
│  Home  │  Assets  │  Schedule  │  Reports  │  Settings      │
│   🏠   │    📦    │     📅     │    📊     │     ⚙️         │
└─────────────────────────────────────────────────────────────┘
```

### Navigation Hierarchy

#### 1. Home Tab 🏠
```
HomeView (Dashboard)
├── PropertySelectorView (if multiple properties)
├── UpcomingTasksView
│   └── TaskDetailView
│       ├── CompleteTaskView
│       └── RescheduleTaskView
├── RecentActivityView
│   └── ServiceRecordDetailView
├── PropertyHealthScoreView
└── QuickActionsView
    ├── AddAssetView
    └── AddTaskView
```

#### 2. Assets Tab 📦
```
AssetListView
├── AssetCategoryFilterView
├── AssetSearchView
├── AssetDetailView
│   ├── AssetEditView
│   ├── AssetPhotosView
│   │   ├── PhotoDetailView
│   │   └── AddPhotoView
│   ├── MaintenanceScheduleView
│   │   ├── ScheduleDetailView
│   │   └── AddScheduleView
│   └── ServiceHistoryView
│       └── ServiceRecordDetailView
└── AddAssetView
    ├── AssetCameraView
    ├── AssetPhotoPickerView
    └── AssetDetailsEntryView
```

#### 3. Schedule Tab 📅
```
MaintenanceScheduleView
├── CalendarView
│   ├── MonthView
│   ├── WeekView
│   └── DayView
├── TaskListView
│   ├── PendingTasksView
│   ├── OverdueTasksView
│   └── CompletedTasksView
├── TaskDetailView
│   ├── CompleteTaskView
│   │   ├── AddNotesView
│   │   ├── AddPhotosView
│   │   └── ServiceProviderView
│   ├── RescheduleTaskView
│   └── SkipTaskView
└── AddTaskView
    └── CustomScheduleView
```

#### 4. Reports Tab 📊
```
ReportsView
├── PropertyReportView
│   ├── ReportPreviewView
│   ├── ReportEditView
│   └── ReportExportView
├── ShareLinkManagementView
│   ├── CreateShareLinkView
│   ├── ShareLinkSettingsView
│   └── AccessAnalyticsView
├── MaintenanceAnalyticsView
│   ├── CostAnalyticsView
│   ├── HealthScoreView
│   └── ComplianceReportView
└── ServiceProviderDirectoryView
    ├── ServiceProviderDetailView
    └── AddServiceProviderView
```

#### 5. Settings Tab ⚙️
```
SettingsView
├── ProfileView
│   ├── EditProfileView
│   └── AccountManagementView
├── PropertySettingsView
│   ├── PropertyDetailView
│   ├── AddPropertyView
│   └── PropertySwitcherView
├── NotificationSettingsView
│   ├── PushNotificationPreferencesView
│   └── ReminderTimingView
├── PrivacySettingsView
│   ├── DataSharingView
│   └── ReportPrivacyView
├── SubscriptionView
│   ├── PlanComparisonView
│   └── BillingView
├── SupportView
│   ├── HelpCenterView
│   ├── ContactSupportView
│   └── FeedbackView
└── AppSettingsView
    ├── ThemeSelectionView
    └── AccessibilitySettingsView
```

## Screen Specifications

### Core Navigation Screens

#### 1. HomeView (Dashboard)
**Purpose**: Central hub showing property overview and immediate actions needed
- **Key Components**:
  - Property selector (if multiple properties)
  - Upcoming tasks widget (next 7 days)
  - Recent activity feed
  - Property health score indicator
  - Quick action buttons
- **Navigation**: Tab bar entry point
- **Actions**: Navigate to detailed views, quick asset/task creation

#### 2. AssetListView
**Purpose**: Comprehensive view of all property assets with filtering and search
- **Key Components**:
  - Asset grid/list with thumbnails
  - Category filter bar
  - Search functionality
  - Sort options (date, category, health score)
  - Add asset floating action button
- **Navigation**: Tab bar entry point, drill-down navigation
- **Actions**: View asset details, add new assets, filter/search

#### 3. AssetDetailView
**Purpose**: Complete asset information and management
- **Key Components**:
  - Asset photos carousel
  - Asset specifications and details
  - Maintenance schedule section
  - Service history timeline
  - Health score and condition
  - Action buttons (edit, schedule maintenance)
- **Navigation**: From asset list, search results
- **Actions**: Edit asset, view/add photos, manage maintenance

#### 4. MaintenanceScheduleView
**Purpose**: Calendar-based view of all maintenance tasks
- **Key Components**:
  - Calendar interface (month/week/day views)
  - Task list with status indicators
  - Filter by asset, category, status
  - Add task/schedule buttons
- **Navigation**: Tab bar entry point
- **Actions**: View task details, complete tasks, reschedule

#### 5. TaskDetailView
**Purpose**: Individual task management and completion
- **Key Components**:
  - Task information and due date
  - Related asset context
  - Completion form with photos/notes
  - Service provider selection
  - Cost tracking
- **Navigation**: From schedule views, dashboard widgets
- **Actions**: Complete task, reschedule, add service record

### Modal and Sheet Presentations

#### Asset Creation Flow
```
AddAssetView (Sheet)
├── Camera/Photo Selection (Full Screen)
├── AI Identification Results (if available)
└── Asset Details Form
    └── Save Confirmation
```

#### Task Completion Flow
```
CompleteTaskView (Sheet)
├── Add Photos (Camera/Gallery)
├── Add Notes (Text Entry)
├── Select Service Provider
├── Enter Costs
└── Completion Confirmation
```

#### Property Report Creation
```
CreatePropertyReportView (Sheet)
├── Report Template Selection
├── Data Privacy Settings
├── Report Preview
└── Export/Share Options
```

## Navigation Patterns

### Primary Navigation
- **Tab Bar**: Always visible for main app sections
- **Navigation Stack**: Standard iOS push/pop for drill-down
- **Modal Presentation**: For creation flows and settings

### Secondary Navigation
- **Segmented Controls**: For view mode switching (calendar views)
- **Filter Bars**: For content filtering (asset categories)
- **Search**: Global search with scoped results
- **Quick Actions**: Contextual action sheets

### Deep Linking Support
- **Universal Links**: For shared property reports
- **URL Schemes**: For maintenance task notifications
- **Shortcuts**: Siri shortcuts for common actions

## Accessibility Considerations

### VoiceOver Support
- Descriptive labels for all interface elements
- Logical reading order for complex views
- Action descriptions for buttons and controls

### Dynamic Type
- Scalable text throughout the interface
- Adaptive layouts for larger text sizes
- Icon scaling for better visibility

### Color and Contrast
- High contrast mode support
- Color-blind friendly palette
- Alternative indicators beyond color

## State Management

### View State
- Loading states for async operations
- Empty states for new users
- Error states with recovery actions
- Success states with clear feedback

### Data Flow
- Top-down data flow from tab controllers
- Local state for view-specific needs
- Shared state for cross-tab data
- Offline state handling

## Performance Considerations

### List Performance
- Lazy loading for large asset lists
- Image caching and resizing
- Background fetch for maintenance updates

### Memory Management
- Proper view controller lifecycle
- Image memory optimization
- Core Data fault management

### Network Efficiency
- Background sync scheduling
- Optimistic UI updates
- Retry logic for failed operations

This navigation structure provides a clear, intuitive user experience while maintaining iOS design patterns and supporting the complex feature set required for property asset management.