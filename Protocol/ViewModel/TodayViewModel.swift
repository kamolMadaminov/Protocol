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
    var mood: String = "🔥"
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
    
    private func initializeHabitStatuses(using habitsToUse: [Habit]) { // <-- Renamed and takes parameter
        print("Initializing habit statuses for \(habitsToUse.count) habits.")
        // Create dictionary based on the names of the habits passed in
        self.habits = Dictionary(uniqueKeysWithValues: habitsToUse.map { ($0.name, false) })
    }
    
    func loadLog() {
        let specificDate = todayDate
        let descriptor = FetchDescriptor<DailyLog>(predicate: #Predicate { $0.date == specificDate })
        
        initializeHabitStatuses(using: self.currentHabits)
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
                
                var updatedHabits = self.habits
                
                for (loggedHabitName, loggedStatus) in result.habits {
                    if updatedHabits[loggedHabitName] != nil {
                        updatedHabits[loggedHabitName] = loggedStatus
                    } else {
                        print("- Skipping '\(loggedHabitName)' (no longer defined)")
                    }
                    
                }
                self.habits = updatedHabits
            } else {
                print("No existing log found for today.")
            }
        } catch {
            print("Error loading daily log: \(error)")
            initializeHabitStatuses(using: self.currentHabits)
            self.mood = "🔥"
            self.note = ""
            self.reflection = ""
            self.log = nil
        }
    }
    
    
    func saveLog() {
        let habitsToSave = self.habits.filter { habitName, _ in
            self.currentHabits.contains { $0.name == habitName }
        }
        
        if log == nil {
            print("- Creating new log entry.")
            log = DailyLog(date: todayDate, habits: habitsToSave, mood: mood, note: note, reflection: reflection)
            if let newLog = log {
                context.insert(newLog)
            }
        } else {
            print("- Updating existing log entry.")
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
            print("Attempting to delete log for date: \(specificDate)")
            try context.delete(model: DailyLog.self, where: #Predicate { $0.date == specificDate })
            try context.save() // Save deletion
            print("Successfully deleted log for today.")
            loadLog()
        } catch {
            print("Error deleting or saving after deleting today's log: \(error)")
            loadLog()
        }
    }
    
    func updateHabits(_ newHabits: [Habit]) {
        print("ViewModel updateHabits received \(newHabits.count) habits.")
        let oldHabitNames = Set(self.currentHabits.map { $0.name })
        let newHabitNames = Set(newHabits.map { $0.name })
        
        if oldHabitNames != newHabitNames {
            print("Habit list changed. Updating internal state.")
            self.currentHabits = newHabits
            loadLog()
        } else {
            print("Habit list unchanged, skipping state update.")
        }
    }
    
    // Helper to provide sorted habit names for the View
    var sortedHabits: [Habit] {
        
        currentHabits.sorted { $0.creationDate < $1.creationDate }
    }
}
