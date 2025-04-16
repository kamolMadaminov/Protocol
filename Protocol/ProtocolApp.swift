//
//  ProtocolApp.swift
//  Protocol
//
//  Created by Kamol Madaminov on 11/04/25.
//

import SwiftUI
import SwiftData

@main
struct ProtocolApp: App {
    
    let sharedModelContainer: ModelContainer
    
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false

    init() {
        // Initialize the container first
        let schema = Schema([DailyLog.self, Habit.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            sharedModelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
            print("ModelContainer created successfully.") // Debug print
            
            // --- Trigger Data Retention Check ---
            // This runs the check in the background via Task.detached within the manager
             print("Triggering data retention check...") // Debug print
            DataRetentionManager.performCleanup(container: sharedModelContainer)
            // --- End Trigger ---
            
        } catch {
             fatalError("Could not create ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
                    if hasCompletedOnboarding {
                        ContentView()
                    } else {
                        OnboardingContainerView(onComplete: {
                            hasCompletedOnboarding = true
                        })
                    }
                }
                .modelContainer(sharedModelContainer)
    }
}
