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
    @Attribute(.unique) var name: String
    var habitDescription: String?
    var creationDate: Date
    init(name: String, creationDate: Date = Date(), habitDescription: String? = nil) {
        self.name = name
        self.creationDate = creationDate
        self.habitDescription = habitDescription
    }
}
