//
//  TodayViewModel.swift
//  Protocol
//
//  Created by Kamol Madaminov on 11/04/25.
//

// TodayViewModel.swift

import Foundation
import SwiftData
import SwiftUI

@Observable
class TodayViewModel {
    var context: ModelContext
    var log: DailyLog?
    
    var habits: [String: Bool] = [:]
    var mood: String = "🙂"
    var note: String = ""
    var reflection: String = ""
    
    private var currentHabits: [Habit] = []
    
    private var todayDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
    
    init(context: ModelContext, initialHabits: [Habit] = []) {
        self.context = context
        self.currentHabits = initialHabits
        initializeHabitStatuses(using: self.currentHabits)
        loadLog()
        
    }
    
    private func initializeHabitStatuses(using habitsToUse: [Habit]) {
        self.habits = Dictionary(uniqueKeysWithValues: habitsToUse.map { ($0.name, false) })
    }
    
    func loadLog() {
        let specificDate = todayDate
        let descriptor = FetchDescriptor<DailyLog>(predicate: #Predicate { $0.date == specificDate })
        
        // Reset state before loading or if no log exists
        initializeHabitStatuses(using: self.currentHabits) // Use the current list
        self.mood = "🙂"
        self.note = ""
        self.reflection = ""
        self.log = nil
        
        do {
            if let result = try context.fetch(descriptor).first {
                self.log = result
                self.mood = result.mood
                self.note = result.note
                self.reflection = result.reflection
                
                var updatedHabits = self.habits // Start with current defaults (all false)

                // Merge saved statuses, ignoring habits that no longer exist
                for (loggedHabitName, loggedStatus) in result.habits {
                    if updatedHabits[loggedHabitName] != nil {
                         updatedHabits[loggedHabitName] = loggedStatus
                    }
                }
                 self.habits = updatedHabits // Apply the merged statuses
            }
        } catch {
            print("Error loading daily log: \(error)")
             // Ensure clean state on error
             initializeHabitStatuses(using: self.currentHabits)
             self.mood = "🙂"
             self.note = ""
             self.reflection = ""
             self.log = nil
        }
    }
    
    
    func saveLog() {
         // Filter habits to save only those currently defined in currentHabits
         let habitsToSave = self.habits.filter { habitName, _ in
             self.currentHabits.contains { $0.name == habitName }
         }

        if log == nil {
            log = DailyLog(date: todayDate, habits: habitsToSave, mood: mood, note: note, reflection: reflection)
            if let newLog = log {
                context.insert(newLog)
            }
        } else {
            log?.habits = habitsToSave
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
    
    func deleteTodaysLog() {
        let specificDate = todayDate
        do {
            try context.delete(model: DailyLog.self, where: #Predicate { $0.date == specificDate })
            try context.save() // Save deletion
            loadLog() // Reload to reset the view model state
        } catch {
            print("Error deleting or saving after deleting today's log: \(error)")
            loadLog() // Still try to reload state
        }
    }
    
    func updateHabits(_ newHabits: [Habit]) {
        let oldHabitNames = Set(self.currentHabits.map { $0.name })
        let newHabitNames = Set(newHabits.map { $0.name })
        
        if oldHabitNames != newHabitNames {
            self.currentHabits = newHabits
            loadLog() // Reload log to incorporate new habit structure
        }
    }
    
    // Helper to provide sorted habit names for the View
    var sortedHabits: [Habit] {
        currentHabits.sorted { $0.creationDate < $1.creationDate }
    }
    
    func moodDescription(for emoji: String) -> String {
        switch emoji {
        case "🥀": return "Barely made it"
        case "😮‍💨": return "Pushed through"
        case "🙂": return "Neutral"
        case "💪": return "Felt strong"
        case "🚀": return "On fire"
        default: return ""
        }
    }
}
