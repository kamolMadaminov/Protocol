//
//  Habit.swift
//  Protocol
//
//  Created by Kamol Madaminov on 12/04/25.
//

import Foundation
import SwiftData

@Model
class Habit {
    var id: UUID
    @Attribute(.unique) var name: String
    var habitDescription: String?
    var creationDate: Date
    var reminderEnabled: Bool = false
    var reminderTime: Date?
    
    init(id: UUID = UUID(), name: String, creationDate: Date = Date(), habitDescription: String? = nil, reminderEnabled: Bool = false, reminderTime: Date? = nil) {
        self.id = id
        self.name = name
        self.creationDate = creationDate
        self.habitDescription = habitDescription
        self.reminderEnabled = reminderEnabled
        self.reminderTime = reminderTime
    }
}
