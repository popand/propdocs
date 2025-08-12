//
//  HomeView.swift
//  PropDocs
//
//  Main dashboard view based on home-dashboard.html prototype
//

import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject private var propertyViewModel: PropertyViewModel
    @State private var showPropertySelector = false
    @State private var showAddProperty = false
    
    var body: some View {
        Group {
            if propertyViewModel.properties.isEmpty {
                // Empty State - No Properties
                PropertyEmptyStateView()
            } else {
                // Dashboard Content - Has Properties
                DashboardContentView(
                    showPropertySelector: $showPropertySelector,
                    showAddProperty: $showAddProperty
                )
                .environmentObject(propertyViewModel)
            }
        }
        .background(PropDocsColors.groupedBackgroundPrimary)
        .navigationBarHidden(true)
        .sheet(isPresented: $showPropertySelector) {
            PropertySelectorView()
                .environmentObject(propertyViewModel)
        }
        .sheet(isPresented: $showAddProperty) {
            PropertyCreationView()
                .environmentObject(propertyViewModel)
        }
        .onAppear {
            // Load properties when view appears
            if propertyViewModel.properties.isEmpty {
                propertyViewModel.loadProperties()
            }
        }
    }
}

// MARK: - Dashboard Content

struct DashboardContentView: View {
    
    @EnvironmentObject private var propertyViewModel: PropertyViewModel
    @Binding var showPropertySelector: Bool
    @Binding var showAddProperty: Bool
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                // Dashboard Header
                DashboardHeaderView(
                    showPropertySelector: $showPropertySelector,
                    showAddProperty: $showAddProperty
                )
                .environmentObject(propertyViewModel)
                
                // Main Content
                VStack(spacing: Spacing.lg) {
                    // Upcoming Tasks Section
                    UpcomingTasksSection()
                    
                    // Recent Activity Section
                    RecentActivitySection()
                    
                    // Quick Actions Section
                    QuickActionsSection(showAddProperty: $showAddProperty)
                }
                .padding(.top, Spacing.md)
            }
        }
    }
}

// MARK: - Dashboard Header

struct DashboardHeaderView: View {
    
    @EnvironmentObject private var propertyViewModel: PropertyViewModel
    @Binding var showPropertySelector: Bool
    @Binding var showAddProperty: Bool
    
    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(
                colors: [.propDocsBlue, Color.propDocsIndigo],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(spacing: Spacing.lg) {
                // Navigation Bar
                HStack {
                    // Logo (placeholder - in real app this would be an image)
                    Text("PropDocs")
                        .font(.headline(.semibold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Add Property Button
                    IconButton(
                        systemImage: "plus.circle",
                        size: 28,
                        tintColor: .white
                    ) {
                        showAddProperty = true
                    }
                    
                    // Profile Button
                    IconButton(
                        systemImage: "person.circle",
                        size: 28,
                        tintColor: .white
                    ) {
                        // Handle profile tap
                    }
                }
                .padding(.horizontal, Spacing.md)
                .padding(.top, Spacing.sm)
                
                // Property Selector
                PropertySelectorHeader(showPropertySelector: $showPropertySelector)
                    .environmentObject(propertyViewModel)
                
                // Property Health Score
                PropertyHealthScoreView()
                    .environmentObject(propertyViewModel)
            }
            .padding(.bottom, Spacing.lg)
        }
        .cornerRadius(CornerRadius.lg, corners: [.bottomLeft, .bottomRight])
        .padding(.bottom, Spacing.md)
    }
}

// MARK: - Property Selector Header

struct PropertySelectorHeader: View {
    
    @EnvironmentObject private var propertyViewModel: PropertyViewModel
    @Binding var showPropertySelector: Bool
    
    private var currentProperty: Property? {
        propertyViewModel.activeProperty ?? propertyViewModel.properties.first
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(currentProperty?.displayName ?? "No Property")
                    .font(.title2(.bold))
                    .foregroundColor(.white)
                
                Text(currentProperty?.propertyTypeEnum.displayName ?? "")
                    .font(.footnote(.regular))
                    .foregroundColor(.white.opacity(0.9))
            }
            
            Spacer()
            
            if propertyViewModel.properties.count > 1 {
                Button(action: { showPropertySelector = true }) {
                    Text("Switch")
                        .font(.footnote(.medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, Spacing.md)
                        .padding(.vertical, Spacing.xs)
                        .background(.white.opacity(0.2))
                        .clipShape(Capsule())
                }
            }
        }
        .padding(.horizontal, Spacing.md)
    }
}

// MARK: - Property Health Score

struct PropertyHealthScoreView: View {
    
