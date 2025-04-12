//
//  TodayViewModel.swift
//  Protocol
//
//  Created by Kamol Madaminov on 11/04/25.
//

import Foundation
import SwiftData

@Observable
class TodayViewModel {
    var context: ModelContext
    var log: DailyLog?

    var habits: [String: Bool] = [:]
    var mood: String = ""
    var note: String = ""
    var reflection: String = ""

    private var todayDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }

    init(context: ModelContext) {
        self.context = context
        loadLog()
    }

    func loadLog() {
        let specificDate = todayDate
        let descriptor = FetchDescriptor<DailyLog>(predicate: #Predicate { $0.date == specificDate })

        do {
            if let result = try context.fetch(descriptor).first {
                log = result
                habits = result.habits
                mood = result.mood
                note = result.note
                reflection = result.reflection
            } else {
                log = nil
                habits = [:]
                mood = "🔥" 
                note = ""
                reflection = ""
            }
        } catch {
            print("Error loading daily log: \(error)")
            log = nil
            habits = [:]
            mood = "🔥"
            note = ""
            reflection = ""
        }
    }


    func saveLog() {
        if log == nil {
            log = DailyLog(date: todayDate, habits: habits, mood: mood, note: note, reflection: reflection)
            if let newLog = log { // Safely unwrap
                 context.insert(newLog)
            }
        } else {
            // Update the existing log object
            log?.habits = habits
            log?.mood = mood
            log?.note = note
            log?.reflection = reflection
        }

        do {
            try context.save()
        } catch {
             print("Error saving daily log: \(error)")
        }
    }
}
