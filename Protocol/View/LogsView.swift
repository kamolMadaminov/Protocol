//
//  LogsView.swift
//  Protocol
//
//  Created by Kamol Madaminov on 12/04/25.
//

import SwiftUI
import SwiftData

struct LogsView: View {
    @Query(sort: [SortDescriptor<DailyLog>(\.date, order: .reverse)]) private var logs: [DailyLog]

    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            List {
                if logs.isEmpty {
                    ContentUnavailableView(
                        "No Logs Yet",
                        systemImage: "doc.text.magnifyingglass",
                        description: Text("Start logging your daily protocols, and they will appear here.")
                    )
                } else {
                    ForEach(logs) { log in
                        NavigationLink(destination: DetailedLogView(log: log)) {
                            VStack(alignment: .leading) {
                                HStack {
                                    VStack{
                                        Text(formattedDate(log.date))
                                            .font(.headline)
                                        
                                        if !log.note.isEmpty {
                                            Text("Note: \(log.note)")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                                .lineLimit(1)
                                        } else if !log.reflection.isEmpty {
                                             Text("Reflection: \(log.reflection)")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                                .lineLimit(1)
                                        }
                                    }
                                    Spacer()
                                    Text(log.mood)
                                        .font(.title2)
                                }

                            }
                        }
                    }
                    .onDelete(perform: deleteLogs)
                }
            }
            .navigationTitle("Past Logs")
        }
    }

    // Helper function to format the date string for the list view
    private func formattedDate(_ dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd" // Current format

        let outputFormatter = DateFormatter()
        outputFormatter.dateStyle = .medium
        outputFormatter.timeStyle = .none

        if let date = inputFormatter.date(from: dateString) {
            return outputFormatter.string(from: date)
        } else {
            return dateString
        }
    }

    // Function to handle deleting logs from the list
    private func deleteLogs(offsets: IndexSet) {
        withAnimation {
            offsets.map { logs[$0] }.forEach(modelContext.delete)
        }
    }
}

#Preview {
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
