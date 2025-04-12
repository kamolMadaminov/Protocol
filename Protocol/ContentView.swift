//
//  ContentView.swift
//  Protocol
//
//  Created by Kamol Madaminov on 11/04/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        // TabView allows switching between main sections
        TabView {
            // First Tab: Today's View
            TodayView() // Your existing view
                .tabItem {
                    // Label shown in the tab bar
                    Label("Today", systemImage: "doc.text.image")
                }
                .tag(0) // Optional tag

            // Second Tab: Logs View
            LogsView() // Your new view from Phase 2
                .tabItem {
                    // Label shown in the tab bar
                    Label("Logs", systemImage: "list.bullet.clipboard")
                }
                .tag(1) // Optional tag

            // Add more tabs here if needed in the future
        }
    }
}

#Preview {
    ContentView()
}
