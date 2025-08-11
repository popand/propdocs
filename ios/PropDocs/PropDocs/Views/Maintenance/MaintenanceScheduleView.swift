//
//  MaintenanceScheduleView.swift
//  PropDocs
//
//  Maintenance schedule view based on maintenance-schedule.html prototype
//

import SwiftUI

struct MaintenanceScheduleView: View {
    
    @EnvironmentObject private var propertyViewModel: PropertyViewModel
    @State private var viewMode: ViewMode = .calendar
    @State private var selectedDate = Date()
    @State private var selectedMonth = Date()
    @State private var selectedFilter: TaskFilter = .all
    @State private var showingAddTask = false
    
    enum ViewMode {
        case calendar
        case list
    }
    
    enum TaskFilter: String, CaseIterable {
        case all = "All Tasks"
        case overdue = "Overdue"
        case today = "Today"
        case thisWeek = "This Week"
        case hvac = "HVAC"
        case plumbing = "Plumbing"
        
        var color: Color {
            switch self {
            case .all: return PropDocsColors.labelSecondary
            case .overdue: return .statusCritical
            case .today: return .statusWarning
            case .thisWeek: return .propDocsBlue
            case .hvac: return .categoryHVAC
            case .plumbing: return .categoryPlumbing
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // View Selector
            ViewSelectorHeader(viewMode: $viewMode)
            
            if viewMode == .calendar {
                CalendarView(
                    selectedDate: $selectedDate,
                    selectedMonth: $selectedMonth
                )
            } else {
                TaskListView(selectedFilter: $selectedFilter)
            }
        }
        .navigationTitle("Schedule")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                IconButton(systemImage: "calendar.badge.plus") {
                    showingAddTask = true
                }
            }
        }
        .overlay(
            // Floating Action Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    FloatingActionButton(systemImage: "plus") {
                        showingAddTask = true
                    }
                    .padding(.bottom, 100) // Account for tab bar
                    .padding(.trailing, Spacing.md)
                }
            }
        )
        .sheet(isPresented: $showingAddTask) {
            AddTaskView()
        }
    }
}

// MARK: - View Selector Header

struct ViewSelectorHeader: View {
    
    @Binding var viewMode: MaintenanceScheduleView.ViewMode
    
    var body: some View {
        HStack(spacing: 2) {
            Button(action: { viewMode = .calendar }) {
                Text("Calendar")
                    .font(.subheadline(.medium))
                    .foregroundColor(viewMode == .calendar ? PropDocsColors.labelPrimary : PropDocsColors.labelSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.sm)
                    .background(viewMode == .calendar ? PropDocsColors.backgroundPrimary : .clear)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
            
            Button(action: { viewMode = .list }) {
                Text("List")
                    .font(.subheadline(.medium))
                    .foregroundColor(viewMode == .list ? PropDocsColors.labelPrimary : PropDocsColors.labelSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.sm)
                    .background(viewMode == .list ? PropDocsColors.backgroundPrimary : .clear)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
        }
        .padding(2)
        .background(PropDocsColors.fillSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.md)
        .background(PropDocsColors.backgroundPrimary)
        .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
    }
}

// MARK: - Calendar View

struct CalendarView: View {
    
    @Binding var selectedDate: Date
    @Binding var selectedMonth: Date
    
    // Mock task data
    private let mockTasks: [Date: [MockMaintenanceTask]] = {
        let calendar = Calendar.current
        let today = Date()
        
        return [
            calendar.date(byAdding: .day, value: -3, to: today)!: [
                MockMaintenanceTask(title: "Replace HVAC Filter", type: .overdue)
            ],
            today: [
                MockMaintenanceTask(title: "Clean Gutters", type: .due),
                MockMaintenanceTask(title: "Test Smoke Detectors", type: .due)
            ],
            calendar.date(byAdding: .day, value: 7, to: today)!: [
                MockMaintenanceTask(title: "Inspect Water Heater", type: .upcoming)
            ],
            calendar.date(byAdding: .day, value: 14, to: today)!: [
                MockMaintenanceTask(title: "Service Garage Door", type: .upcoming),
                MockMaintenanceTask(title: "Check Electrical Panel", type: .upcoming)
            ]
        ]
    }()
    
    var body: some View {
        VStack(spacing: 0) {
            // Calendar Container
            PropDocsCard(padding: 0) {
                VStack(spacing: 0) {
                    // Calendar Header
                    CalendarHeader(selectedMonth: $selectedMonth)
                    
                    // Weekday Headers
                    CalendarWeekdayHeader()
                    
                    // Calendar Grid
                    CalendarGrid(
                        selectedDate: $selectedDate,
                        selectedMonth: selectedMonth,
                        tasks: mockTasks
                    )
                }
            }
            .padding(.horizontal, Spacing.md)
            .padding(.bottom, Spacing.md)
            
            Spacer()
        }
        .background(PropDocsColors.groupedBackgroundPrimary)
    }
}

// MARK: - Calendar Header

struct CalendarHeader: View {
    
    @Binding var selectedMonth: Date
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: selectedMonth)
    }
    