    @EnvironmentObject private var propertyViewModel: PropertyViewModel
    
    private var healthScore: Int {
        // Mock health score calculation - in real app this would be based on actual data
        80
    }
    
    private var healthDescription: String {
        switch healthScore {
        case 80...100: return "Good"
        case 60..<80: return "Fair"
        case 40..<60: return "Poor"
        default: return "Critical"
        }
    }
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            HealthScoreCircle(score: healthScore, size: 60, lineWidth: 4)
            
            VStack(alignment: .leading) {
                Text(healthDescription)
                    .font(.headline(.semibold))
                    .foregroundColor(.white)
                
                Text("Property Health Score")
                    .font(.footnote(.regular))
                    .foregroundColor(.white.opacity(0.9))
            }
            
            Spacer()
        }
        .padding(.horizontal, Spacing.md)
    }
}

// MARK: - Upcoming Tasks Section

struct UpcomingTasksSection: View {
    
    // Mock task data - in real app this would come from view model
    private let mockTasks: [MockTask] = [
        MockTask(
            title: "Replace HVAC Filter",
            subtitle: "Living Room HVAC System",
            dueDate: "Today",
            priority: .high
        ),
        MockTask(
            title: "Test Smoke Detectors",
            subtitle: "All Bedrooms & Hallways",
            dueDate: "Tomorrow",
            priority: .medium
        ),
        MockTask(
            title: "Clean Gutters",
            subtitle: "Exterior Maintenance",
            dueDate: "This Week",
            priority: .low
        )
    ]
    
    var body: some View {
        PropDocsCard(padding: 0) {
            VStack(spacing: 0) {
                // Section Header
                PropDocsCardHeader(
                    title: "Upcoming Tasks",
                    actionTitle: "View All"
                ) {
                    // Handle view all tap
                }
                .padding(Spacing.md)
                
                // Task List
                LazyVStack(spacing: 0) {
                    ForEach(Array(mockTasks.enumerated()), id: \.offset) { index, task in
                        TaskItemView(task: task)
                        
                        if index < mockTasks.count - 1 {
                            Divider()
                                .padding(.leading, Spacing.xl + Spacing.md)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, Spacing.md)
    }
}

// MARK: - Task Item View

struct TaskItemView: View {
    
    let task: MockTask
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            // Priority Indicator
            PriorityIndicator(task.priority, style: .bar)
            
            // Task Content
            VStack(alignment: .leading, spacing: 2) {
                Text(task.title)
                    .font(.body(.medium))
                    .foregroundColor(PropDocsColors.labelPrimary)
                
                Text(task.subtitle)
                    .font(.footnote(.regular))
                    .foregroundColor(PropDocsColors.labelSecondary)
            }
            
            Spacer()
            
            // Due Date
            Text(task.dueDate)
                .font(.caption(.medium))
                .foregroundColor(PropDocsColors.labelTertiary)
        }
        .padding(Spacing.md)
        .contentShape(Rectangle())
        .onTapGesture {
            // Handle task tap
        }
    }
}

// MARK: - Recent Activity Section

struct RecentActivitySection: View {
    
    // Mock activity data
    private let mockActivities: [MockActivity] = [
        MockActivity(
            title: "Water Heater Inspection",
            subtitle: "Completed by John's Plumbing",
            time: "2 hours ago",
            type: .completed
        ),
        MockActivity(
            title: "Added New Asset",
            subtitle: "Kitchen Refrigerator - Samsung RF28R7351SG",
            time: "Yesterday",
            type: .scheduled
        ),
        MockActivity(
            title: "Garage Door Lubrication",
            subtitle: "Self-completed maintenance",
            time: "3 days ago",
            type: .completed
        )
    ]
    
    var body: some View {
        VStack(spacing: Spacing.md) {
            // Section Header
            HStack {
                Text("Recent Activity")
                    .font(.title3(.semibold))
                    .foregroundColor(PropDocsColors.labelPrimary)
                
                Spacer()
                
                Button("View All") {
                    // Handle view all tap
                }
                .font(.subheadline(.medium))
                .foregroundColor(.propDocsBlue)
            }
            .padding(.horizontal, Spacing.md)
            
            // Activity List
            VStack(spacing: Spacing.md) {
                ForEach(Array(mockActivities.enumerated()), id: \.offset) { _, activity in
                    ActivityItemView(activity: activity)
                }
            }
            .padding(.horizontal, Spacing.md)
        }
    }
}

// MARK: - Activity Item View

struct ActivityItemView: View {
    
    let activity: MockActivity
    
    var body: some View {
        HStack(alignment: .top, spacing: Spacing.md) {
            TaskStatusIcon(activity.type == .completed ? .completed : .scheduled, size: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(activity.title)
                    .font(.body(.medium))
                    .foregroundColor(PropDocsColors.labelPrimary)
                
                Text(activity.subtitle)
                    .font(.footnote(.regular))
                    .foregroundColor(PropDocsColors.labelSecondary)
                
                Text(activity.time)
                    .font(.caption(.regular))
                    .foregroundColor(PropDocsColors.labelTertiary)
                    .padding(.top, 2)
            }
            
            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            // Handle activity tap
        }
    }
}

// MARK: - Quick Actions Section

struct QuickActionsSection: View {
    
    @Binding var showAddProperty: Bool
    
    private func quickActions() -> [QuickAction] {
        [
            QuickAction(title: "Add Property", systemImage: "house.fill", color: .propDocsBlue, action: .addProperty),
            QuickAction(title: "Add Asset", systemImage: "shippingbox", color: .propDocsBlue, action: .addAsset),
            QuickAction(title: "Schedule Task", systemImage: "calendar", color: .propDocsGreen, action: .scheduleTask),
            QuickAction(title: "View Report", systemImage: "chart.bar", color: .propDocsOrange, action: .viewReport),
            QuickAction(title: "Take Photo", systemImage: "camera", color: .propdocsPurple, action: .takePhoto)
        ]
    }
    
    var body: some View {
        VStack(spacing: Spacing.md) {
            // Section Header
            HStack {
                Text("Quick Actions")
                    .font(.title3(.semibold))
                    .foregroundColor(PropDocsColors.labelPrimary)
                
                Spacer()
            }
            .padding(.horizontal, Spacing.md)
            
            // Actions Scroll View
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.md) {
                    ForEach(quickActions(), id: \.title) { action in
                        QuickActionButton(
                            action: action,
                            showAddProperty: $showAddProperty
                        )
                    }
                }
                .padding(.horizontal, Spacing.md)
            }
        }
    }
}

