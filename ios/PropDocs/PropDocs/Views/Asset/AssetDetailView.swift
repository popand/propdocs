//
//  AssetDetailView.swift
//  PropDocs
//
//  Asset detail view based on asset-detail.html prototype
//

import SwiftUI

struct AssetDetailView: View {
    
    let asset: MockAsset
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedImageIndex = 0
    @State private var showingServiceHistory = false
    @State private var showingEditAsset = false
    
    init(asset: MockAsset) {
        self.asset = asset
    }
    
    // Mock asset photos
    private let mockPhotos = ["placeholder1", "placeholder2", "placeholder3"]
    
    // Mock asset details
    private var mockAssetDetails: [AssetDetailRow] = [
        AssetDetailRow(label: "Location", value: "Basement"),
        AssetDetailRow(label: "System Type", value: "Split System"),
        AssetDetailRow(label: "BTU Rating", value: "60,000 BTU"),
        AssetDetailRow(label: "Efficiency", value: "16 SEER"),
        AssetDetailRow(label: "Serial Number", value: "3119C54821"),
        AssetDetailRow(label: "Warranty", value: "10 years parts")
    ]
    
    // Mock maintenance tasks
    private var mockMaintenanceTasks: [MockMaintenanceTask] = [
        MockMaintenanceTask(
            title: "Replace Air Filter",
            asset: "Central HVAC System",
            dueDate: "Overdue by 2 weeks",
            frequency: "Every 3 months",
            type: .overdue,
            priority: .high
        ),
        MockMaintenanceTask(
            title: "Annual System Inspection",
            asset: "Central HVAC System",
            dueDate: "Due in 2 months",
            frequency: "Annually",
            type: .upcoming
        ),
        MockMaintenanceTask(
            title: "Clean Condenser Coils",
            asset: "Central HVAC System",
            dueDate: "Due in 4 months",
            frequency: "Every 6 months",
            type: .upcoming
        )
    ]
    
    // Mock service history
    private var mockServiceHistory: [ServiceHistoryItem] = [
        ServiceHistoryItem(
            title: "Annual Maintenance",
            provider: "HVAC Pro Services",
            cost: "$245.00",
            date: "Sep 15, 2024"
        ),
        ServiceHistoryItem(
            title: "Filter Replacement",
            provider: "Self-completed",
            cost: "$35.00",
            date: "Jun 12, 2024"
        ),
        ServiceHistoryItem(
            title: "System Installation",
            provider: "Climate Control Inc.",
            cost: "$8,500.00",
            date: "Mar 22, 2019"
        )
    ]
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                // Hero Image Section
                AssetHeroSection(
                    asset: asset,
                    photos: mockPhotos,
                    selectedImageIndex: $selectedImageIndex
                ) {
                    presentationMode.wrappedValue.dismiss()
                }
                
                // Asset Header Info
                AssetHeaderSection(asset: asset, showingEditAsset: $showingEditAsset)
                
                // Main Content Sections
                VStack(spacing: Spacing.lg) {
                    // Details Section
                    AssetDetailsSection(details: mockAssetDetails)
                    
                    // Maintenance Schedule Section
                    MaintenanceSection(tasks: mockMaintenanceTasks)
                    
                    // Service History Section
                    ServiceHistorySection(
                        serviceHistory: mockServiceHistory,
                        showingServiceHistory: $showingServiceHistory
                    )
                }
                .padding(.top, Spacing.md)
                .padding(.bottom, 120) // Space for action buttons
            }
        }
        .background(PropDocsColors.groupedBackgroundPrimary)
        .navigationBarHidden(true)
        .overlay(
            // Action Buttons
            ActionButtonsOverlay(),
            alignment: .bottom
        )
        .sheet(isPresented: $showingEditAsset) {
            EditAssetView(asset: asset)
        }
        .sheet(isPresented: $showingServiceHistory) {
            ServiceHistoryDetailView(serviceHistory: mockServiceHistory)
        }
    }
}

// MARK: - Asset Hero Section

struct AssetHeroSection: View {
    
    let asset: MockAsset
    let photos: [String]
    @Binding var selectedImageIndex: Int
    let onBackTap: () -> Void
    
