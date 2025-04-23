//
//  LogsViewModel.swift
//  Protocol
//
//  Created by Kamol Madaminov on 14/04/25.
//

import Foundation
import SwiftData
import SwiftUI

// Structure to hold aggregated mood data for the chart
struct MoodFrequency: Identifiable {
    let id = UUID()
    let mood: String
    var count: Int
}

// Structure to hold calculated trend data for a single habit
struct HabitTrendData {
    var weeklyCompletionPercentage: Double = 0.0
    var currentStreak: Int = 0
    var longestStreak: Int = 0
}

struct DailyCompletionStat: Identifiable {
    let id = UUID()
    let date: Date
    let completionPercentage: Double
}

@Observable
class LogsViewModel {
    // Store calculated data: Key is Habit's PersistentIdentifier for stability
    var trendData: [PersistentIdentifier: HabitTrendData] = [:]
    var moodChartData: [MoodFrequency] = []
    var weeklyCompletionGraphData: [DailyCompletionStat] = []
    
    // Overall consistency and streaks
    var overallConsistencyScore: Double = 0.0
    var overallLongestStreak: Int = 0
    
    // Store processed logs for easier lookup (Date: Log)
    private var logDict: [Date: DailyLog] = [:]
    private var allHabits: [Habit] = []
    private var allLogsSorted: [DailyLog] = []
    