// MARK: - Quick Action Button

struct QuickActionButton: View {
    
    let action: QuickAction
    @Binding var showAddProperty: Bool
    
    var body: some View {
        VStack(spacing: Spacing.sm) {
            ZStack {
                Circle()
                    .fill(action.color)
                    .frame(width: 32, height: 32)
                
                Image(systemName: action.systemImage)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
            }
            
            Text(action.title)
                .font(.footnote(.medium))
                .foregroundColor(PropDocsColors.labelPrimary)
                .multilineTextAlignment(.center)
        }
        .frame(width: 120)
        .padding(Spacing.md)
        .background(PropDocsColors.groupedBackgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
        .onTapGesture {
            handleAction()
        }
    }
    
    private func handleAction() {
        switch action.action {
        case .addProperty:
            showAddProperty = true
        case .addAsset:
            // Handle add asset
            break
        case .scheduleTask:
            // Handle schedule task
            break
        case .viewReport:
            // Handle view report
            break
        case .takePhoto:
            // Handle take photo
            break
        }
    }
}

// MARK: - Property Selector View

struct PropertySelectorView: View {
    
    @EnvironmentObject private var propertyViewModel: PropertyViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List(propertyViewModel.properties, id: \.id) { property in
                PropertySelectorRow(
                    property: property,
                    isSelected: property.id == propertyViewModel.activeProperty?.id
                ) {
                    propertyViewModel.setActiveProperty(property)
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .navigationTitle("Select Property")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

// MARK: - Property Selector Row

struct PropertySelectorRow: View {
    
    let property: Property
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(property.displayName)
                    .font(.body(.medium))
                    .foregroundColor(PropDocsColors.labelPrimary)
                
                if let address = property.address {
                    Text(address)
                        .font(.footnote(.regular))
                        .foregroundColor(PropDocsColors.labelSecondary)
                }
            }
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.propDocsBlue)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: action)
    }
}

// MARK: - Mock Data Models

struct MockTask {
    let title: String
    let subtitle: String
    let dueDate: String
    let priority: PriorityIndicator.Priority
}

struct MockActivity {
    let title: String
    let subtitle: String
    let time: String
    let type: ActivityType
    
    enum ActivityType {
        case completed
        case scheduled
    }
}

struct QuickAction {
    let title: String
    let systemImage: String
    let color: Color
    let action: QuickActionType
}

enum QuickActionType {
    case addProperty
    case addAsset
    case scheduleTask
    case viewReport
    case takePhoto
}

// MARK: - Corner Radius Extension

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    HomeView()
        .environmentObject(PropertyViewModel())
}