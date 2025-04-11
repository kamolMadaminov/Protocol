//
//  DailyLogModel.swift
//  Protocol
//
//  Created by Kamol Madaminov on 11/04/25.
//

import Foundation
import SwiftData

@Model
class DailyLog {
    @Attribute(.unique) var date: String
    var habits: [String: Bool]
    var mood: String
    var note: String
    var reflection: String

    init(date: String, habits: [String: Bool], mood: String, note: String, reflection: String) {
        self.date = date
        self.habits = habits
        self.mood = mood
        self.note = note
        self.reflection = reflection
    }
}
