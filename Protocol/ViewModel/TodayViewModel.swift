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
    private var definedHabits: [Habit] = []

    var habits: [String: Bool] = [:]
    var mood: String = "🔥"
    var note: String = ""
    var reflection: String = ""

    private var todayDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }

    init(context: ModelContext) {
            self.context = context
            fetchDefinedHabits()
            loadLog()
        
        }

    func fetchDefinedHabits() {
        let sortDescriptor = SortDescriptor<Habit>(\.creationDate)
        let fetchDescriptor = FetchDescriptor<Habit>(sortBy: [sortDescriptor])
        do {
            self.definedHabits = try context.fetch(fetchDescriptor)
        } catch {
            print("Error fetching defined habits: \(error)")
            self.definedHabits = [] // Reset on error
        }
    }

    func initializeHabitStatuses() {
        self.habits = Dictionary(uniqueKeysWithValues: definedHabits.map { ($0.name, false) })
    }

    func loadLog() {
        let specificDate = todayDate
        let descriptor = FetchDescriptor<DailyLog>(predicate: #Predicate { $0.date == specificDate })

        initializeHabitStatuses()
        self.mood = "🔥"
        self.note = ""
        self.reflection = ""
        self.log = nil

        do {
            if let result = try context.fetch(descriptor).first {
                self.log = result
                self.mood = result.mood
                self.note = result.note
                self.reflection = result.reflection

                
                for (loggedHabitName, loggedStatus) in result.habits {
                    if self.habits[loggedHabitName] != nil {
                        self.habits[loggedHabitName] = loggedStatus
                    }

                }
            }
        } catch {
            print("Error loading daily log: \(error)")
            initializeHabitStatuses()
            self.mood = "🔥"
            self.note = ""
            self.reflection = ""
            self.log = nil
        }
    }


    func saveLog() {
         let habitsToSave = self.habits.filter { habitName, _ in
             definedHabits.contains { $0.name == habitName }
         }

        if log == nil {
            // Create and insert a new log
            log = DailyLog(date: todayDate, habits: habitsToSave, mood: mood, note: note, reflection: reflection)
            if let newLog = log {
                context.insert(newLog)
            }
        } else {
            // Update the existing log object
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
        let descriptor = FetchDescriptor<DailyLog>(predicate: #Predicate { $0.date == specificDate })

        do {
            if let logToDelete = try context.fetch(descriptor).first {
                print("Deleting log for date: \(logToDelete.date)")
                context.delete(logToDelete)
                try context.save()
                print("Successfully deleted log for today.")
                // Reload to reset the state variables (mood, habits, note, reflection, log property)
                loadLog()
            } else {
                 print("No log found for today (\(specificDate)) to delete.")
            }
        } catch {
            print("Error deleting or saving after deleting today's log: \(error)")
        }
    }

    // Helper to provide sorted habit names for the View
    var sortedHabitNames: [String] {
        definedHabits.map { $0.name }
    }
}
