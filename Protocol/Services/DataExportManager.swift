//
//  DataExportManager.swift
//  Protocol
//
//  Created by Kamol Madaminov on 15/04/25.
//

import Foundation
import SwiftData

// --- DTOs for Codable Conformance ---
// Simple struct to hold log data for export
struct ExportableDailyLog: Codable {
    let date: String
    let habits: [String: Bool]
    let mood: String
    let note: String
    let reflection: String
}

// Simple struct to hold habit data for export (optional, but good context)
struct ExportableHabit: Codable {
    let name: String
    let habitDescription: String?
    let creationDate: Date // Use Date directly, let JSONEncoder handle formatting
}

// Top-level structure for the exported JSON file
struct ExportData: Codable {
    let exportDate: Date
    let habits: [ExportableHabit]
    let logs: [ExportableDailyLog]
}
// --- End DTOs ---


class DataExportManager {

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func exportToJSON() throws -> URL {
        // 1. Fetch Data
        let logDescriptor = FetchDescriptor<DailyLog>(sortBy: [SortDescriptor(\.date)])
        let habitDescriptor = FetchDescriptor<Habit>(sortBy: [SortDescriptor(\.creationDate)])

        let logs = try modelContext.fetch(logDescriptor)
        let habits = try modelContext.fetch(habitDescriptor)

        // 2. Convert to Exportable DTOs
        let exportableLogs = logs.map { log in
            ExportableDailyLog(
                date: log.date,
                habits: log.habits,
                mood: log.mood,
                note: log.note,
                reflection: log.reflection
            )
        }

        let exportableHabits = habits.map { habit in
            ExportableHabit(
                name: habit.name,
                habitDescription: habit.habitDescription,
                creationDate: habit.creationDate
            )
        }
        
        // 3. Create Top-Level Export Object
        let exportData = ExportData(
            exportDate: Date(),
            habits: exportableHabits,
            logs: exportableLogs
        )

        // 4. Encode to JSON
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys] // Make it readable
        encoder.dateEncodingStrategy = .iso8601 // Standard date format
        let jsonData = try encoder.encode(exportData)

        // 5. Get Temporary File URL
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = "protocol_export_\(Date().formatted(.iso8601.year().month().day())).json"
        let fileURL = tempDir.appendingPathComponent(fileName)

        // 6. Write JSON Data to File
        try jsonData.write(to: fileURL, options: .atomic)

        print("Export successful. File saved to: \(fileURL.path)")
        return fileURL
    }
}
