//
//  TodayView.swift
//  Protocol
//
//  Created by Kamol Madaminov on 11/04/25.
//
// TodayView.swift (Changes highlighted)

import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: TodayViewModel?

    var body: some View {
        Group {
            if let viewModel = viewModel {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        Text("Today’s Protocol")
                            .font(.title)
                            .fontWeight(.semibold)
                         
                        VStack(alignment: .leading, spacing: 16) {
                            Text("📆 Habits")
                                .font(.headline)

                            ForEach(viewModel.sortedHabitNames, id: \.self) { habitName in
                                Toggle(isOn: Binding(
                                    get: { viewModel.habits[habitName] ?? false },
                                    set: { newValue in
                                        viewModel.habits[habitName] = newValue
                                        viewModel.saveLog()
                                    }
                                )) {
                                    Text(habitName)
                                }
                            }
                             // Adding a message if no habits are defined yet
                            if viewModel.sortedHabitNames.isEmpty {
                                Text("No habits defined yet. Add some in Settings!") // Placeholder text
                                    .foregroundColor(.gray)
                                    .padding(.vertical)
                            }
                        }

                        VStack(alignment: .leading, spacing: 12) {
                            Text("🧠 State Log")
                                .font(.headline)

                            Picker("Mood", selection: Binding(
                                get: { viewModel.mood },
                                set: { viewModel.mood = $0; viewModel.saveLog() } // Save on change
                            )) {
                                Text("🔥").tag("🔥")
                                Text("🌫️").tag("🌫️")
                                Text("⚡️").tag("⚡️")
                            }
                            .pickerStyle(.segmented)
                            TextField("Note (optional)", text: Binding(
                                get: { viewModel.note },
                                set: { viewModel.note = $0 }
                            ), onCommit: {
                                viewModel.saveLog()
                            })
                            .textFieldStyle(.roundedBorder)

                        }

                        VStack(alignment: .leading, spacing: 12) {
                            Text("📜 Reflection Prompt")
                                .font(.headline)

                            Text("“Did your actions match your mission?”")

                            TextField("Write your reflection...", text: Binding(
                                get: { viewModel.reflection },
                                set: { viewModel.reflection = $0 }
                            ), onCommit: {
                                 viewModel.saveLog()
                            })
                            .textFieldStyle(.roundedBorder)

                        }

                    }
                    .padding()
                }
                .onAppear {
                    viewModel.fetchDefinedHabits()
                    viewModel.loadLog()
                }

            } else {
                ProgressView("Loading Protocol...")
                    .onAppear {
                        if self.viewModel == nil {
                           self.viewModel = TodayViewModel(context: modelContext)
                        }
                    }
            }
        }
    }
}


#Preview {
     do {
         let config = ModelConfiguration(isStoredInMemoryOnly: true)
         let container = try ModelContainer(for: DailyLog.self, Habit.self, configurations: config) // Add Habit

         let habit1 = Habit(name: "Workout")
         let habit2 = Habit(name: "Read 30 Mins")
         let habit3 = Habit(name: "Meditate")
         container.mainContext.insert(habit1)
         container.mainContext.insert(habit2)
         container.mainContext.insert(habit3)

         return TodayView()
             .modelContainer(container)
     } catch {
         fatalError("Failed to create model container for preview: \(error)")
     }
}
