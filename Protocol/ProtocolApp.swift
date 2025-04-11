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
    var body: some Scene {
        WindowGroup {
            TodayView()
        }
        .modelContainer(for: DailyLog.self)
    }
}
