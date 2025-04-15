//
//  DataRetentionManager.swift
//  Protocol
//
//  Created by Kamol Madaminov on 15/04/25.
//

import Foundation
import SwiftData

// Enum to represent retention periods, matching UserDefaults keys
enum DataRetentionPeriod: String, CaseIterable, Identifiable {
    case indefinite = "Indefinite"
    case threeMonths = "3 Months"
    case sixMonths = "6 Months"
    case twelveMonths = "12 Months"

    var id: String { self.rawValue }

    // Calculate the cutoff date based on the selected period
    func cutoffDate(from referenceDate: Date = Date(), calendar: Calendar = .current) -> Date? {
        let startDate = calendar.startOfDay(for: referenceDate)
        switch self {
        case .indefinite:
            return nil // No cutoff
        case .threeMonths:
            return calendar.date(byAdding: .month, value: -3, to: startDate)
        case .sixMonths:
            return calendar.date(byAdding: .month, value: -6, to: startDate)
        case .twelveMonths:
            return calendar.date(byAdding: .month, value: -12, to: startDate)
        }
    }
}

@MainActor
class DataRetentionManager {

    // Static function to perform cleanup, using the main container
    static func performCleanup(container: ModelContainer) {
        // 1. Get the saved setting (using UserDefaults directly)
        let savedPeriodRawValue = UserDefaults.standard.string(forKey: "dataRetentionPeriod") ?? DataRetentionPeriod.indefinite.rawValue
        guard let retentionPeriod = DataRetentionPeriod(rawValue: savedPeriodRawValue),
              retentionPeriod != .indefinite else {
            print("Data Retention: Policy is Indefinite. No cleanup needed.")
            return
        }

        // 2. Calculate the cutoff date
        guard let cutoffDate = retentionPeriod.cutoffDate() else {
            print("Data Retention: Could not calculate cutoff date.")
            return
        }

        // 3. Format cutoff date for comparison with stored string dates
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone.current // Match storage format's implied timezone
        let cutoffDateString = dateFormatter.string(from: cutoffDate)

        print("Data Retention: Deleting logs before \(cutoffDateString)...")

        // 4. Perform deletion using a background context derived from the container
        Task.detached {
            do {
                // Create a new context for this background task
                let context = ModelContext(container)
                
                // Define the predicate for deletion
                let predicate = #Predicate<DailyLog> { log in
                    log.date < cutoffDateString // Simple string comparison works for "yyyy-MM-dd"
                }

                // Perform the deletion
                try context.delete(model: DailyLog.self, where: predicate)

                // Save the changes on the background context
                try context.save()

                // Use await MainActor.run for UI updates or main-thread prints if needed *after* save
                 await MainActor.run {
                     print("Data Retention: Cleanup completed successfully.")
                 }

            } catch {
                 await MainActor.run { // Switch back to main actor for printing errors related to the task
                     print("Data Retention: Error performing cleanup: \(error)")
                 }
            }
        }
    }
}
