//
//  LogsView.swift
//  Protocol
//
//  Created by Kamol Madaminov on 12/04/25.
//

import SwiftUI
import SwiftData

struct LogsView: View {
    // Query for Habits (sorted by creation)
    @Query(sort: \Habit.creationDate) private var habits: [Habit]
    
    // Query for Logs (sorted reverse for list display)
    @Query(sort: [SortDescriptor<DailyLog>(\.date, order: .reverse)]) private var logs: [DailyLog]
    
    @Environment(\.modelContext) private var modelContext
    
    // State for the ViewModel
    @State private var viewModel = LogsViewModel()
    
    var body: some View {
        NavigationStack {
            List {
                // --- Trends Section ---
                Section("Habit Trends") {
                    if habits.isEmpty {
                        Text("No habits defined yet.")
                            .foregroundColor(.secondary)
                    } else if viewModel.trendData.isEmpty && !habits.isEmpty {
                        ProgressView()
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        // Iterate through the habits using the @Query result
                        ForEach(habits) { habit in
                            // Safely unwrap trend data for this habit's ID
                            if let trend = viewModel.trendData[habit.persistentModelID] {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(habit.name).font(.headline)
                                        // Display Description if you want it here too
                                        if let description = habit.habitDescription, !description.isEmpty {
                                            Text(description)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    Spacer()
                                    VStack(alignment: .trailing) {
                                        // Format percentage nicely
                                        Text("Weekly: \(trend.weeklyCompletionPercentage, specifier: "%.0f")%")
                                        Text("Streak: \(trend.currentStreak) \(trend.currentStreak == 1 ? "day" : "days")")
                                            .foregroundStyle(trend.currentStreak > 0 ? .orange : .secondary)
                                    }
                                    .font(.subheadline)
                                }
                                .padding(.vertical, 2)
                            } else {
                                HStack {
                                    Text(habit.name)
                                    Spacer()
                                    Text("Calculating...")
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                } // End Trends Section
                
                // --- Section for Past Log Entries ---
                Section("Past Log Entries") {
                    if logs.isEmpty {
                        Text("No logs recorded yet.")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        ForEach(logs) { log in
                            NavigationLink(destination: DetailedLogView(log: log)) {
                                HStack {
                                    // Display mood and formatted date
                                    Text("\(log.mood) \(formattedDate(log.date))")
                                        .font(.headline)
                                    
                                    Spacer()
                                    
                                    // Optionally show note/reflection snippet
                                    if !log.note.isEmpty {
                                        Text(log.note)
                                            .font(.caption)
                                            .lineLimit(1)
                                            .foregroundStyle(.secondary)
                                    } else if !log.reflection.isEmpty {
                                        Text(log.reflection)
                                            .font(.caption)
                                            .lineLimit(1)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .onDelete(perform: deleteLogs) // Keep swipe to delete
                    }
                }
            }
            .navigationTitle("Logs & Trends")
            .task(id: "\(habits.count)-\(logs.count)") {
                print("LogsView .task triggered.")
                viewModel.updateData(habits: habits, logs: logs)
            }
            .onAppear {
                print("LogsView appeared.")
                viewModel.updateData(habits: habits, logs: logs)
            }
        }
    }
    
    // Helper function to format the date string
    private func formattedDate(_ dateString: String) -> String {
        // ... (your existing implementation)
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        let outputFormatter = DateFormatter()
        outputFormatter.dateStyle = .medium
        outputFormatter.timeStyle = .none
        if let date = inputFormatter.date(from: dateString) {
            return outputFormatter.string(from: date)
        } else {
            return dateString
        }
    }
    
    // Function to handle deleting logs (Keep as is)
    private func deleteLogs(offsets: IndexSet) {
        withAnimation {
            offsets.map { logs[$0] }.forEach(modelContext.delete)
        }
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        // Include Habit in the container for preview
        let container = try ModelContainer(for: DailyLog.self, Habit.self, configurations: config)
        
        // Add Habits for Preview
        let habit1 = Habit(name: "Workout", creationDate: Calendar.current.date(byAdding: .day, value: -10, to: Date())!, habitDescription: "Morning strength training")
        let habit2 = Habit(name: "Read 30 Mins", creationDate: Calendar.current.date(byAdding: .day, value: -5, to: Date())!, habitDescription: "Read 'Atomic Habits'")
        let habit3 = Habit(name: "Meditate", creationDate: Calendar.current.date(byAdding: .day, value: -2, to: Date())!)
        container.mainContext.insert(habit1)
        container.mainContext.insert(habit2)
        container.mainContext.insert(habit3)
        
        // Use a helper to get date strings easily
        func dateString(daysAgo: Int) -> String {
            let date = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date())!
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter.string(from: date)
        }
        
        // Sample logs for the last week or so
        container.mainContext.insert(DailyLog(date: dateString(daysAgo: 0), habits: ["Workout": true, "Read 30 Mins": true, "Meditate": false], mood: "⚡️", note: "Good day", reflection: ""))
        container.mainContext.insert(DailyLog(date: dateString(daysAgo: 1), habits: ["Workout": true, "Read 30 Mins": false, "Meditate": true], mood: "🔥", note: "Tired", reflection: ""))
        container.mainContext.insert(DailyLog(date: dateString(daysAgo: 2), habits: ["Workout": true, "Read 30 Mins": true, "Meditate": true], mood: "🔥", note: "", reflection: ""))
        container.mainContext.insert(DailyLog(date: dateString(daysAgo: 3), habits: ["Workout": false, "Read 30 Mins": true], mood: "🌫️", note: "Missed workout", reflection: ""))
        container.mainContext.insert(DailyLog(date: dateString(daysAgo: 4), habits: ["Workout": true, "Read 30 Mins": true], mood: "⚡️", note: "", reflection: ""))
        container.mainContext.insert(DailyLog(date: dateString(daysAgo: 5), habits: ["Workout": true, "Read 30 Mins": false], mood: "🔥", note: "Busy", reflection: ""))
        container.mainContext.insert(DailyLog(date: dateString(daysAgo: 6), habits: ["Workout": true], mood: "⚡️", note: "", reflection: ""))
        container.mainContext.insert(DailyLog(date: dateString(daysAgo: 7), habits: ["Workout": false], mood: "🌫️", note: "", reflection: ""))
        container.mainContext.insert(DailyLog(date: dateString(daysAgo: 8), habits: ["Workout": true], mood: "🔥", note: "", reflection: ""))
        
        return LogsView()
            .modelContainer(container)
    } catch {
        fatalError("Failed to create model container for preview: \(error)")
    }
}