    var body: some View {
        ZStack {
            // Background placeholder for image
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color.gray.opacity(0.1), Color.gray.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 280)
            
            // Asset icon as placeholder
            Image(systemName: asset.systemImage)
                .font(.system(size: 64, weight: .medium))
                .foregroundColor(asset.category.color)
            
            // Overlay gradient
            LinearGradient(
                colors: [Color.clear, Color.black.opacity(0.3)],
                startPoint: .top,
                endPoint: .bottom
            )
            
            // Navigation buttons
            VStack {
                HStack {
                    Button(action: onBackTap) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primary)
                            .frame(width: 32, height: 32)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        // Handle more options
                    }) {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primary)
                            .frame(width: 32, height: 32)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                }
                .padding(Spacing.md)
                
                Spacer()
                
                // Photo indicators
                if photos.count > 1 {
                    HStack(spacing: Spacing.xs) {
                        ForEach(0..<photos.count, id: \.self) { index in
                            Circle()
                                .fill(index == selectedImageIndex ? Color.white : Color.white.opacity(0.5))
                                .frame(width: 8, height: 8)
                        }
                    }
                    .padding(.bottom, Spacing.md)
                }
            }
        }
    }
}

// MARK: - Asset Header Section

struct AssetHeaderSection: View {
    
    let asset: MockAsset
    @Binding var showingEditAsset: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            // Title and Status
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(asset.title)
                        .font(.title1(.bold))
                        .foregroundColor(PropDocsColors.labelPrimary)
                    
                    Text("\(asset.category.rawValue) • \(asset.brand)")
                        .font(.body(.regular))
                        .foregroundColor(PropDocsColors.labelSecondary)
                }
                
                Spacer()
                
                // Health Badge
                HStack(spacing: Spacing.xs) {
                    StatusDot(asset.status.statusDotStatus, size: 8)
                    Text(asset.status.displayName)
                        .font(.footnote(.semibold))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.xs)
                .background(asset.status.statusDotStatus.color)
                .clipShape(Capsule())
            }
            
            // Specifications
            HStack(spacing: 0) {
                SpecificationView(value: "2019", label: "Install Year")
                
                Divider()
                    .frame(height: 40)
                
                SpecificationView(value: "5 years", label: "Age")
                
                Divider()
                    .frame(height: 40)
                
                SpecificationView(value: "$8,500", label: "Value")
                
                Divider()
                    .frame(height: 40)
                
                SpecificationView(value: "15-20", label: "Life (years)")
            }
            .padding(Spacing.md)
            .background(PropDocsColors.fillSecondary)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
        }
        .padding(.horizontal, Spacing.md)
        .background(PropDocsColors.backgroundPrimary)
    }
}

// MARK: - Specification View

struct SpecificationView: View {
    
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.headline(.semibold))
                .foregroundColor(PropDocsColors.labelPrimary)
            
            Text(label)
                .font(.caption(.regular))
                .foregroundColor(PropDocsColors.labelSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Asset Details Section

struct AssetDetailsSection: View {
    
    let details: [AssetDetailRow]
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // Section Header
            HStack {
                Text("Details")
                    .font(.title3(.semibold))
                    .foregroundColor(PropDocsColors.labelPrimary)
                
                Spacer()
                
                Button("Edit") {
                    // Handle edit
                }
                .font(.subheadline(.medium))
                .foregroundColor(.propDocsBlue)
            }
            .padding(.horizontal, Spacing.md)
            
            // Details List
            PropDocsCard(padding: 0) {
                LazyVStack(spacing: 0) {
                    ForEach(Array(details.enumerated()), id: \.offset) { index, detail in
                        HStack {
                            Text(detail.label)
                                .font(.body(.medium))
                                .foregroundColor(PropDocsColors.labelPrimary)
                            
                            Spacer()
                            
                            Text(detail.value)
                                .font(.body(.regular))
                                .foregroundColor(PropDocsColors.labelSecondary)
                                .multilineTextAlignment(.trailing)
                        }
                        .padding(Spacing.md)
                        
                        if index < details.count - 1 {
                            Divider()
                        }
                    }
                }
            }
            .padding(.horizontal, Spacing.md)
        }
    }
}

// MARK: - Maintenance Section

struct MaintenanceSection: View {
    
    let tasks: [MockMaintenanceTask]
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // Section Header
            HStack {
                Text("Maintenance Schedule")
                    .font(.title3(.semibold))
                    .foregroundColor(PropDocsColors.labelPrimary)
                
                Spacer()
                
                Button("Manage") {
                    // Handle manage
                }
                .font(.subheadline(.medium))
                .foregroundColor(.propDocsBlue)
            }
            .padding(.horizontal, Spacing.md)
            
