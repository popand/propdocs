//
//  OnboardingFlowView.swift
//  PropDocs
//
//  Created by Andrei Pop on 2025-08-07.
//

import SwiftUI

struct OnboardingFlowView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @Environment(\.dismiss) private var dismiss
    @Binding var isPresented: Bool

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Progress indicator
                progressIndicator
                    .padding(.horizontal, 24)
                    .padding(.top, 16)

                // Page content
                TabView(selection: $viewModel.currentPage) {
                    ForEach(0 ..< viewModel.pages.count, id: \.self) { index in
                        OnboardingPageView(page: viewModel.pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.5), value: viewModel.currentPage)

                // Action buttons
                actionButtons
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            viewModel.startOnboarding()
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Onboarding Flow")
    }

    // MARK: - Progress Indicator

    private var progressIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0 ..< viewModel.pages.count, id: \.self) { index in
                Circle()
                    .fill(index <= viewModel.currentPage ? Color.blue : Color.gray.opacity(0.3))
                    .frame(width: 8, height: 8)
                    .scaleEffect(index == viewModel.currentPage ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 0.3), value: viewModel.currentPage)
            }

            Spacer()

            // Skip button
            Button("Skip") {
                skipOnboarding()
            }
            .font(.body)
            .foregroundColor(.secondary)
            .accessibilityLabel("Skip onboarding")
        }
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        HStack(spacing: 16) {
            // Back button
            if viewModel.currentPage > 0 {
                Button(action: {
                    viewModel.previousPage()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .medium))
                        Text("Back")
                            .font(.headline)
                    }
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                }
                .accessibilityLabel("Go back to previous page")
                .transition(.move(edge: .leading).combined(with: .opacity))
            }

            // Next/Get Started button
            Button(action: {
                if viewModel.isLastPage {
                    completeOnboarding()
                } else {
                    viewModel.nextPage()
                }
            }) {
                HStack(spacing: 8) {
                    Text(viewModel.isLastPage ? "Get Started" : "Next")
                        .font(.headline)

                    if !viewModel.isLastPage {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16, weight: .medium))
                    } else {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 18, weight: .medium))
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(viewModel.isLastPage ? Color.green : Color.blue)
                .cornerRadius(12)
            }
            .accessibilityLabel(viewModel.isLastPage ? "Complete onboarding and get started" : "Go to next page")
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.currentPage)
    }

    // MARK: - Actions

    private func skipOnboarding() {
        viewModel.completeOnboarding()
        isPresented = false
    }

    private func completeOnboarding() {
        viewModel.completeOnboarding()
        isPresented = false
    }
}

// MARK: - Preview

struct OnboardingFlowView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Light mode
            OnboardingFlowView(isPresented: .constant(true))
                .previewDisplayName("Light Mode")

            // Dark mode
            OnboardingFlowView(isPresented: .constant(true))
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")

            // Different device sizes
            OnboardingFlowView(isPresented: .constant(true))
                .previewDevice("iPhone SE (3rd generation)")
                .previewDisplayName("iPhone SE")
        }
    }
}
