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
    
    var body: some View {
        Group {
            if authenticationViewModel.authenticationStatus.isAuthenticated {
                // Main app interface
                MainTabView()
                    .environmentObject(propertyViewModel)
                    .environmentObject(authenticationViewModel)
            } else {
                // Authentication/onboarding flow
                OnboardingFlowView()
                    .environmentObject(authenticationViewModel)
            }
        }
        .onAppear {
            // Check authentication status on app launch
            authenticationViewModel.checkAuthenticationStatus()
        }
        .animation(.easeInOut(duration: 0.3), value: authenticationViewModel.authenticationStatus.isAuthenticated)
    }
}

#Preview {
    ContentView()
}