    var body: some View {
        HStack {
            Button(action: previousMonth) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.propDocsBlue)
                    .frame(width: 32, height: 32)
            }
            
            Spacer()
            
            Text(monthYearString)
                .font(.headline(.semibold))
                .foregroundColor(PropDocsColors.labelPrimary)
            
            Spacer()
            
            Button(action: nextMonth) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.propDocsBlue)
                    .frame(width: 32, height: 32)
            }
        }
        .padding(Spacing.md)
        .background(PropDocsColors.backgroundPrimary)
        .overlay(
            Rectangle()
                .fill(PropDocsColors.separator)
                .frame(height: 0.5),
            alignment: .bottom
        )
    }
    
    private func previousMonth() {
        selectedMonth = Calendar.current.date(byAdding: .month, value: -1, to: selectedMonth) ?? selectedMonth
    }
    
    private func nextMonth() {
        selectedMonth = Calendar.current.date(byAdding: .month, value: 1, to: selectedMonth) ?? selectedMonth
    }
}

// MARK: - Calendar Weekday Header

struct CalendarWeekdayHeader: View {
    
    private let weekdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    var body: some View {
        HStack {
            ForEach(weekdays, id: \.self) { weekday in
                Text(weekday)
                    .font(.caption(.semibold))
                    .foregroundColor(PropDocsColors.labelSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.sm)
            }
        }
        .background(PropDocsColors.fillTertiary)
    }
}

// MARK: - Calendar Grid

struct CalendarGrid: View {
    
    @Binding var selectedDate: Date
    let selectedMonth: Date
    let tasks: [Date: [MockMaintenanceTask]]
    
    private let calendar = Calendar.current
    
    private var calendarDays: [CalendarDay] {
        guard let monthRange = calendar.range(of: .day, in: .month, for: selectedMonth),
              let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedMonth)) else {
            return []
        }
        
        let firstWeekday = calendar.component(.weekday, from: firstOfMonth)
        var days: [CalendarDay] = []
        
        // Previous month days
        if firstWeekday > 1 {
            let previousMonth = calendar.date(byAdding: .month, value: -1, to: selectedMonth)!
            let previousMonthRange = calendar.range(of: .day, in: .month, for: previousMonth)!
            let lastPreviousMonthDay = previousMonthRange.upperBound - 1
            
            for day in (lastPreviousMonthDay - firstWeekday + 2)...lastPreviousMonthDay {
                let date = calendar.date(byAdding: .day, value: day - lastPreviousMonthDay - 1, to: firstOfMonth)!
                days.append(CalendarDay(date: date, isCurrentMonth: false))
            }
        }
        
        // Current month days
        for day in monthRange {
            let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth)!
            days.append(CalendarDay(date: date, isCurrentMonth: true))
        }
        
        // Next month days to fill the grid
        let remainingSlots = 42 - days.count // 6 rows * 7 days
        for day in 1...remainingSlots {
            let date = calendar.date(byAdding: .day, value: monthRange.upperBound - 1 + day, to: firstOfMonth)!
            days.append(CalendarDay(date: date, isCurrentMonth: false))
        }
        
        return days
    }
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 0) {
            ForEach(calendarDays, id: \.date) { calendarDay in
                CalendarDayView(
                    calendarDay: calendarDay,
                    isSelected: calendar.isDate(calendarDay.date, inSameDayAs: selectedDate),
                    isToday: calendar.isDateInToday(calendarDay.date),
                    tasks: tasks[calendar.startOfDay(for: calendarDay.date)] ?? []
                ) {
                    selectedDate = calendarDay.date
                }
            }
        }
        .background(PropDocsColors.groupedBackgroundSecondary)
    }
}

// MARK: - Calendar Day View

struct CalendarDayView: View {
    
    let calendarDay: CalendarDay
    let isSelected: Bool
    let isToday: Bool
    let tasks: [MockMaintenanceTask]
    let action: () -> Void
    
