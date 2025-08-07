//
//  OnboardingViewModel.swift
//  PropDocs
//
//  Created by Andrei Pop on 2025-08-07.
//

import Foundation
import SwiftUI

@MainActor
class OnboardingViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var currentPage: Int = 0
    @Published var isOnboardingComplete: Bool = false

    // MARK: - Constants

    let pages: [OnboardingPage] = [
        .welcome,
        .assetManagement,
        .maintenance,
        .reports,
    ]

    // MARK: - Computed Properties

    var isLastPage: Bool {
        currentPage == pages.count - 1
    }

    var isFirstPage: Bool {
        currentPage == 0
    }

    var progress: Double {
        Double(currentPage + 1) / Double(pages.count)
    }

    // MARK: - Dependencies

    private let userDefaults: UserDefaults

    // MARK: - Constants for UserDefaults

    private enum UserDefaultsKeys {
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let onboardingCompletedDate = "onboardingCompletedDate"
        static let onboardingVersion = "onboardingVersion"
    }

    private let currentOnboardingVersion = "1.0.0"

    // MARK: - Initialization

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        isOnboardingComplete = hasCompletedOnboarding()
    }

    // MARK: - Public Methods

    func startOnboarding() {
        currentPage = 0
    }

    func nextPage() {
        guard !isLastPage else { return }

        withAnimation(.easeInOut(duration: 0.5)) {
            currentPage += 1
        }
    }

    func previousPage() {
        guard !isFirstPage else { return }

        withAnimation(.easeInOut(duration: 0.5)) {
            currentPage -= 1
        }
    }

    func goToPage(_ page: Int) {
        guard page >= 0, page < pages.count else { return }

        withAnimation(.easeInOut(duration: 0.5)) {
            currentPage = page
        }
    }

    func completeOnboarding() {
        markOnboardingAsCompleted()
        isOnboardingComplete = true
    }

    // MARK: - Completion Tracking

    func hasCompletedOnboarding() -> Bool {
        let hasCompleted = userDefaults.bool(forKey: UserDefaultsKeys.hasCompletedOnboarding)
        let storedVersion = userDefaults.string(forKey: UserDefaultsKeys.onboardingVersion)

        // Check if user has completed onboarding AND it's the current version
        return hasCompleted && storedVersion == currentOnboardingVersion
    }

    func shouldShowOnboarding() -> Bool {
        !hasCompletedOnboarding()
    }

    private func markOnboardingAsCompleted() {
        userDefaults.set(true, forKey: UserDefaultsKeys.hasCompletedOnboarding)
        userDefaults.set(Date(), forKey: UserDefaultsKeys.onboardingCompletedDate)
        userDefaults.set(currentOnboardingVersion, forKey: UserDefaultsKeys.onboardingVersion)
    }

    func resetOnboarding() {
        userDefaults.removeObject(forKey: UserDefaultsKeys.hasCompletedOnboarding)
        userDefaults.removeObject(forKey: UserDefaultsKeys.onboardingCompletedDate)
        userDefaults.removeObject(forKey: UserDefaultsKeys.onboardingVersion)
        isOnboardingComplete = false
        currentPage = 0
    }

    // MARK: - Analytics & Tracking

    func trackPageView(page: OnboardingPage) {
        // This is where you would add analytics tracking
        // For example: Analytics.track("onboarding_page_viewed", properties: ["page": page.id])
        print("📊 Onboarding page viewed: \(page.id)")
    }

    func trackOnboardingCompleted() {
        // This is where you would add analytics tracking
        // For example: Analytics.track("onboarding_completed")
        print("📊 Onboarding completed")
    }

    func trackOnboardingSkipped(fromPage: Int) {
        // This is where you would add analytics tracking
        let pageId = pages[safe: fromPage]?.id ?? "unknown"
        print("📊 Onboarding skipped from page: \(pageId)")
    }

    // MARK: - Helper Methods

    func getPageTitle(for index: Int) -> String {
        pages[safe: index]?.title ?? ""
    }

    func getPageIcon(for index: Int) -> String {
        pages[safe: index]?.iconName ?? "questionmark"
    }

    func getCompletionDate() -> Date? {
        userDefaults.object(forKey: UserDefaultsKeys.onboardingCompletedDate) as? Date
    }

    func getDaysSinceCompletion() -> Int? {
        guard let completionDate = getCompletionDate() else { return nil }

        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.day], from: completionDate, to: now)
        return components.day
    }
}

// MARK: - Array Extension

private extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

// MARK: - Preview Helpers

extension OnboardingViewModel {
    static var preview: OnboardingViewModel {
        let viewModel = OnboardingViewModel()
        return viewModel
    }

    static var previewCompleted: OnboardingViewModel {
        let viewModel = OnboardingViewModel()
        viewModel.completeOnboarding()
        return viewModel
    }

    static var previewLastPage: OnboardingViewModel {
        let viewModel = OnboardingViewModel()
        viewModel.currentPage = viewModel.pages.count - 1
        return viewModel
    }
}
