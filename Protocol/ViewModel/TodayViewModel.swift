//
//  TodayViewModel.swift
//  Protocol
//
//  Created by Kamol Madaminov on 11/04/25.
//

import Foundation
import SwiftData

@Observable
class TodayViewModel {
    var context: ModelContext
    var log: DailyLog?

    var habits: [String: Bool] = [:]
    var mood: String = ""
    var note: String = ""
    var reflection: String = ""

    private var todayDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }

    init(context: ModelContext) {
        self.context = context
        loadLog()
    }

    func loadLog() {
        let descriptor = FetchDescriptor<DailyLog>(predicate: #Predicate { $0.date == todayDate })

        if let result = try? context.fetch(descriptor).first {
            log = result
            habits = result.habits
            mood = result.mood
            note = result.note
            reflection = result.reflection
        } else {
            habits = [:]
            mood = ""
            note = ""
            reflection = ""
        }
    }

    func saveLog() {
        if log == nil {
            log = DailyLog(date: todayDate, habits: habits, mood: mood, note: note, reflection: reflection)
            context.insert(log!)
        } else {
            log?.habits = habits
            log?.mood = mood
            log?.note = note
            log?.reflection = reflection
        }

        try? context.save()
    }
}
