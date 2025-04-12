//
//  ProtocolApp.swift
//  Protocol
//
//  Created by Kamol Madaminov on 11/04/25.
//

import SwiftUI
import SwiftData

@main
struct ProtocolApp: App { // <-- Replace ProtocolApp with your actual App Name

    // Setup the shared SwiftData model container
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            DailyLog.self // Make sure DailyLog is included
            // Add other models here if you create more
        ])
        // Use persistent storage (not in-memory) for the actual app
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }() // <-- Executes the closure to create the container

    var body: some Scene {
        WindowGroup {
            // Use ContentView as the root view inside the window
            ContentView()
        }
        // Apply the container to the entire window group scene
        .modelContainer(sharedModelContainer)
    }
}
