////
////  AddEditHabitViewModel.swift
////  Protocol
////
////  Created by Kamol Madaminov on 23/04/25.
////
//
//import SwiftUI
//import SwiftData
//import UserNotifications // Import for UNAuthorizationStatus
//
//@Observable
//class AddEditHabitViewModel {
//
//    // --- Dependencies ---
//    private var modelContext: ModelContext
//    private let notificationManager = NotificationManager.shared // Access Singleton
//
//    // --- State Properties ---
//    var habitName: String = ""
//    var habitDescription: String = ""
//    var reminderEnabled: Bool = false
//    var reminderTime: Date = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date())! // Default time if none exists
//
//    // --- Editing Context ---
//    private var habitToEdit: Habit? // Keep track if editing
//    var isEditing: Bool { habitToEdit != nil }
//    var navigationTitle: String { isEditing ? "Edit Habit" : "Add Habit" }
//
//    // --- UI Control State ---
//    var showingDeleteConfirm: Bool = false
//    var showingErrorAlert: Bool = false
//    var errorMessage: String = ""
//    var canSave: Bool { !habitName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
//
//    // Haptic Triggers (Can be observed by the view)
//    var triggerSaveHaptic: Int = 0 // Use simple increments to trigger
//    var triggerDeleteHaptic: Int = 0
//
//    // --- Initialization ---
//    init(modelContext: ModelContext, habitToEdit: Habit? = nil) {
//        self.modelContext = modelContext
//        self.habitToEdit = habitToEdit
//
//        // Populate state if editing
//        if let habit = habitToEdit {
//            self.habitName = habit.name
//            self.habitDescription = habit.habitDescription ?? ""
//            self.reminderEnabled = habit.reminderEnabled
//            // Use existing reminder time or default if nil but enabled (shouldn't happen ideally)
//            self.reminderTime = habit.reminderTime ?? Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date())!
//        }
//    }
//
//    // MARK: - Actions
//
//    func saveHabit(completion: @escaping (Bool) -> Void) {
//        guard canSave else {
//            showError("Habit name cannot be empty.")
//            completion(false)
//            return
//        }
//
//        // --- Permission Check (if reminder enabled) ---
//        if reminderEnabled {
//            notificationManager.checkAuthorizationStatus { [weak self] status in
//                 guard let self = self else { return }
//                 if status == .authorized || status == .provisional {
//                    self.proceedWithSave(completion: completion)
//                 } else if status == .notDetermined {
//                    self.notificationManager.requestPermission { granted in
//                         if granted {
//                             self.proceedWithSave(completion: completion)
//                         } else {
//                             self.showError("Notifications permission is required to enable reminders. You can enable it in the Settings app.")
//                             // Optionally turn the toggle back off
//                             self.reminderEnabled = false
//                             completion(false)
//                         }
//                    }
//                 } else { // Denied or restricted
//                     self.showError("Notifications are disabled. Please enable them in the Settings app to use reminders.")
//                     // Optionally turn the toggle back off
//                     self.reminderEnabled = false
//                     completion(false)
//                 }
//            }
//        } else {
//             // If reminder is not enabled, just save without permission check
//             proceedWithSave(completion: completion)
//        }
//    }
//
//    private func proceedWithSave(completion: @escaping (Bool) -> Void) {
//         let nameToSave = habitName
//         let descriptionToSave = habitDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : habitDescription.trimmingCharacters(in: .whitespacesAndNewlines)
//         let finalReminderTime = reminderEnabled ? reminderTime : nil // Set time to nil if reminder is off
//
//         do {
//             let habit: Habit
//             if let existingHabit = habitToEdit {
//                 // Editing existing habit
//                 existingHabit.name = nameToSave
//                 existingHabit.habitDescription = descriptionToSave
//                 existingHabit.reminderEnabled = reminderEnabled
//                 existingHabit.reminderTime = finalReminderTime
//                 habit = existingHabit // Use existing habit for notification logic
//                 print("Updating habit ID: \(habit.persistentModelID)")
//             } else {
//                 // Adding new habit
//                 let newHabit = Habit(
//                     name: nameToSave,
//                     creationDate: Date(),
//                     habitDescription: descriptionToSave,
//                     reminderEnabled: reminderEnabled,
//                     reminderTime: finalReminderTime
//                 )
//                 modelContext.insert(newHabit)
//                 habit = newHabit // Use new habit for notification logic
//                 print("Inserting new habit")
//             }
//
//             try modelContext.save()
//             print("Save successful")
//
//             // --- Handle Notification Scheduling ---
//             if habit.reminderEnabled, let time = habit.reminderTime {
//                 notificationManager.scheduleHabitReminder(habitId: habit.id.uuidString, habitName: habit.name, time: time)
//             } else {
//                 // If reminder is disabled or time is nil (shouldn't happen if enabled), cancel any existing one
//                 notificationManager.cancelHabitReminder(habitId: habit.id.uuidString)
//             }
//
//             triggerSaveHaptic += 1 // Trigger haptic feedback
//             completion(true) // Signal success to the view (for dismissal)
//
//         } catch {
//             print("Error saving habit: \(error)")
//             showError("Failed to save habit. Please try again.\n(\(error.localizedDescription))")
//             completion(false) // Signal failure
//         }
//    }
//
//    func deleteHabit(completion: @escaping (Bool) -> Void) {
//        guard let habit = habitToEdit else {
//             completion(false)
//             return
//        }
//
//        let habitIdString = habit.id.uuidString // Capture ID before deletion
//
//        do {
//             print("Deleting habit ID: \(habit.persistentModelID)")
//             // --- Cancel Notification First ---
//             notificationManager.cancelHabitReminder(habitId: habitIdString)
//
//             modelContext.delete(habit)
//             try modelContext.save()
//             print("Delete successful")
//
//             triggerDeleteHaptic += 1 // Trigger haptic feedback
//             completion(true) // Signal success for dismissal
//
//        } catch {
//             print("Error deleting habit: \(error)")
//             showError("Failed to delete habit. Please try again.\n(\(error.localizedDescription))")
//             completion(false)
//        }
//    }
//
//
//    // MARK: - UI Helpers
//
//    private func showError(_ message: String) {
//        errorMessage = message
//        showingErrorAlert = true
//    }
//
//    // Call this if the user explicitly toggles the reminder switch
//    func reminderToggled(isOn: Bool) {
//        // If turning on, and time hasn't been set by user yet, ensure it has a default.
//        // The view might already handle this, but this is a safeguard.
//        // The actual permission check happens during the save process.
//        if isOn && habitToEdit?.reminderTime == nil { // Only default if editing an existing habit that had no time
//             // Use the default set in the property initializer
//        }
//        // The @Published reminderEnabled property is updated directly by the View's binding
//    }
//}
