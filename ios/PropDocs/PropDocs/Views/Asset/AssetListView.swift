//
//  AssetListView.swift
//  PropDocs
//
//  Asset list view with grid/list toggle based on asset-list.html prototype
//

import SwiftUI

struct AssetListView: View {
    
    @EnvironmentObject private var propertyViewModel: PropertyViewModel
    @State private var searchText = ""
    @State private var selectedCategory: AssetCategory = .all
    @State private var viewMode: ViewMode = .grid
    @State private var showingAddAsset = false
    
    enum ViewMode {
        case grid
        case list
    }
    
    enum AssetCategory: String, CaseIterable {
        case all = "All"
        case hvac = "HVAC"
        case plumbing = "Plumbing"
        case electrical = "Electrical"
        case appliances = "Appliances"
        case security = "Security"
        
        var color: Color {
            switch self {
            case .all: return PropDocsColors.labelSecondary
            case .hvac: return .categoryHVAC
            case .plumbing: return .categoryPlumbing
            case .electrical: return .categoryElectrical
            case .appliances: return .categoryAppliances
            case .security: return .categorySecurity
            }
        }
        
        var systemImage: String {
            switch self {
            case .all: return "square.grid.2x2"
            case .hvac: return "wind"
            case .plumbing: return "drop"
            case .electrical: return "bolt"
            case .appliances: return "refrigerator"
            case .security: return "lock.shield"
            }
        }
    }
    
    // Mock asset data - in real app this would come from Core Data
    private let mockAssets: [MockAsset] = [
        MockAsset(
            title: "Central HVAC System",
            category: .hvac,
            brand: "Carrier",
            status: .good,
            systemImage: "wind"
        ),
        MockAsset(
            title: "Water Heater",
            category: .plumbing,
            brand: "Rheem",
            status: .warning,
            systemImage: "drop"
        ),
        MockAsset(
            title: "Kitchen Refrigerator",
            category: .appliances,
            brand: "Samsung",
            status: .good,
            systemImage: "refrigerator"
        ),
        MockAsset(
            title: "Main Electrical Panel",
            category: .electrical,
            brand: "Square D",
            status: .good,
            systemImage: "bolt"
        ),
        MockAsset(
            title: "Security System",
            category: .security,
            brand: "Ring",
            status: .good,
            systemImage: "lock.shield"
        ),
        MockAsset(
            title: "Garage Door Opener",
            category: .hvac,
            brand: "LiftMaster",
            status: .warning,
            systemImage: "garage.closed"
        )
    ]
    
    private var filteredAssets: [MockAsset] {
        var assets = mockAssets
        
        // Filter by category
        if selectedCategory != .all {
            assets = assets.filter { $0.category == selectedCategory }
        }
        
        // Filter by search
        if !searchText.isEmpty {
            assets = assets.filter { asset in
                asset.title.localizedCaseInsensitiveContains(searchText) ||
                asset.brand.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return assets
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Search and Filter Header
            SearchAndFilterHeader(
                searchText: $searchText,
                selectedCategory: $selectedCategory,
                viewMode: $viewMode
            )
            
            // Assets Content
            ScrollView {
                LazyVStack(spacing: 0) {
                    if viewMode == .grid {
                        AssetGridView(assets: filteredAssets)
                    } else {
                        AssetListSectionView(assets: filteredAssets)
                    }
                }
                .padding(.top, Spacing.md)
            }
            .background(PropDocsColors.groupedBackgroundPrimary)
        }
        .navigationTitle("Assets")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                IconButton(systemImage: "gear") {
                    // Handle settings
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
                        showingAddAsset = true
                    }
                    .padding(.bottom, 100) // Account for tab bar
                    .padding(.trailing, Spacing.md)
                }
            }
        )
        .sheet(isPresented: $showingAddAsset) {
            AddAssetView()
        }
    }
}

// MARK: - Search and Filter Header

struct SearchAndFilterHeader: View {
    
    @Binding var searchText: String
    @Binding var selectedCategory: AssetListView.AssetCategory
    @Binding var viewMode: AssetListView.ViewMode
    
