//
//  ContentView.swift
//  PropDocs
//
//  Main content view that shows the appropriate interface based on authentication state
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var authenticationViewModel = AuthenticationViewModel()
    @StateObject private var propertyViewModel = PropertyViewModel()
    @State private var isOnboardingPresented = true
    
    var body: some View {
        contentView
            .onAppear {
                // Check authentication status on app launch
                authenticationViewModel.checkAuthenticationStatus()
            }
            .animation(.easeInOut(duration: 0.3), value: authenticationViewModel.authenticationStatus.isAuthenticated)
    }
    
    @ViewBuilder
    private var contentView: some View {
        if authenticationViewModel.authenticationStatus.isAuthenticated {
            // Main app interface
            MainTabView()
                .environmentObject(propertyViewModel)
                .environmentObject(authenticationViewModel)
        } else {
            // Authentication/onboarding flow
            OnboardingFlowView(isPresented: $isOnboardingPresented)
                .environmentObject(authenticationViewModel)
                .onChange(of: isOnboardingPresented) { newValue in
                    if !newValue {
                        // Onboarding was dismissed, check authentication status again
                        authenticationViewModel.checkAuthenticationStatus()
                    }
                }
        }
    }
}

#Preview {
    ContentView()
}
