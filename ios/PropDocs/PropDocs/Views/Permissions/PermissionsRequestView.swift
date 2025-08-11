//
//  PermissionsRequestView.swift
//  PropDocs
//
//  Created by Andrei Pop on 2025-08-07.
//

import SwiftUI

struct PermissionsRequestView: View {
    @StateObject private var viewModel = PermissionsViewModel()
    @Environment(\.dismiss) private var dismiss
    @Binding var isPresented: Bool
    
    @State private var currentPermissionIndex = 0
    @State private var showingSettings = false
    
    var body: some View {
        NavigationView {
            ZStack {
                backgroundGradient
                
                VStack(spacing: 32) {
                    headerSection
                    permissionsList
                    actionButtons
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 40)
            }
            .navigationTitle("Permissions")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Skip") {
                        handleSkip()
                    }
                    .foregroundColor(.blue)
                }
            }
            .onAppear {
                Task {
                    await viewModel.checkAllPermissions()
                }
            }
            .alert("Open Settings", isPresented: $showingSettings) {
                Button("Settings") {
                    viewModel.openSettings()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("To change permissions, please go to Settings > PropDocs")
            }
        }
    }
    
    // MARK: - Background
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color.blue.opacity(0.1),
                Color.purple.opacity(0.05),
                Color.clear
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "shield.checkered")
                .font(.system(size: 60, weight: .light))
                .foregroundColor(.blue)
            
            VStack(spacing: 8) {
                Text("Privacy & Permissions")
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("PropDocs needs certain permissions to provide the best experience for managing your property assets.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
            }
        }
    }
    
    // MARK: - Permissions List
    
    private var permissionsList: some View {
        VStack(spacing: 20) {
            ForEach(PermissionType.allCases, id: \.rawValue) { permission in
                PermissionRowView(
                    permission: permission,
                    status: viewModel.getStatus(for: permission),
                    onRequest: {
                        Task {
                            await handlePermissionRequest(permission)
                        }
                    }
                )
            }
        }
    }
    
    // MARK: - Action Buttons
    
    private var actionButtons: some View {
        VStack(spacing: 16) {
            if viewModel.allPermissionsGranted {
                Button("Continue") {
                    handleContinue()
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(viewModel.isLoading)
            } else {
                Button("Grant All Permissions") {
                    Task {
                        await handleGrantAllPermissions()
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(viewModel.isLoading)
                
                Button("Continue Without All Permissions") {
                    handleContinue()
                }
                .buttonStyle(SecondaryButtonStyle())
                .disabled(viewModel.isLoading)
            }
            
            if viewModel.isLoading {
                ProgressView("Checking permissions...")
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // MARK: - Actions
    
    private func handlePermissionRequest(_ permission: PermissionType) async {
        let result = await viewModel.requestPermission(permission)
        
        if result.status == .denied && result.error == .settingsRequired {
            showingSettings = true
        }
    }
    
    private func handleGrantAllPermissions() async {
        let results = await viewModel.requestAllPermissions()
        
        let hasSettingsRequired = results.contains { result in
            result.error == .settingsRequired
        }
        
        if hasSettingsRequired {
            showingSettings = true
        }
    }
    
    private func handleContinue() {
        isPresented = false
        dismiss()
    }
    
    private func handleSkip() {
        isPresented = false
        dismiss()
    }
}

// MARK: - Permission Row View

struct PermissionRowView: View {
    let permission: PermissionType
    let status: PermissionStatus
    let onRequest: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            iconView
            contentView
            statusView
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
        )
    }
    
    private var iconView: some View {
        ZStack {
            Circle()
                .fill(iconBackgroundColor)
                .frame(width: 50, height: 50)
            
            Image(systemName: permission.icon)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(iconForegroundColor)
        }
    }
    
    private var contentView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(permission.displayName)
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(permission.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var statusView: some View {
        Group {
            if status.isGranted {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title3)
                    .foregroundColor(.green)
            } else {
                Button(actionTitle) {
                    onRequest()
                }
                .buttonStyle(CompactButtonStyle())
            }
        }
    }
    
    private var iconBackgroundColor: Color {
        switch permission {
        case .camera:
            return .blue.opacity(0.15)
        case .photoLibrary:
            return .purple.opacity(0.15)
        case .notifications:
            return .orange.opacity(0.15)
        }
    }
    
    private var iconForegroundColor: Color {
        switch permission {
        case .camera:
            return .blue
        case .photoLibrary:
            return .purple
        case .notifications:
            return .orange
        }
    }
    
    private var actionTitle: String {
        switch status {
        case .notDetermined:
            return "Allow"
        case .denied, .restricted:
            return "Settings"
        case .authorized, .limited:
            return "Granted"
        }
    }
}

// MARK: - Button Styles

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.blue)
                    .opacity(configuration.isPressed ? 0.8 : 1.0)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.medium))
            .foregroundColor(.blue)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.blue, lineWidth: 1.5)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemBackground))
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct CompactButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.caption.weight(.semibold))
            .foregroundColor(.blue)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(.blue.opacity(0.1))
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Preview

#Preview {
    PermissionsRequestView(isPresented: .constant(true))
}