    var body: some View {
        VStack(spacing: Spacing.md) {
            // Search Bar
            HStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(PropDocsColors.labelTertiary)
                        .font(.body(.medium))
                    
                    TextField("Search assets...", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                }
                .padding(Spacing.sm)
                .background(PropDocsColors.fillTertiary)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.sm))
            }
            .padding(.horizontal, Spacing.md)
            
            // Filter Chips and View Toggle
            HStack {
                // Filter Chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Spacing.sm) {
                        ForEach(AssetListView.AssetCategory.allCases, id: \.self) { category in
                            FilterChip(
                                title: category.rawValue,
                                isSelected: selectedCategory == category
                            ) {
                                selectedCategory = category
                            }
                        }
                    }
                    .padding(.horizontal, Spacing.md)
                }
                
                Spacer()
                
                // View Mode Toggle
                ViewModeToggle(viewMode: $viewMode)
                    .padding(.trailing, Spacing.md)
            }
        }
        .padding(.vertical, Spacing.md)
        .background(PropDocsColors.backgroundPrimary)
        .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
    }
}

// MARK: - Filter Chip

struct FilterChip: View {
    
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.footnote(.medium))
                .foregroundColor(isSelected ? .white : PropDocsColors.labelPrimary)
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)
                .background(isSelected ? .propDocsBlue : PropDocsColors.fillSecondary)
                .clipShape(Capsule())
        }
    }
}

// MARK: - View Mode Toggle

struct ViewModeToggle: View {
    
    @Binding var viewMode: AssetListView.ViewMode
    
    var body: some View {
        HStack(spacing: 2) {
            Button(action: { viewMode = .grid }) {
                Text("Grid")
                    .font(.footnote(.medium))
                    .foregroundColor(viewMode == .grid ? PropDocsColors.labelPrimary : PropDocsColors.labelSecondary)
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, Spacing.xs)
                    .background(viewMode == .grid ? PropDocsColors.backgroundPrimary : .clear)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
            
            Button(action: { viewMode = .list }) {
                Text("List")
                    .font(.footnote(.medium))
                    .foregroundColor(viewMode == .list ? PropDocsColors.labelPrimary : PropDocsColors.labelSecondary)
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, Spacing.xs)
                    .background(viewMode == .list ? PropDocsColors.backgroundPrimary : .clear)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
        }
        .padding(2)
        .background(PropDocsColors.fillSecondary)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Asset Grid View

struct AssetGridView: View {
    
    let assets: [MockAsset]
    
    private let columns = [
        GridItem(.flexible(), spacing: Spacing.md),
        GridItem(.flexible(), spacing: Spacing.md)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: Spacing.md) {
            ForEach(assets, id: \.id) { asset in
                AssetGridCard(asset: asset)
            }
        }
        .padding(.horizontal, Spacing.md)
    }
}

// MARK: - Asset Grid Card

struct AssetGridCard: View {
    
