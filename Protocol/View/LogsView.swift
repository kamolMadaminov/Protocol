//
//  LogsView.swift
//  Protocol
//
//  Created by Kamol Madaminov on 12/04/25.
//

import SwiftUI
import SwiftData

struct LogsView: View {
    // Query fetching all DailyLog entries, sorted by date descending
    @Query(sort: [SortDescriptor<DailyLog>(\.date, order: .reverse)]) private var logs: [DailyLog]

    @Environment(\.modelContext) private var modelContext

    var body: some View {
        // Using NavigationStack for potential future navigation to detail views
        NavigationStack {
            List {
                // Check if logs are empty
                if logs.isEmpty {
                    ContentUnavailableView(
                        "No Logs Yet",
                        systemImage: "doc.text.magnifyingglass",
                        description: Text("Start logging your daily protocols, and they will appear here.")
                    )
                } else {
                    // Iterate over the fetched and sorted logs
                    ForEach(logs) { log in
                        VStack(alignment: .leading) {
                            HStack {
                                Text(formattedDate(log.date)) // Display formatted date
                                    .font(.headline)
                                Spacer()
                                Text(log.mood) // Display mood emoji
                                    .font(.title2)
                            }
                            // Optionally display a snippet of the note or reflection
                            if !log.note.isEmpty {
                                Text("Note: \(log.note)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .lineLimit(1) // Limit to one line
                            } else if !log.reflection.isEmpty {
                                 Text("Reflection: \(log.reflection)")
                                     .font(.caption)
                                     .foregroundColor(.gray)
                                     .lineLimit(1)
                            }
                        }
                        // Add padding within the list row if desired
                        // .padding(.vertical, 4)
                    }
                    // Optional: Add delete functionality
                    .onDelete(perform: deleteLogs)
                }
            }
            .navigationTitle("Past Logs")
            // Optional: Add an EditButton if using onDelete
            // .toolbar {
            //     if !logs.isEmpty {
            //         EditButton()
            //     }
            // }
        }
    }

    // Helper function to format the date string if needed
    private func formattedDate(_ dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd" // Current format

        let outputFormatter = DateFormatter()
        outputFormatter.dateStyle = .medium // e.g., "Apr 12, 2025"
        outputFormatter.timeStyle = .none

        if let date = inputFormatter.date(from: dateString) {
            return outputFormatter.string(from: date)
        } else {
            return dateString // Fallback to original string if formatting fails
        }
    }

    // Function to handle deleting logs from the list
    private func deleteLogs(offsets: IndexSet) {
        withAnimation {
            offsets.map { logs[$0] }.forEach(modelContext.delete)
            // Optional: Save context explicitly if needed, often handled automatically
            // try? modelContext.save()
        }
    }
}

#Preview {
    // Provide a sample ModelContainer for the preview
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: DailyLog.self, configurations: config)

        // Add sample data for previewing
        let sampleLog1 = DailyLog(date: "2025-04-11", habits: ["Workout": true], mood: "⚡️", note: "Good session", reflection: "Felt strong")
        let sampleLog2 = DailyLog(date: "2025-04-10", habits: ["Read": true], mood: "🔥", note: "", reflection: "Finished chapter")
        let sampleLog3 = DailyLog(date: "2025-04-12", habits: ["Meditate": true], mood: "🌫️", note: "Cloudy day", reflection: "Need more focus")
        container.mainContext.insert(sampleLog1)
        container.mainContext.insert(sampleLog2)
        container.mainContext.insert(sampleLog3)


        return LogsView()
            .modelContainer(container)
    } catch {
        fatalError("Failed to create model container for preview: \(error)")
    }
}