    private var dayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: calendarDay.date)
    }
    
    var body: some View {
        VStack(spacing: 2) {
            // Day Number
            Text(dayString)
                .font(.footnote(.medium))
                .foregroundColor(textColor)
                .padding(.top, Spacing.xs)
            
            // Task Indicators
            VStack(spacing: 1) {
                ForEach(Array(tasks.prefix(3).enumerated()), id: \.offset) { _, task in
                    Circle()
                        .fill(task.type.color)
                        .frame(width: 4, height: 4)
                }
                
                if tasks.count > 3 {
                    Text("•••")
                        .font(.system(size: 6))
                        .foregroundColor(PropDocsColors.labelTertiary)
                }
            }
            
            Spacer()
        }
        .frame(height: 50)
        .frame(maxWidth: .infinity)
        .background(backgroundColor)
        .overlay(
            Rectangle()
                .stroke(PropDocsColors.separator, lineWidth: 0.5)
        )
        .onTapGesture(perform: action)
    }
    
    private var textColor: Color {
        if isToday {
            return .white
        } else if !calendarDay.isCurrentMonth {
            return PropDocsColors.labelTertiary
        } else {
            return PropDocsColors.labelPrimary
        }
    }
    
    private var backgroundColor: Color {
        if isToday {
            return .propDocsBlue
        } else if isSelected {
            return PropDocsColors.fillQuaternary
        } else {
            return PropDocsColors.groupedBackgroundSecondary
        }
    }
}

// MARK: - Task List View

struct TaskListView: View {
    
    @Binding var selectedFilter: MaintenanceScheduleView.TaskFilter
    
    // Mock task sections
    private let mockTaskSections: [TaskSection] = [
        TaskSection(
            title: "Overdue",
            icon: "exclamationmark.circle.fill",
            color: .statusCritical,
            tasks: [
                MockMaintenanceTask(
                    title: "Replace HVAC Filter",
                    asset: "Central HVAC System",
                    dueDate: "Nov 5, 2024",
                    frequency: "Every 3 months",
                    type: .overdue
                ),
                MockMaintenanceTask(
                    title: "Test Smoke Detectors",
                    asset: "All Bedrooms & Hallways",
                    dueDate: "Nov 1, 2024",
                    frequency: "Monthly",
                    type: .overdue
                )
            ]
        ),
        TaskSection(
            title: "Today",
            icon: "calendar.circle.fill",
            color: .statusWarning,
            tasks: [
                MockMaintenanceTask(
                    title: "Clean Gutters",
                    asset: "Exterior Maintenance",
                    dueDate: "Today",
                    frequency: "Bi-annually",
                    type: .due
                )
            ]
        ),
        TaskSection(
            title: "Upcoming",
            icon: "clock.circle.fill",
            color: .propDocsBlue,
            tasks: [
                MockMaintenanceTask(
                    title: "Inspect Water Heater",
                    asset: "Basement Water Heater",
                    dueDate: "Nov 15, 2024",
                    frequency: "Annually",
                    type: .upcoming
                ),
                MockMaintenanceTask(
                    title: "Service Garage Door",
                    asset: "Garage Door Opener",
                    dueDate: "Nov 22, 2024",
                    frequency: "Every 6 months",
                    type: .upcoming
                ),
                MockMaintenanceTask(
                    title: "Check Plumbing Fixtures",
                    asset: "All Bathrooms & Kitchen",
                    dueDate: "Dec 1, 2024",
                    frequency: "Quarterly",
                    type: .upcoming
                ),
                MockMaintenanceTask(
                    title: "Deep Clean Refrigerator",
                    asset: "Kitchen Refrigerator",
                    dueDate: "Dec 8, 2024",
                    frequency: "Every 3 months",
                    type: .upcoming
                )
            ]
        )
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Filter Section
            TaskFilterSection(selectedFilter: $selectedFilter)
            
            // Task Sections
            ScrollView {
                LazyVStack(spacing: Spacing.lg) {
                    ForEach(mockTaskSections, id: \.title) { section in
                        TaskSectionView(section: section)
                    }
                }
                .padding(.top, Spacing.md)
            }
            .background(PropDocsColors.groupedBackgroundPrimary)
        }
    }
}

// MARK: - Task Filter Section

struct TaskFilterSection: View {
    
    @Binding var selectedFilter: MaintenanceScheduleView.TaskFilter
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.sm) {
                ForEach(MaintenanceScheduleView.TaskFilter.allCases, id: \.self) { filter in
                    FilterChip(
                        title: filter.rawValue,
                        isSelected: selectedFilter == filter
                    ) {
                        selectedFilter = filter
                    }
                }
            }
            .padding(.horizontal, Spacing.md)
        }
        .padding(.vertical, Spacing.md)
        .background(PropDocsColors.backgroundPrimary)
        .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
    }
}

// MARK: - Task Section View

struct TaskSectionView: View {
    
    let section: TaskSection
    