    // Date Formatter for consistency (matching DailyLog.date format)
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current // Use current time zone
        formatter.locale = Locale.current   // Use current locale
        return formatter
    }()
    
    // Calendar for date calculations
    private let calendar = Calendar.current
    
    init() {}
    
    // Main function called by the View when data is available/updated
    func updateData(habits: [Habit], logs: [DailyLog]) {
        self.allHabits = habits
        self.allLogsSorted = logs.sorted { log1, log2 in
            guard let date1 = dateFormatter.date(from: log1.date),
                  let date2 = dateFormatter.date(from: log2.date) else {
                return false
            }
            return date1 < date2
        }
        
        // Create a dictionary for faster lookups during streak calculation
        self.logDict = Dictionary(uniqueKeysWithValues: self.allLogsSorted.compactMap { log in
            guard let date = dateFormatter.date(from: log.date) else { return nil }
            let startOfDay = calendar.startOfDay(for: date)
            return (startOfDay, log)
        })
        
        // Recalculate all trends
        calculateAllMetrics()
        
        // Calculate Mood Chart Data for the last 7 days
        calculateMoodChartData(forPastDays: 7)
        
        // Draw Weekly Completion graph for the last 7 days
        calculateWeeklyCompletionGraphData(forPastDays: 7)
    }
    
    private func calculateAllMetrics() {
        var newTrendData: [PersistentIdentifier: HabitTrendData] = [:]
        let today = calendar.startOfDay(for: Date()) // Use start of today
        var totalWeeklyCompletionSum: Double = 0.0
        var longestStreakAcrossHabits = 0
        
        for habit in allHabits {
            let weeklyPercentage = calculateWeeklyCompletion(for: habit, today: today)
            let streak = calculateCurrentStreak(for: habit, today: today)
            let longest = calculateLongestStreak(for: habit) // Calculate longest streak
            
            newTrendData[habit.persistentModelID] = HabitTrendData(
                weeklyCompletionPercentage: weeklyPercentage,
                currentStreak: streak,
                longestStreak: longest // Store longest streak
            )
            totalWeeklyCompletionSum += weeklyPercentage
            if longest > longestStreakAcrossHabits {
                longestStreakAcrossHabits = longest
            }
        }
        
        // Update the published properties
        self.trendData = newTrendData
        self.overallLongestStreak = longestStreakAcrossHabits
        
        // Calculate overall consistency score (simple average for now)
        if !allHabits.isEmpty {
            self.overallConsistencyScore = totalWeeklyCompletionSum / Double(allHabits.count)
        } else {
            self.overallConsistencyScore = 0.0
        }
        
        print("Trends calculated: \(self.trendData)")
        print("Overall Consistency Score: \(self.overallConsistencyScore)")
        print("Overall Longest Streak: \(self.overallLongestStreak)")
    }
    
    // --- Weekly Completion Calculation ---
    private func calculateWeeklyCompletion(for habit: Habit, today: Date) -> Double {
        guard let sevenDaysAgo = calendar.date(byAdding: .day, value: -6, to: today) else { return 0.0 } // Start of day, 6 days before today = 7 day period
        
        let habitCreationDate = calendar.startOfDay(for: habit.creationDate)
        
        // Determine the relevant start date for calculation (max of 7 days ago and creation date)
        let startDate = max(sevenDaysAgo, habitCreationDate)
        
        var possibleDays = 0
        var completedDays = 0
        
        // Iterate through the last 7 days (or fewer if habit is newer)
        for dayOffset in 0..<7 {
            guard let currentDate = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }
            
            // Only count days from the effective start date onwards
            if currentDate >= startDate {
                possibleDays += 1
                
                // Check if log exists for this date and habit is marked true
                if let log = logDict[currentDate], log.habits[habit.name] == true {
                    completedDays += 1
                }
            }
        }
        
        guard possibleDays > 0 else { return 0.0 }
        
        let percentage = (Double(completedDays) / Double(possibleDays)) * 100.0
        print("- Habit '\(habit.name)': Completed \(completedDays)/\(possibleDays) days in window. (\(percentage)%)")
        return percentage
    }
    
    // --- Streak Calculation ---
    private func calculateCurrentStreak(for habit: Habit, today: Date) -> Int {
        var currentStreak = 0
        let habitCreationDate = calendar.startOfDay(for: habit.creationDate)
        
        // Iterate backwards from today
        for dayOffset in 0... { // Potentially infinite loop, but break conditions handle it
            guard let currentDate = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { break }
            
            // Stop if we go before the habit was created
            if currentDate < habitCreationDate {
                break
            }
            
            // Check log for this date
            if let log = logDict[currentDate], log.habits[habit.name] == true {
                // Day completed, continue streak
                currentStreak += 1
            } else {
                break
            }
        }
        print("- Habit '\(habit.name)': Current Streak = \(currentStreak)")
        return currentStreak
    }
    
    // --- Longest Streak Calculation ---
    private func calculateLongestStreak(for habit: Habit) -> Int {
        var longestStreak = 0
        var currentStreak = 0
        let habitCreationDate = calendar.startOfDay(for: habit.creationDate)
        
        // Iterate through all sorted logs relevant to this habit's creation date
        let relevantLogs = allLogsSorted.filter { log in
            guard let logDate = dateFormatter.date(from: log.date) else { return false }
            return calendar.startOfDay(for: logDate) >= habitCreationDate
        }
        
        var previousDate: Date? = nil
        
        for log in relevantLogs {
            guard let logDate = dateFormatter.date(from: log.date) else { continue }
            let currentDate = calendar.startOfDay(for: logDate)
            
            // Check for missed days between logs
            if let prevDate = previousDate {
                let daysBetween = calendar.dateComponents([.day], from: prevDate, to: currentDate).day ?? 0
                if daysBetween > 1 {
                    // Gap detected, reset current streak
                    longestStreak = max(longestStreak, currentStreak)
                    currentStreak = 0 // Reset streak
                }
            }
            
            
            if log.habits[habit.name] == true {
                currentStreak += 1
            } else {
                // Day logged but habit not completed
                longestStreak = max(longestStreak, currentStreak)
                currentStreak = 0 // Reset streak
            }
            previousDate = currentDate // Update previous date
        }
        
        longestStreak = max(longestStreak, currentStreak)
        
        return longestStreak
    }
    
    private func calculateMoodChartData(forPastDays days: Int) {
        let today = calendar.startOfDay(for: Date())
        guard let startDate = calendar.date(byAdding: .day, value: -(days - 1), to: today) else {
            self.moodChartData = []
            return
        }
        
        print("Calculating mood chart data from \(startDate) to \(today)")
        
        // Filter logs within the date range
        let recentLogs = allLogsSorted.filter { log in
            guard let logDate = dateFormatter.date(from: log.date) else { return false }
            let logStartOfDay = calendar.startOfDay(for: logDate)
            return logStartOfDay >= startDate && logStartOfDay <= today
        }
        
        // Tally mood counts
        var moodCounts: [String: Int] = [:]
        for log in recentLogs {
            moodCounts[log.mood, default: 0] += 1
        }
        
        print("- Mood counts for last \(days) days: \(moodCounts)")
        
        // Sorting by mood emoji string provides a basic consistent order
        self.moodChartData = moodCounts.map { mood, count in
            MoodFrequency(mood: mood, count: count)
        }.sorted { $0.mood < $1.mood }
        
        print("- Mood chart data prepared: \(self.moodChartData)")
    }
    
    
    // calculateWeeklyCompletionGraphData graph drawing function
    private func calculateWeeklyCompletionGraphData(forPastDays days: Int) {
        var graphData: [DailyCompletionStat] = []
        let today = calendar.startOfDay(for: Date())
        
        print("--- Calculating Weekly Completion Graph (for \(days) days ending \(today)) ---")
        
        for dayOffset in (0..<days).reversed() {
            guard let currentDate = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }
            
            let activeHabits = allHabits.filter { habit in
                let habitStartOfDay = calendar.startOfDay(for: habit.creationDate)
                return habitStartOfDay <= currentDate
            }
            
            guard !activeHabits.isEmpty else {
                print("  No active habits on this date. Appending 0%.")
                graphData.append(DailyCompletionStat(date: currentDate, completionPercentage: 0))
                continue
            }
            
            var completedCount = 0
            let log = logDict[currentDate]
            
            if let log = log {
                print("  Log found for this date. Mood: \(log.mood)")
            }
            
            for habit in activeHabits {
                if log?.habits[habit.name] == true {
                    completedCount += 1
                }
            }
            
            let completionPercentage = (Double(completedCount) / Double(activeHabits.count)) * 100.0
            print("  Calculation: \(completedCount) completed / \(activeHabits.count) active = \(completionPercentage)%")
            graphData.append(DailyCompletionStat(date: currentDate, completionPercentage: completionPercentage))
            
        }
        self.weeklyCompletionGraphData = graphData
    }
}
