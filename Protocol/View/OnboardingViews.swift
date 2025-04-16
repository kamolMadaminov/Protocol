import SwiftUI

struct OnboardingContainerView: View {
    var onComplete: () -> Void

    @State private var currentTab = 0

    var body: some View {
        TabView(selection: $currentTab) {
            OnboardingPageView(
                imageName: "figure.wave",
                title: "Welcome to Protocol",
                description: "Your personal companion for tracking daily habits, mood, and reflections to foster self-awareness and consistency.",
                isLastPage: false,
                currentPage: $currentTab
            )
            .tag(0)

            OnboardingPageView(
                imageName: "doc.text.image",
                title: "Track Your Day",
                description: "Use the 'Today' tab as your daily dashboard. Log completed habits, record your mood, add brief notes, and reflect on your day.",
                isLastPage: false,
                currentPage: $currentTab
            )
            .tag(1)

            OnboardingPageView(
                imageName: "list.bullet.clipboard",
                title: "Review Your Journey",
                description: "The 'Logs' tab provides a historical view of your entries. Observe patterns and track your progress over time.",
                isLastPage: false,
                currentPage: $currentTab
            )
            .tag(2)

            OnboardingPageView(
                imageName: "gear",
                title: "Customize & Manage",
                description: "Define the habits you want to track and manage application settings in the 'Settings' tab. Tailor Protocol to your needs.",
                isLastPage: true,
                currentPage: $currentTab,
                onComplete: onComplete
            )
            .tag(3)
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .background(Color(hex: "#1E2A47").ignoresSafeArea()) // Apply Navy Blue background
    }
}

struct OnboardingPageView: View {
    let imageName: String
    let title: String
    let description: String
    let isLastPage: Bool
    @Binding var currentPage: Int
    var onComplete: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .foregroundStyle(Color(hex: "#30D0A0")) // Apply Emerald Green to icons
                .padding(.bottom, 30)

            Spacer()

            Text(title)
                .font(.system(.largeTitle, design: .rounded, weight: .bold))
                .foregroundColor(.white) // Ensure text is readable on Navy Blue
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Text(description)
                .font(.body)
                .foregroundColor(.white.opacity(0.7)) // Use a lighter shade for description
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
                .lineSpacing(5)

            Spacer()

            if isLastPage {
                Button("Get Started") {
                    onComplete?()
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(hex: "#4EC5A7")) // Apply Teal Green to "Get Started" button
                .controlSize(.large)
                .padding(.bottom, 50)
            } else {
                Button("Next") {
                    withAnimation {
                        currentPage += 1
                    }
                }
                .buttonStyle(.bordered)
                .tint(Color(hex: "#30D0A0")) // Apply Emerald Green to "Next" button
                .controlSize(.large)
                .padding(.bottom, 50)
            }
        }
        .padding(.vertical)
    }
}

#Preview("Onboarding Flow") {
    OnboardingContainerView(onComplete: {
        print("Preview: Onboarding Completed!")
    })
}

extension Color {
    init(hex: String) {
        var cleanString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        cleanString = cleanString.replacingOccurrences(of: "#", with: "")
        var base: UInt64 = 0
        Scanner(string: cleanString).scanHexInt64(&base)
        let red = Double((base >> 16) & 0xFF) / 255.0
        let green = Double((base >> 8) & 0xFF) / 255.0
        let blue = Double(base & 0xFF) / 255.0
        self.init(red: red, green: green, blue: blue)
    }
}