    var body: some View {
        VStack(spacing: 0) {
            // Section Header
            HStack {
                HStack(spacing: Spacing.sm) {
                    ZStack {
                        Circle()
                            .fill(section.color)
                            .frame(width: 20, height: 20)
                        
                        Image(systemName: section.icon)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white)
                    }
                    
                    Text(section.title)
                        .font(.title3(.semibold))
                        .foregroundColor(PropDocsColors.labelPrimary)
                }
                
                Spacer()
                
                Text("\(section.tasks.count)")
                    .font(.footnote(.medium))
                    .foregroundColor(PropDocsColors.labelPrimary)
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, 4)
                    .background(PropDocsColors.fillSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
            .padding(.horizontal, Spacing.md)
            .padding(.bottom, Spacing.sm)
            .background(PropDocsColors.groupedBackgroundPrimary)
            .overlay(
                Rectangle()
                    .fill(PropDocsColors.separator)
                    .frame(height: 0.5),
                alignment: .bottom
            )
            
            // Tasks
            LazyVStack(spacing: 0) {
                ForEach(Array(section.tasks.enumerated()), id: \.offset) { index, task in
                    MaintenanceTaskRow(task: task)
                    
                    if index < section.tasks.count - 1 {
                        Divider()
                    }
                }
            }
            .background(PropDocsColors.groupedBackgroundSecondary)
        }
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
        .padding(.horizontal, Spacing.md)
    }
}

// MARK: - Maintenance Task Row

struct MaintenanceTaskRow: View {
    
    let task: MockMaintenanceTask
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            // Task Checkbox
            ZStack {
                Circle()
                    .stroke(task.type.color, lineWidth: 2)
                    .frame(width: 22, height: 22)
                
                if task.type == .overdue {
                    Circle()
                        .fill(task.type.color)
                        .frame(width: 22, height: 22)
                    
                    Image(systemName: "exclamationmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            
            // Priority Bar
            PriorityIndicator(task.priority, style: .bar)
            
            // Task Content
            VStack(alignment: .leading, spacing: 2) {
                Text(task.title)
                    .font(.body(.medium))
                    .foregroundColor(PropDocsColors.labelPrimary)
                    .lineLimit(1)
                
                Text(task.asset)
                    .font(.footnote(.regular))
                    .foregroundColor(PropDocsColors.labelSecondary)
                    .lineLimit(1)
                
                HStack {
                    Text(task.dueDate)
                        .font(.caption(.regular))
                        .foregroundColor(PropDocsColors.labelTertiary)
                    
                    Text(task.frequency)
                        .font(.caption(.regular))
                        .foregroundColor(.propDocsBlue)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(PropDocsColors.fillTertiary)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
                .padding(.top, 2)
            }
            
            Spacer()
            
            // Action Buttons
            HStack(spacing: Spacing.sm) {
                Button(action: {
                    // Handle reschedule
                }) {
                    Image(systemName: "clock")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(PropDocsColors.labelTertiary)
                        .frame(width: 32, height: 32)
                }
                
                Button(action: {
                    // Handle complete
                }) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(PropDocsColors.labelTertiary)
                        .frame(width: 32, height: 32)
                }
            }
        }
        .padding(Spacing.md)
        .contentShape(Rectangle())
        .onTapGesture {
            // Handle task tap
        }
    }
}

// MARK: - Add Task View (Placeholder)

struct AddTaskView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Add Task")
                    .font(.title.weight(.bold))
                
                Text("Task creation form would go here")
                    .font(.body)
                    .foregroundColor(PropDocsColors.labelSecondary)
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

// MARK: - Supporting Models

struct CalendarDay {
    let date: Date
    let isCurrentMonth: Bool
}

struct TaskSection {
    let title: String
    let icon: String
    let color: Color
    let tasks: [MockMaintenanceTask]
}

struct MockMaintenanceTask {
    let id = UUID()
    let title: String
    let asset: String
    let dueDate: String
    let frequency: String
    let type: TaskType
    let priority: PriorityIndicator.Priority
    
    init(
        title: String,
        asset: String = "",
        dueDate: String = "",
        frequency: String = "",
        type: TaskType,
        priority: PriorityIndicator.Priority = .medium
    ) {
        self.title = title
        self.asset = asset
        self.dueDate = dueDate
        self.frequency = frequency
        self.type = type
        self.priority = priority
    }
    
    enum TaskType {
        case overdue
        case due
        case upcoming
        case completed
        
        var color: Color {
            switch self {
            case .overdue: return .statusCritical
            case .due: return .statusWarning
            case .upcoming: return .propDocsBlue
            case .completed: return .statusGood
            }
        }
    }
}

#Preview {
    NavigationView {
        MaintenanceScheduleView()
            .environmentObject(PropertyViewModel())
    }
}