    let asset: MockAsset
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            // Asset Image/Icon
            ZStack {
                RoundedRectangle(cornerRadius: CornerRadius.sm)
                    .fill(
                        LinearGradient(
                            colors: [Color.gray.opacity(0.1), Color.gray.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 120)
                
                Image(systemName: asset.systemImage)
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(asset.category.color)
            }
            
            // Asset Info
            VStack(alignment: .leading, spacing: 4) {
                Text(asset.title)
                    .font(.footnote(.semibold))
                    .foregroundColor(PropDocsColors.labelPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                Text("\(asset.category.rawValue) • \(asset.brand)")
                    .font(.caption(.regular))
                    .foregroundColor(PropDocsColors.labelSecondary)
                
                HStack {
                    StatusDot(asset.status.statusDotStatus, size: 6)
                    Text(asset.status.displayName)
                        .font(.caption2(.regular))
                        .foregroundColor(PropDocsColors.labelSecondary)
                }
            }
        }
        .padding(Spacing.md)
        .background(PropDocsColors.groupedBackgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        .onTapGesture {
            // Handle asset tap
        }
    }
}

// MARK: - Asset List Section View

struct AssetListSectionView: View {
    
    let assets: [MockAsset]
    
    private var groupedAssets: [AssetListView.AssetCategory: [MockAsset]] {
        Dictionary(grouping: assets) { $0.category }
    }
    
    var body: some View {
        LazyVStack(spacing: Spacing.lg) {
            ForEach(AssetListView.AssetCategory.allCases.filter { category in
                category != .all && groupedAssets[category] != nil
            }, id: \.self) { category in
                AssetCategorySection(
                    category: category,
                    assets: groupedAssets[category] ?? []
                )
            }
        }
    }
}

// MARK: - Asset Category Section

struct AssetCategorySection: View {
    
    let category: AssetListView.AssetCategory
    let assets: [MockAsset]
    
    var body: some View {
        VStack(spacing: 0) {
            // Section Header
            HStack {
                HStack(spacing: Spacing.sm) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(category.color)
                            .frame(width: 24, height: 24)
                        
                        Image(systemName: category.systemImage)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                    }
                    
                    Text(category.rawValue)
                        .font(.title3(.semibold))
                        .foregroundColor(PropDocsColors.labelPrimary)
                }
                
                Spacer()
                
                Text("\(assets.count)")
                    .font(.footnote(.medium))
                    .foregroundColor(PropDocsColors.labelSecondary)
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, 4)
                    .background(PropDocsColors.fillSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
            .padding(.horizontal, Spacing.md)
            .padding(.bottom, Spacing.sm)
            
            // Assets List
            LazyVStack(spacing: 0) {
                ForEach(Array(assets.enumerated()), id: \.offset) { index, asset in
                    AssetListRow(asset: asset)
                    
                    if index < assets.count - 1 {
                        Divider()
                            .padding(.leading, 76) // Account for thumbnail + padding
                    }
                }
            }
            .background(PropDocsColors.groupedBackgroundSecondary)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
            .padding(.horizontal, Spacing.md)
        }
    }
}

// MARK: - Asset List Row

struct AssetListRow: View {
    
    let asset: MockAsset
    
    var body: some View {
        HStack(spacing: Spacing.md) {
            // Asset Thumbnail
            ZStack {
                RoundedRectangle(cornerRadius: CornerRadius.sm)
                    .fill(
                        LinearGradient(
                            colors: [Color.gray.opacity(0.1), Color.gray.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 48, height: 48)
                
                Image(systemName: asset.systemImage)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(asset.category.color)
            }
            
            // Asset Content
            VStack(alignment: .leading, spacing: 2) {
                Text(asset.title)
                    .font(.body(.medium))
                    .foregroundColor(PropDocsColors.labelPrimary)
                    .lineLimit(1)
                
                Text("\(asset.brand) • Model: ABC123")
                    .font(.footnote(.regular))
                    .foregroundColor(PropDocsColors.labelSecondary)
                    .lineLimit(1)
                
                HStack {
                    StatusDot(asset.status.statusDotStatus, size: 6)
                    Text("Last service: 2 months ago")
                        .font(.caption(.regular))
                        .foregroundColor(PropDocsColors.labelSecondary)
                }
                .padding(.top, 2)
            }
            
            Spacer()
            
            // Chevron
            Image(systemName: "chevron.right")
                .font(.footnote(.medium))
                .foregroundColor(PropDocsColors.labelTertiary)
        }
        .padding(Spacing.md)
        .contentShape(Rectangle())
        .onTapGesture {
            // Handle asset tap
        }
    }
}

// MARK: - Add Asset View (Placeholder)

struct AddAssetView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Add Asset")
                    .font(.title.weight(.bold))
                
                Text("Asset creation form would go here")
                    .font(.body)
                    .foregroundColor(PropDocsColors.labelSecondary)
            }
            .navigationTitle("New Asset")
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

// MARK: - Mock Asset Model

struct MockAsset {
    let id = UUID()
    let title: String
    let category: AssetListView.AssetCategory
    let brand: String
    let status: AssetStatus
    let systemImage: String
    
    enum AssetStatus {
        case good
        case warning
        case critical
        
        var displayName: String {
            switch self {
            case .good: return "Good"
            case .warning: return "Needs Service"
            case .critical: return "Critical"
            }
        }
        
        var statusDotStatus: StatusDot.Status {
            switch self {
            case .good: return .good
            case .warning: return .warning
            case .critical: return .critical
            }
        }
    }
}

#Preview {
    NavigationView {
        AssetListView()
            .environmentObject(PropertyViewModel())
    }
}