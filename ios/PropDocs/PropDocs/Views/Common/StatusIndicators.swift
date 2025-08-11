//
//  StatusIndicators.swift
//  PropDocs
//
//  Status and priority indicator components
//

import SwiftUI

// MARK: - Status Dot

struct StatusDot: View {
    
    enum Status {
        case good
        case warning
        case critical
        case unknown
        
        var color: Color {
            switch self {
            case .good: return .statusGood
            case .warning: return .statusWarning
            case .critical: return .statusCritical
            case .unknown: return PropDocsColors.labelTertiary
            }
        }
    }
    
    let status: Status
    let size: CGFloat
    
    init(_ status: Status, size: CGFloat = 8) {
        self.status = status
        self.size = size
    }
    
    var body: some View {
        Circle()
            .fill(status.color)
            .frame(width: size, height: size)
    }
}

// MARK: - Priority Indicator

struct PriorityIndicator: View {
    
    enum Priority {
        case high
        case medium
        case low
        
        var color: Color {
            switch self {
            case .high: return .priorityHigh
            case .medium: return .priorityMedium
            case .low: return .priorityLow
            }
        }
        
        var title: String {
            switch self {
            case .high: return "High"
            case .medium: return "Medium"
            case .low: return "Low"
            }
        }
    }
    
    let priority: Priority
    let style: Style
    
    enum Style {
        case bar
        case badge
        case dot
    }
    
    init(_ priority: Priority, style: Style = .bar) {
        self.priority = priority
        self.style = style
    }
    
    var body: some View {
        switch style {
        case .bar:
            Rectangle()
                .fill(priority.color)
                .frame(width: 3, height: 48)
                .clipShape(RoundedRectangle(cornerRadius: 1.5))
                
        case .badge:
            Text(priority.title)
                .font(.caption(.medium))
                .foregroundColor(.white)
                .padding(.horizontal, Spacing.sm)
                .padding(.vertical, Spacing.xs)
                .background(priority.color)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.badge))
                
        case .dot:
            Circle()
                .fill(priority.color)
                .frame(width: 8, height: 8)
        }
    }
}

// MARK: - Health Score Circle

struct HealthScoreCircle: View {
    
    let score: Int
    let size: CGFloat
    let lineWidth: CGFloat
    
    init(score: Int, size: CGFloat = 60, lineWidth: CGFloat = 4) {
        self.score = score
        self.size = size
        self.lineWidth = lineWidth
    }
    
    private var progress: Double {
        Double(score) / 100.0
    }
    
    private var scoreColor: Color {
        switch score {
        case 80...100: return .statusGood
        case 60..<80: return .statusWarning
        default: return .statusCritical
        }
    }
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(PropDocsColors.fillTertiary, lineWidth: lineWidth)
            
            // Progress circle
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    scoreColor,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 1.0), value: progress)
            
            // Score text
            Text("\(score)")
                .font(.system(size: size * 0.3, weight: .bold, design: .rounded))
                .foregroundColor(scoreColor)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Progress Bar

struct ProgressBar: View {
    
    let progress: Double
    let height: CGFloat
    let backgroundColor: Color
    let foregroundColor: Color
    
    init(
        progress: Double,
        height: CGFloat = 4,
        backgroundColor: Color = PropDocsColors.fillTertiary,
        foregroundColor: Color = .propDocsBlue
    ) {
        self.progress = max(0, min(1, progress))
        self.height = height
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(backgroundColor)
                    .frame(height: height)
                
                // Progress
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(foregroundColor)
                    .frame(width: geometry.size.width * progress, height: height)
                    .animation(.easeInOut(duration: 0.3), value: progress)
            }
        }
        .frame(height: height)
    }
}

// MARK: - Badge

struct Badge: View {
    
    let count: Int
    let color: Color
    
    init(_ count: Int, color: Color = .propDocsRed) {
        self.count = count
        self.color = color
    }
    
    var body: some View {
        if count > 0 {
            Text(count > 99 ? "99+" : "\(count)")
                .font(.caption2(.semibold))
                .foregroundColor(.white)
                .padding(.horizontal, count < 10 ? 6 : 8)
                .padding(.vertical, 2)
                .background(color)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.badge))
                .minimumScaleFactor(0.8)
        }
    }
}

// MARK: - Task Status Icon

struct TaskStatusIcon: View {
    
    enum TaskStatus {
        case completed
        case overdue
        case upcoming
        case scheduled
        
        var systemImage: String {
            switch self {
            case .completed: return "checkmark.circle.fill"
            case .overdue: return "exclamationmark.circle.fill"
            case .upcoming: return "clock.circle.fill"
            case .scheduled: return "calendar.circle.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .completed: return .statusGood
            case .overdue: return .statusCritical
            case .upcoming: return .statusWarning
            case .scheduled: return .propDocsBlue
            }
        }
    }
    
    let status: TaskStatus
    let size: CGFloat
    
    init(_ status: TaskStatus, size: CGFloat = 32) {
        self.status = status
        self.size = size
    }
    
    var body: some View {
        Image(systemName: status.systemImage)
            .font(.system(size: size * 0.6, weight: .medium))
            .foregroundColor(.white)
            .frame(width: size, height: size)
            .background(status.color)
            .clipShape(Circle())
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        VStack(spacing: Spacing.lg) {
            // Status dots
            HStack {
                VStack {
                    StatusDot(.good)
                    Text("Good").caption()
                }
                VStack {
                    StatusDot(.warning)
                    Text("Warning").caption()
                }
                VStack {
                    StatusDot(.critical)
                    Text("Critical").caption()
                }
                VStack {
                    StatusDot(.unknown)
                    Text("Unknown").caption()
                }
            }
            
            // Priority indicators
            HStack {
                VStack {
                    PriorityIndicator(.high, style: .bar)
                    Text("High Bar").caption()
                }
                VStack {
                    PriorityIndicator(.medium, style: .badge)
                    Text("Medium Badge").caption()
                }
                VStack {
                    PriorityIndicator(.low, style: .dot)
                    Text("Low Dot").caption()
                }
            }
            
            // Health score circles
            HStack {
                VStack {
                    HealthScoreCircle(score: 85)
                    Text("85 Score").caption()
                }
                VStack {
                    HealthScoreCircle(score: 65, size: 80)
                    Text("65 Score").caption()
                }
                VStack {
                    HealthScoreCircle(score: 45, size: 50)
                    Text("45 Score").caption()
                }
            }
            
            // Progress bars
            VStack(spacing: Spacing.md) {
                ProgressBar(progress: 0.8)
                ProgressBar(progress: 0.3, foregroundColor: .statusWarning)
                ProgressBar(progress: 0.1, foregroundColor: .statusCritical)
            }
            .frame(width: 200)
            
            // Badges
            HStack {
                Badge(5)
                Badge(12, color: .propDocsBlue)
                Badge(99)
                Badge(150)
            }
            
            // Task status icons
            HStack {
                VStack {
                    TaskStatusIcon(.completed)
                    Text("Completed").caption()
                }
                VStack {
                    TaskStatusIcon(.overdue)
                    Text("Overdue").caption()
                }
                VStack {
                    TaskStatusIcon(.upcoming)
                    Text("Upcoming").caption()
                }
                VStack {
                    TaskStatusIcon(.scheduled)
                    Text("Scheduled").caption()
                }
            }
        }
        .padding()
    }
    .background(PropDocsColors.groupedBackgroundPrimary)
}