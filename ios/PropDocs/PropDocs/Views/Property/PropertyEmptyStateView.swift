//
//  PropertyEmptyStateView.swift
//  PropDocs
//
//  Empty state view shown when user has no properties
//

import SwiftUI

struct PropertyEmptyStateView: View {
    
    @State private var showingPropertyCreation = false
    
    var body: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()
            
            // Illustration
            VStack(spacing: Spacing.lg) {
                ZStack {
                    Circle()
                        .fill(Color.propDocsBlue.opacity(0.1))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "house.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.propDocsBlue)
                }
                
                VStack(spacing: Spacing.md) {
                    Text("Welcome to PropDocs!")
                        .font(.title.weight(.bold))
                        .foregroundColor(PropDocsColors.labelPrimary)
                    
                    Text("Start managing your property by adding your first property. Track assets, schedule maintenance, and keep everything organized in one place.")
                        .font(.body.weight(.regular))
                        .foregroundColor(PropDocsColors.labelSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Spacing.lg)
                }
            }
            
            Spacer()
            
            // Action Button
            VStack(spacing: Spacing.lg) {
                PropDocsButton(
                    "Add Your First Property",
                    style: .primary
                ) {
                    showingPropertyCreation = true
                }
                .padding(.horizontal, Spacing.lg)
                
                // Optional: Add sample data button for testing
                #if DEBUG
                PropDocsButton(
                    "Add Sample Property",
                    style: .secondary
                ) {
                    createSampleProperty()
                }
                .padding(.horizontal, Spacing.lg)
                #endif
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(PropDocsColors.groupedBackgroundPrimary)
        .sheet(isPresented: $showingPropertyCreation) {
            PropertyCreationView(isOnboardingMode: true)
        }
    }
    
    #if DEBUG
    private func createSampleProperty() {
        // This would create a sample property for testing purposes
        // Implementation would depend on your PropertyViewModel
    }
    #endif
}

// MARK: - Compact Empty State

struct CompactPropertyEmptyStateView: View {
    
    @State private var showingPropertyCreation = false
    
    var body: some View {
        VStack(spacing: Spacing.lg) {
            VStack(spacing: Spacing.md) {
                Image(systemName: "house.circle")
                    .font(.system(size: 40))
                    .foregroundColor(Color.propDocsBlue)
                
                VStack(spacing: Spacing.sm) {
                    Text("No Properties Yet")
                        .font(.headline.weight(.semibold))
                        .foregroundColor(PropDocsColors.labelPrimary)
                    
                    Text("Add your first property to start tracking assets and maintenance.")
                        .font(.footnote.weight(.regular))
                        .foregroundColor(PropDocsColors.labelSecondary)
                        .multilineTextAlignment(.center)
                }
            }
            
            PropDocsButton(
                "Add Property",
                style: .primary,
                size: .compact
            ) {
                showingPropertyCreation = true
            }
        }
        .padding(Spacing.lg)
        .background(PropDocsColors.groupedBackgroundSecondary)
        .cornerRadius(CornerRadius.lg)
        .sheet(isPresented: $showingPropertyCreation) {
            PropertyCreationView()
        }
    }
}

#Preview("Full Screen Empty State") {
    PropertyEmptyStateView()
}

#Preview("Compact Empty State") {
    CompactPropertyEmptyStateView()
        .padding()
        .background(PropDocsColors.groupedBackgroundPrimary)
}