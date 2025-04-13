//
//  AddEditHabitView.swift
//  Protocol
//
//  Created by Kamol Madaminov on 13/04/25.
//

import SwiftUI
import SwiftData

struct AddEditHabitView: View {
    // Environment properties
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss

    // The habit being edited, or nil if adding a new one
    var habitToEdit: Habit?

    // State for the form fields
    @State private var habitName: String = ""

    // State for managing alerts
    @State private var showingDeleteConfirm = false
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""

    private var isEditing: Bool {
        habitToEdit != nil
    }

    // Computed property for the navigation title
    private var navigationTitle: String {
        isEditing ? "Edit Habit" : "Add Habit"
    }

    var body: some View {
        // No inner NavigationStack needed here - relies on presentation context
        Form {
            TextField("Habit Name", text: $habitName)
                // Automatically trim whitespace
                .onChange(of: habitName) { oldValue, newValue in
                    habitName = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                }
        }
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {

            // Save Button (trailing)
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    saveHabit()
                }
                .disabled(habitName.isEmpty) // Check trimmed name
            }

            // Delete Button (only show if editing)
            if isEditing {
                ToolbarItem(placement: .destructiveAction) {
                    Button("Delete", role: .destructive) {
                        showingDeleteConfirm = true // Trigger confirmation
                    }
                }
            } else {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            if let habit = habitToEdit {
                habitName = habit.name.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        // Alert for Delete Confirmation
        .alert("Delete Habit?", isPresented: $showingDeleteConfirm) {
            Button("Delete", role: .destructive) {
                performDelete()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete the habit \"\(habitToEdit?.name ?? "")\"? This cannot be undone.")
        }
        // Alert for Save/Delete Errors
        .alert("Error", isPresented: $showingErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }

    //MARK: --- Private Functions ---

    private func saveHabit() {
        guard !habitName.isEmpty else {
            showError("Habit name cannot be empty.")
            return
        }

        do {
            if let habit = habitToEdit {
                // Editing existing habit
                habit.name = habitName // Already trimmed
                print("Updating habit ID: \(habit.persistentModelID)")
            } else {
                // Adding new habit
                let newHabit = Habit(name: habitName, creationDate: Date())
                modelContext.insert(newHabit)
                print("Inserting new habit")
            }

            try modelContext.save()
            print("Save successful")
            dismiss() // Dismiss on success

        } catch {
            print("Error saving habit: \(error)")
            showError("Failed to save habit. Please try again.\n(\(error.localizedDescription))")
        }
    }

    private func performDelete() {
        guard let habit = habitToEdit else { return }

        do {
            print("Deleting habit ID: \(habit.persistentModelID)")
            modelContext.delete(habit)
            try modelContext.save()
            print("Delete successful")
            dismiss() // Dismiss on success

        } catch {
            print("Error deleting habit: \(error)")
            showError("Failed to delete habit. Please try again.\n(\(error.localizedDescription))")
        }
    }

    private func showError(_ message: String) {
        errorMessage = message
        showingErrorAlert = true
    }
}

// --- Previews ---

#Preview("Add Habit") {
    NavigationStack {
        AddEditHabitView(habitToEdit: nil)
            .modelContainer(for: Habit.self, inMemory: true)
    }
}

#Preview("Edit Habit") {
     let config = ModelConfiguration(isStoredInMemoryOnly: true)
     let container = try! ModelContainer(for: Habit.self, configurations: config)
     let sampleHabit = Habit(name: "  Existing Habit  ")
     container.mainContext.insert(sampleHabit)

    return NavigationStack {
        AddEditHabitView(habitToEdit: sampleHabit)
           .modelContainer(container)
    }
}
