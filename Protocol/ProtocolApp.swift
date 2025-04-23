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
        do {
            
            let latestSchema = Schema(AppSchemaV2.models)
            sharedModelContainer = try ModelContainer(
                for: latestSchema, // Pass the Schema OBJECT here
                migrationPlan: MigrationPlan.self // Pass your migration plan type here
            )
            print("ModelContainer created successfully using MigrationPlan.")
            
            // --- Trigger Data Retention Check ---
            print("Triggering data retention check...")
            DataRetentionManager.performCleanup(container: sharedModelContainer)
            // --- End Trigger ---
            
        } catch {
            fatalError("Could not create ModelContainer with MigrationPlan: \(error)")
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
