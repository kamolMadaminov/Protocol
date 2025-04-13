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
                            HStack {
                                Text("\(log.mood) \(formattedDate(log.date))")
                                    .font(.headline)
                                    .lineLimit(1)
                                Spacer()
                                if !log.note.isEmpty || !log.reflection.isEmpty {
                                    VStack(alignment: .trailing) {
                                        if !log.note.isEmpty {
                                            Text(log.note) 
                                        } else {
                                            Text(log.reflection)
                                        }
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("Past Logs")
        }
    }

    // Helper function to format the date string
    private func formattedDate(_ dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        let outputFormatter = DateFormatter()
        outputFormatter.dateStyle = .medium // "Apr 13, 2025" - good for list
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
