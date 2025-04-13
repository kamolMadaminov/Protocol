//
//  ContentView.swift
//  Protocol
//
//  Created by Kamol Madaminov on 11/04/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            TodayView()
                .tabItem {
                    Label("Today", systemImage: "doc.text.image")
                }
                .tag(0)

            LogsView()
                .tabItem {
                    Label("Logs", systemImage: "list.bullet.clipboard")
                }
                .tag(1)
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(2)
        }
    }
}

#Preview {
    ContentView()
}