            // Tasks List
            PropDocsCard(padding: 0) {
                LazyVStack(spacing: 0) {
                    ForEach(Array(tasks.enumerated()), id: \.offset) { index, task in
                        HStack(spacing: Spacing.md) {
                            // Task Status Icon
                            TaskStatusIcon(task.type == .overdue ? .overdue : .scheduled, size: 32)
                            
                            // Task Content
                            VStack(alignment: .leading, spacing: 2) {
                                Text(task.title)
                                    .font(.body(.medium))
                                    .foregroundColor(PropDocsColors.labelPrimary)
                                
                                Text(task.dueDate)
                                    .font(.footnote(.regular))
                                    .foregroundColor(PropDocsColors.labelSecondary)
                                
                                Text(task.frequency)
                                    .font(.caption(.regular))
                                    .foregroundColor(PropDocsColors.labelTertiary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.footnote(.medium))
                                .foregroundColor(PropDocsColors.labelTertiary)
                        }
                        .padding(Spacing.md)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            // Handle task tap
                        }
                        
                        if index < tasks.count - 1 {
                            Divider()
                        }
                    }
                }
            }
            .padding(.horizontal, Spacing.md)
        }
    }
}

// MARK: - Service History Section

struct ServiceHistorySection: View {
    
    let serviceHistory: [ServiceHistoryItem]
    @Binding var showingServiceHistory: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // Section Header
            HStack {
                Text("Service History")
                    .font(.title3(.semibold))
                    .foregroundColor(PropDocsColors.labelPrimary)
                
                Spacer()
                
                Button("View All") {
                    showingServiceHistory = true
                }
                .font(.subheadline(.medium))
                .foregroundColor(.propDocsBlue)
            }
            .padding(.horizontal, Spacing.md)
            
            // Service History List (showing only first few items)
            PropDocsCard(padding: 0) {
                LazyVStack(spacing: 0) {
                    ForEach(Array(serviceHistory.prefix(3).enumerated()), id: \.offset) { index, service in
                        HStack(alignment: .top, spacing: Spacing.md) {
                            // Service Icon
                            TaskStatusIcon(.completed, size: 32)
                            
                            // Service Content
                            VStack(alignment: .leading, spacing: 2) {
                                Text(service.title)
                                    .font(.body(.medium))
                                    .foregroundColor(PropDocsColors.labelPrimary)
                                
                                Text(service.provider)
                                    .font(.footnote(.regular))
                                    .foregroundColor(PropDocsColors.labelSecondary)
                                
                                Text(service.cost)
                                    .font(.footnote(.semibold))
                                    .foregroundColor(.propDocsGreen)
                            }
                            
                            Spacer()
                            
                            Text(service.date)
                                .font(.caption(.regular))
                                .foregroundColor(PropDocsColors.labelTertiary)
                        }
                        .padding(Spacing.md)
                        
                        if index < min(serviceHistory.count, 3) - 1 {
                            Divider()
                        }
                    }
                }
            }
            .padding(.horizontal, Spacing.md)
        }
    }
}

// MARK: - Action Buttons Overlay

struct ActionButtonsOverlay: View {
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack(spacing: Spacing.md) {
                PropDocsButton(
                    "Schedule Service",
                    style: .secondary
                ) {
                    // Handle schedule service
                }
                
                PropDocsButton(
                    "Complete Task"
                ) {
                    // Handle complete task
                }
            }
            .padding(.horizontal, Spacing.md)
            .padding(.bottom, Spacing.lg)
            .background(
                LinearGradient(
                    colors: [PropDocsColors.backgroundPrimary.opacity(0), PropDocsColors.backgroundPrimary],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 100)
            )
        }
    }
}

// MARK: - Edit Asset View (Placeholder)

struct EditAssetView: View {
    
    let asset: MockAsset
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Edit Asset")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Asset editing form would go here")
                    .font(.body)
                    .foregroundColor(PropDocsColors.labelSecondary)
            }
            .navigationTitle("Edit Asset")
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

// MARK: - Service History Detail View (Placeholder)

struct ServiceHistoryDetailView: View {
    
    let serviceHistory: [ServiceHistoryItem]
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List(serviceHistory, id: \.title) { service in
                VStack(alignment: .leading) {
                    Text(service.title)
                        .font(.body(.medium))
                    Text(service.provider)
                        .font(.footnote(.regular))
                        .foregroundColor(PropDocsColors.labelSecondary)
                    HStack {
                        Text(service.cost)
                            .font(.footnote(.semibold))
                            .foregroundColor(.propDocsGreen)
                        Spacer()
                        Text(service.date)
                            .font(.caption(.regular))
                            .foregroundColor(PropDocsColors.labelTertiary)
                    }
                }
            }
            .navigationTitle("Service History")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

// MARK: - Supporting Models

struct AssetDetailRow {
    let label: String
    let value: String
}

struct ServiceHistoryItem {
    let title: String
    let provider: String
    let cost: String
    let date: String
}

#Preview {
    AssetDetailView(
        asset: MockAsset(
            title: "Central HVAC System",
            category: .hvac,
            brand: "Carrier",
            status: .good,
            systemImage: "wind"
        )
    )
}