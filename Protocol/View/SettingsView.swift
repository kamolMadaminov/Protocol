//
//  SettingsView.swift
//  Protocol
//
//  Created by Kamol Madaminov on 13/04/25.
//

import SwiftUI

enum SettingsNavigation: Hashable {
    case habitList
}

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Data Management") {
                    // Use NavigationLink with a value
                    NavigationLink(value: SettingsNavigation.habitList) {
                        Label("Manage Habits", systemImage: "list.bullet.rectangle.portrait")
                    }
                    // Other links...
                }

                Section("About") {
                     HStack {
                        Text("App Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationDestination(for: SettingsNavigation.self) { destination in
                switch destination {
                case .habitList:
                    HabitListView() // Navigate to HabitListView
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
         SettingsView()
            .modelContainer(for: Habit.self, inMemory: true)
    }
}
