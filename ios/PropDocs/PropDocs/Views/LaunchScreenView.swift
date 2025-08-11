//
//  LaunchScreenView.swift
//  PropDocs
//
//  Launch/loading screen based on loading-state.html prototype
//

import SwiftUI

struct LaunchScreenView: View {
    
    @State private var isLoading = true
    @State private var progress: Double = 0.0
    @State private var logoScale: CGFloat = 0.8
    @State private var logoOpacity: Double = 0.0
    @State private var showProgressBar = false
    @State private var loadingText = "Loading your properties..."
    
    let onLoadingComplete: () -> Void
    
    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(
                colors: [.propDocsBlue, .propDocsIndigo],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Loading Content
            VStack(spacing: Spacing.xl) {
                Spacer()
                
                // Logo Section
                VStack(spacing: Spacing.lg) {
                    // PropDocs Logo/Text (placeholder - in real app this would be an image)
                    Text("PropDocs")
                        .font(.system(size: 42, weight: .bold, design: .default))
                        .foregroundColor(.white)
                        .scaleEffect(logoScale)
                        .opacity(logoOpacity)
                        .animation(.easeInOut(duration: 1.0), value: logoScale)
                        .animation(.easeInOut(duration: 1.0), value: logoOpacity)
                    
                    // Subtitle
                    Text("Property Management Made Simple")
                        .font(.title3(.medium))
                        .foregroundColor(.white.opacity(0.8))
                        .opacity(logoOpacity)
                        .animation(.easeInOut(duration: 1.0).delay(0.3), value: logoOpacity)
                }
                
                Spacer()
                
                // Loading Section
                VStack(spacing: Spacing.lg) {
                    // Loading Spinner
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.2)
                    }
                    
                    // Progress Bar
                    if showProgressBar {
                        VStack(spacing: Spacing.md) {
                            ProgressBar(
                                progress: progress,
                                height: 4,
                                backgroundColor: .white.opacity(0.3),
                                foregroundColor: .white
                            )
                            .frame(width: 200)
                            .animation(.easeInOut(duration: 0.3), value: progress)
                            
                            // Loading Text
                            Text(loadingText)
                                .font(.subheadline(.regular))
                                .foregroundColor(.white.opacity(0.7))
                                .animation(.easeInOut(duration: 0.5), value: loadingText)
                        }
                    }
                }
                .padding(.bottom, Spacing.xl)
            }
            .padding(Spacing.lg)
        }
        .onAppear {
            startLoadingSequence()
        }
    }
    
    private func startLoadingSequence() {
        // Initial logo animation
        withAnimation(.easeInOut(duration: 1.0)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }
        
        // Show progress bar after logo animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeInOut(duration: 0.5)) {
                showProgressBar = true
            }
            
            // Simulate loading progress
            simulateLoadingProgress()
        }
    }
    
    private func simulateLoadingProgress() {
        let loadingSteps: [(Double, String)] = [
            (0.2, "Loading your properties..."),
            (0.4, "Fetching assets..."),
            (0.6, "Checking maintenance schedule..."),
            (0.8, "Syncing data..."),
            (1.0, "Almost ready...")
        ]
        
        for (index, step) in loadingSteps.enumerated() {
            let delay = Double(index) * 0.8
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    progress = step.0
                    loadingText = step.1
                }
                
                // Complete loading on final step
                if step.0 >= 1.0 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        completeLoading()
                    }
                }
            }
        }
    }
    
    private func completeLoading() {
        withAnimation(.easeInOut(duration: 0.5)) {
            isLoading = false
        }
        
        // Call completion handler
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onLoadingComplete()
        }
    }
}

// MARK: - Minimal Loading View

struct MinimalLoadingView: View {
    
    @State private var logoOpacity: Double = 0.0
    @State private var logoScale: CGFloat = 0.8
    
    var body: some View {
        VStack {
            Spacer()
            
            // Simple PropDocs logo/text
            Text("PropDocs")
                .font(.title1(.bold))
                .foregroundColor(PropDocsColors.labelPrimary)
                .scaleEffect(logoScale)
                .opacity(logoOpacity)
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                        logoScale = 1.1
                        logoOpacity = 1.0
                    }
                }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(PropDocsColors.backgroundPrimary)
    }
}

// MARK: - Preview

#Preview("Launch Screen") {
    LaunchScreenView {
        print("Loading complete")
    }
}

#Preview("Minimal Loading") {
    MinimalLoadingView()
}