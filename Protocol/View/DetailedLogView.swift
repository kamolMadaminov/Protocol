//
//  DetailedLogView.swift
//  Protocol
//
//  Created by Kamol Madaminov on 13/04/25.
//

import SwiftUI
import SwiftData

struct DetailedLogView: View {
    let log: DailyLog

    var body: some View {
        ScrollView { 
            VStack(alignment: .leading, spacing: 20) {
                // Display Date prominently
                Text(formattedDate(log.date))
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom)

                // Mood Section
                HStack {
                    Text("Mood:")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Spacer()
                    Text(log.mood)
                        .font(.system(size: 40)) // Larger emoji
                }

                // Habits Section
                VStack(alignment: .leading) {
                    Text("Habits:")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.bottom, 5)

                    if log.habits.isEmpty {
                        Text("No habits logged for this day.")
                            .foregroundColor(.gray)
                    } else {
                        // Sort habits alphabetically for consistent order
                        ForEach(log.habits.sorted(by: { $0.key < $1.key }), id: \.key) { habitName, completed in
                            HStack {
                                Text(habitName)
                                Spacer()
                                Image(systemName: completed ? "checkmark.circle.fill" : "xmark.circle")
                                    .foregroundColor(completed ? .green : .red)
                            }
                            .padding(.vertical, 2)
                        }
                    }
                }

                // Note Section (Only if not empty)
                if !log.note.isEmpty {
                    VStack(alignment: .leading) {
                        Text("Note:")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Text(log.note)
                            .font(.body)
                    }
                }

                // Reflection Section (Only if not empty)
                if !log.reflection.isEmpty {
                    VStack(alignment: .leading) {
                        Text("Reflection:")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Text(log.reflection)
                            .font(.body)
                            .multilineTextAlignment(.leading)
                    }
                }

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Log Details")
        .navigationBarTitleDisplayMode(.inline)
    }

    // Helper function to format the date string (same as in LogsView)
    private func formattedDate(_ dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd" // Current format

        let outputFormatter = DateFormatter()
        outputFormatter.dateStyle = .full
        outputFormatter.timeStyle = .none

        if let date = inputFormatter.date(from: dateString) {
            return outputFormatter.string(from: date)
        } else {
            return dateString
        }
    }
}

// Add a PreviewProvider for DetailedLogView
#Preview {
    // Create a sample log for the preview
    let sampleLog = DailyLog(
        date: "2025-04-12",
        habits: ["Workout": true, "Read": true, "Meditate": false],
        mood: "⚡️",
        note: "A productive day overall.",
        reflection: "Felt aligned with my goals, although meditation was skipped."
    )

    // Embed in NavigationStack for the preview to show the title correctly
    return NavigationStack {
         DetailedLogView(log: sampleLog)
    }
}
