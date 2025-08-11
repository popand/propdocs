//
//  MainTabView.swift
//  PropDocs
//
//  Main tab navigation structure based on the design prototypes
//

import SwiftUI

struct MainTabView: View {
    
    @StateObject private var propertyViewModel = PropertyViewModel()
    @State private var selectedTab: Tab = .home
    
    enum Tab: String, CaseIterable {
        case home = "Home"
        case assets = "Assets"
        case schedule = "Schedule"
        case reports = "Reports"
        case settings = "Settings"
        
        var systemImage: String {
            switch self {
            case .home: return "house.fill"
            case .assets: return "shippingbox.fill"
            case .schedule: return "calendar.circle.fill"
            case .reports: return "chart.bar.fill"
            case .settings: return "gear"
            }
        }
        
        var selectedSystemImage: String {
            return systemImage
        }
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            NavigationView {
                HomeView()
                    .environmentObject(propertyViewModel)
            }
            .tabItem {
                Image(systemName: selectedTab == .home ? Tab.home.selectedSystemImage : Tab.home.systemImage)
                Text(Tab.home.rawValue)
            }
            .tag(Tab.home)
            
            // Assets Tab
            NavigationView {
                AssetListView()
                    .environmentObject(propertyViewModel)
            }
            .tabItem {
                Image(systemName: selectedTab == .assets ? Tab.assets.selectedSystemImage : Tab.assets.systemImage)
                Text(Tab.assets.rawValue)
            }
            .tag(Tab.assets)
            
            // Schedule Tab
            NavigationView {
                MaintenanceScheduleView()
                    .environmentObject(propertyViewModel)
            }
            .tabItem {
                Image(systemName: selectedTab == .schedule ? Tab.schedule.selectedSystemImage : Tab.schedule.systemImage)
                Text(Tab.schedule.rawValue)
            }
            .tag(Tab.schedule)
            
            // Reports Tab (Placeholder for now)
            NavigationView {
                ReportsView()
                    .environmentObject(propertyViewModel)
            }
            .tabItem {
                Image(systemName: selectedTab == .reports ? Tab.reports.selectedSystemImage : Tab.reports.systemImage)
                Text(Tab.reports.rawValue)
            }
            .tag(Tab.reports)
            
            // Settings Tab
            NavigationView {
                SettingsView()
                    .environmentObject(propertyViewModel)
            }
            .tabItem {
                Image(systemName: selectedTab == .settings ? Tab.settings.selectedSystemImage : Tab.settings.systemImage)
                Text(Tab.settings.rawValue)
            }
            .tag(Tab.settings)
        }
        .accentColor(.propDocsBlue)
        .onAppear {
            configureTabBarAppearance()
        }
    }
    
    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        appearance.shadowColor = UIColor.separator.withAlphaComponent(0.3)
        
        // Configure selected state
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color.propDocsBlue)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(Color.propDocsBlue),
            .font: UIFont.systemFont(ofSize: 11, weight: .medium)
        ]
        
        // Configure normal state
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.secondaryLabel
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.secondaryLabel,
            .font: UIFont.systemFont(ofSize: 11, weight: .medium)
        ]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

// MARK: - Placeholder Views

struct ReportsView: View {
    var body: some View {
        VStack {
            Image(systemName: "chart.bar.fill")
                .font(.system(size: 64))
                .foregroundColor(PropDocsColors.labelTertiary)
                .padding()
            
            Text("Reports")
                .font(.title2(.semibold))
                .foregroundColor(PropDocsColors.labelPrimary)
            
            Text("Coming Soon")
                .font(.subheadline(.regular))
                .foregroundColor(PropDocsColors.labelSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(PropDocsColors.groupedBackgroundPrimary)
        .navigationTitle("Reports")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    MainTabView()
}