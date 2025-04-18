import SwiftUI

struct OnboardingContainerView: View {
    var onComplete: () -> Void

    @State private var currentTab = 0
    private let totalPages = 4 // Define the total number of pages

    var body: some View {
        VStack {
            TabView(selection: $currentTab) {
                OnboardingPageView(
                    imageName: "figure.wave",
                    title: "Welcome to Protocol",
                    description: "Your personal companion for tracking daily habits, mood, and reflections to foster self-awareness and consistency."
                )
                .tag(0)

                OnboardingPageView(
                    imageName: "doc.text.image",
                    title: "Track Your Day",
                    description: "Use the 'Today' tab as your daily dashboard. Log completed habits, record your mood, add brief notes, and reflect on your day."
                )
                .tag(1)

                OnboardingPageView(
                    imageName: "list.bullet.clipboard",
                    title: "Review Your Journey",
                    description: "The 'Logs' tab provides a historical view of your entries. Observe patterns and track your progress over time."
                )
                .tag(2)

                OnboardingPageView(
                    imageName: "gear",
                    title: "Customize & Manage",
                    description: "Define the habits you want to track and manage application settings in the 'Settings' tab. Tailor Protocol to your needs."
                )
                .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))

            // Single Button outside the TabView
            if currentTab == totalPages - 1 { // Last page
                Button("Get Started") {
                    withAnimation { // Add animation for the completion action
                        onComplete()
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(hex: "#4EC5A7")) // Teal Green
                .controlSize(.large)
                .padding(.bottom, 50)
                .transition(.opacity.combined(with: .scale))
            } else {
                Button("Next") {
                    withAnimation { // Animate the tab change
                        currentTab += 1
                    }
                }
                .buttonStyle(.bordered)
                .tint(Color(hex: "#30D0A0")) // Emerald Green
                .controlSize(.large)
                .padding(.bottom, 50)
                .transition(.opacity.combined(with: .scale))
            }
        }
        .background().ignoresSafeArea()
    }
}

struct OnboardingPageView: View {
    let imageName: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Spacer()

            Image(systemName: imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .foregroundStyle(Color(hex: "#30D0A0")) // Emerald Green
                .padding(.bottom, 30)

            Spacer()
            Spacer()

            Text(title)
                .font(.system(.largeTitle, design: .rounded, weight: .bold))
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Text(description)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
                .lineSpacing(5)

            Spacer()
        }
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
