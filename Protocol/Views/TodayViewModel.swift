//
//  TodayViewModel.swift
//  Protocol
//
//  Created by Kamol Madaminov on 11/04/25.
//

import Foundation

struct Habit: Identifiable, Codable {
    let id = UUID()
    let name: String
    var isCompleted: Bool
}

struct DailyLog: Codable {
    var date: Date
    var mood: String
    var reflection: String
    var habits: [Habit]
}

class ProtocolViewModel: ObservableObject {
    @Published var habits: [Habit] = [
        Habit(name: "🥋 Train", isCompleted: false),
        Habit(name: "📚 Read", isCompleted: false),
        Habit(name: "🛏️ Sleep Early", isCompleted: false)
    ]
    
    @Published var selectedMood: String = "🌫️"
    @Published var reflection: String = ""
    
    // Placeholder logic
    var dailyPrompt: String {
        "Did your actions match your mission?"
    }
    
    func toggleHabit(_ habit: Habit) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[index].isCompleted.toggle()
        }
    }
    
    func saveLog() {
        let log = DailyLog(
            date: Date(),
            mood: selectedMood,
            reflection: reflection,
            habits: habits
        )
        print("🔒 Log saved: \(log)")
        // Add SwiftData or local storage here later
    }
}
