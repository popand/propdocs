//
//  PropertyCreationView.swift
//  PropDocs
//
//  Property creation form for onboarding and adding new properties
//

import SwiftUI

struct PropertyCreationView: View {
    
    @EnvironmentObject private var propertyViewModel: PropertyViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var showingPropertyTypePicker = false
    
    var isOnboardingMode: Bool = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    if isOnboardingMode {
                        // Onboarding Header
                        VStack(spacing: Spacing.md) {
                            Image(systemName: "house.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.propDocsBlue)
                            
                            Text("Add Your First Property")
                                .font(.title2.weight(.bold))
                                .foregroundColor(PropDocsColors.labelPrimary)
                            
                            Text("Let's start by adding your property information to get personalized maintenance insights.")
                                .font(.body.weight(.regular))
                                .foregroundColor(PropDocsColors.labelSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, Spacing.xl)
                    }
                    
                    // Property Form
                    PropertyFormContent(
                        showingPropertyTypePicker: $showingPropertyTypePicker
                    )
                    .environmentObject(propertyViewModel)
                    
                    Spacer()
                    
                    // Action Buttons
                    VStack(spacing: Spacing.md) {
                        PropDocsButton(
                            isOnboardingMode ? "Create Property" : "Add Property",
                            style: .primary,
                            isLoading: propertyViewModel.isLoading
                        ) {
                            propertyViewModel.createProperty()
                        }
                        .disabled(!isFormValid)
                        
                        if !isOnboardingMode {
                            PropDocsButton(
                                "Cancel",
                                style: .secondary
                            ) {
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                    }
                }
                .padding(Spacing.md)
            }
            .background(PropDocsColors.groupedBackgroundPrimary)
            .navigationTitle(isOnboardingMode ? "Welcome" : "Add Property")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(
                trailing: !isOnboardingMode ? Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                } : nil
            )
            .sheet(isPresented: $showingPropertyTypePicker) {
                PropertyTypePicker(
                    selectedType: $propertyViewModel.selectedPropertyType
                )
            }
            .onChange(of: propertyViewModel.isCreatingProperty) { creating in
                if !creating && !propertyViewModel.properties.isEmpty {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
    
    private var isFormValid: Bool {
        !propertyViewModel.propertyName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !propertyViewModel.propertyAddress.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

// MARK: - Property Form Content

struct PropertyFormContent: View {
    
    @EnvironmentObject private var propertyViewModel: PropertyViewModel
    @Binding var showingPropertyTypePicker: Bool
    
    var body: some View {
        VStack(spacing: Spacing.lg) {
            // Property Name
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("Property Name")
                    .font(.headline.weight(.medium))
                    .foregroundColor(PropDocsColors.labelPrimary)
                
                TextField("e.g., Main Residence, Rental Property", text: $propertyViewModel.propertyName)
                    .textFieldStyle(PropDocsTextFieldStyle())
            }
            
            // Property Address
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("Address")
                    .font(.headline.weight(.medium))
                    .foregroundColor(PropDocsColors.labelPrimary)
                
                TextField("Enter full address", text: $propertyViewModel.propertyAddress)
                    .textFieldStyle(PropDocsTextFieldStyle())
            }
            
            // Property Type
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("Property Type")
                    .font(.headline.weight(.medium))
                    .foregroundColor(PropDocsColors.labelPrimary)
                
                Button(action: {
                    showingPropertyTypePicker = true
                }) {
                    HStack {
                        Text(propertyViewModel.selectedPropertyType.displayName)
                            .foregroundColor(PropDocsColors.labelPrimary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.down")
                            .foregroundColor(PropDocsColors.labelTertiary)
                    }
                    .padding()
                    .background(PropDocsColors.groupedBackgroundSecondary)
                    .cornerRadius(CornerRadius.md)
                    .overlay(
                        RoundedRectangle(cornerRadius: CornerRadius.md)
                            .stroke(PropDocsColors.separator, lineWidth: 1)
                    )
                }
            }
            
            // Error Message
            if let error = propertyViewModel.error {
                Text(error)
                    .font(.footnote.weight(.regular))
                    .foregroundColor(.red)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(CornerRadius.sm)
            }
        }
    }
}

// MARK: - Property Type Picker

struct PropertyTypePicker: View {
    
    @Binding var selectedType: PropertyType
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List(PropertyType.allCases, id: \.self) { type in
                HStack {
                    VStack(alignment: .leading) {
                        Text(type.displayName)
                            .font(.body.weight(.medium))
                            .foregroundColor(PropDocsColors.labelPrimary)
                        
                        if !type.description.isEmpty {
                            Text(type.description)
                                .font(.footnote.weight(.regular))
                                .foregroundColor(PropDocsColors.labelSecondary)
                        }
                    }
                    
                    Spacer()
                    
                    if selectedType == type {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.propDocsBlue)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedType = type
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .navigationTitle("Property Type")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

// MARK: - Custom Text Field Style

struct PropDocsTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(PropDocsColors.groupedBackgroundSecondary)
            .cornerRadius(CornerRadius.md)
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.md)
                    .stroke(PropDocsColors.separator, lineWidth: 1)
            )
    }
}

#Preview("Regular Mode") {
    PropertyCreationView()
        .environmentObject(PropertyViewModel())
}

#Preview("Onboarding Mode") {
    PropertyCreationView(isOnboardingMode: true)
        .environmentObject(PropertyViewModel())
}