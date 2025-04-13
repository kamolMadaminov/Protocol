//
//  HabitListView.swift
//  Protocol
//
//  Created by Kamol Madaminov on 13/04/25.
//

import SwiftUI
import SwiftData

struct HabitListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor<Habit>(\.name)]) private var habits: [Habit] // Sort alphabetically

    @State private var showingAddHabitSheet = false

    var body: some View {
        List {
            if habits.isEmpty {
                 ContentUnavailableView(
                     "No Habits Defined",
                     systemImage: "list.bullet.rectangle.portrait.fill",
                     description: Text("Tap the '+' button to add your first habit.")
                 )
            } else {
                ForEach(habits) { habit in
                    // Link pushes the Habit value
                    NavigationLink(value: habit) {
                        Text(habit.name)
                    }
                }
                .onDelete(perform: deleteHabits)
            }
        }
        .navigationDestination(for: Habit.self) { habit in
            AddEditHabitView(habitToEdit: habit)
        }
        .navigationTitle("Habits")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingAddHabitSheet = true
                } label: {
                    Label("Add Habit", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddHabitSheet) {
            NavigationStack {
                 AddEditHabitView(habitToEdit: nil)
            }
             .environment(\.modelContext, modelContext)
        }
    }

    private func deleteHabits(offsets: IndexSet) {
        withAnimation {
            offsets.map { habits[$0] }.forEach(modelContext.delete)
             try? modelContext.save()
        }
    }
}

#Preview {
    NavigationStack {
        HabitListView()
            .modelContainer(for: Habit.self, inMemory: true)
            .onAppear {
                let context = (try? ModelContainer(for: Habit.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true)).mainContext)
                if let context = context {
                    context.insert(Habit(name: "Read Daily"))
                    context.insert(Habit(name: "Exercise"))
                    context.insert(Habit(name: "Meditate"))
                }
            }
    }
}
