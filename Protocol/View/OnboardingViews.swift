//
//  OnboardingViews.swift
//  Protocol
//
//  Created by Kamol Madaminov on 16/04/25.
//

import SwiftUI

// Main container for the onboarding pages
struct OnboardingContainerView: View {
    var onComplete: () -> Void // Callback action for when onboarding finishes

    @State private var currentTab = 0 // Tracks the current page index

    var body: some View {
        TabView(selection: $currentTab) {
            // Page 1: Welcome
            OnboardingPageView(
                imageName: "figure.wave",
                title: "Welcome to Protocol",
                description: "Your personal companion for tracking daily habits, mood, and reflections to foster self-awareness and consistency.",
                isLastPage: false,
                currentPage: $currentTab
            )
            .tag(0)

            // Page 2: Today Tab
            OnboardingPageView(
                imageName: "doc.text.image", // Matches Today tab icon
                title: "Track Your Day",
                description: "Use the 'Today' tab as your daily dashboard. Log completed habits, record your mood, add brief notes, and reflect on your day.",
                isLastPage: false,
                currentPage: $currentTab
            )
            .tag(1)

            // Page 3: Logs Tab
            OnboardingPageView(
                imageName: "list.bullet.clipboard", // Matches Logs tab icon
                title: "Review Your Journey",
                description: "The 'Logs' tab provides a historical view of your entries. Observe patterns and track your progress over time.",
                 isLastPage: false,
                 currentPage: $currentTab
             )
            .tag(2)

            // Page 4: Settings Tab & Finish
            OnboardingPageView(
                imageName: "gear", // Matches Settings tab icon
                title: "Customize & Manage",
                description: "Define the habits you want to track and manage application settings in the 'Settings' tab. Tailor Protocol to your needs.",
                isLastPage: true, // This is the final page
                currentPage: $currentTab,
                onComplete: onComplete // Pass the completion action here
            )
            .tag(3)
        }
        .tabViewStyle(.page(indexDisplayMode: .always)) // Creates the swipeable pages with dots
        .background(Color(.systemGroupedBackground).ignoresSafeArea()) // Set a background
    }
}

// Reusable view for the content of each onboarding page
struct OnboardingPageView: View {
    let imageName: String
    let title: String
    let description: String
    let isLastPage: Bool
    @Binding var currentPage: Int
    var onComplete: (() -> Void)? = nil // Only the last page uses this

    var body: some View {
        VStack(spacing: 20) { // Adjusted spacing
            Spacer()

            Image(systemName: imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120) // Slightly larger icon
                .foregroundStyle(Color.accentColor)
                .padding(.bottom, 30)


            Text(title)
                .font(.system(.largeTitle, design: .rounded, weight: .bold)) // Refined font
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Text(description)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30) // Adjust padding
                .lineSpacing(5) // Add line spacing for readability

            Spacer()
            Spacer() // Add more space to push button lower

            // Show "Get Started" on the last page, "Next" otherwise
            if isLastPage {
                 Button("Get Started") {
                     onComplete?() // Call the completion handler passed from Container
                 }
                 .buttonStyle(.borderedProminent)
                 .controlSize(.large) // Make button larger
                 .padding(.bottom, 50)
             } else {
                 Button("Next") {
                     withAnimation { // Animate page transition
                         currentPage += 1
                     }
                 }
                 .buttonStyle(.bordered)
                 .controlSize(.large)
                 .padding(.bottom, 50)
             }
        }
        .padding(.vertical) // Add padding to the VStack content
    }
}

// Preview for the Onboarding Flow
#Preview("Onboarding Flow") {
    OnboardingContainerView(onComplete: {
        print("Preview: Onboarding Completed!")
    })
}
