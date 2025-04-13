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
                    VStack(alignment: .leading, spacing: 30) {

                        Text("Today’s Protocol")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        // --- Habits Section ---
                        VStack(alignment: .leading, spacing: 16) {
                            Label("Habits", systemImage: "list.bullet.clipboard")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundStyle(.secondary)

                            Divider()

                            if viewModel.sortedHabitNames.isEmpty {
                                Text("No habits defined yet. Add some in Settings!")
                                    .foregroundColor(.secondary)
                                    .padding(.vertical)
                            } else {
                                ForEach(viewModel.sortedHabitNames, id: \.self) { habitName in
                                    Toggle(isOn: Binding(
                                        get: { viewModel.habits[habitName] ?? false },
                                        set: { newValue in
                                            viewModel.habits[habitName] = newValue
                                            viewModel.saveLog()
                                        }
                                    )) {
                                        Text(habitName)
                                            .font(.body)
                                    }
                                    .tint(.accentColor)
                                }
                            }
                        }

                        // --- State Log Section ---
                        VStack(alignment: .leading, spacing: 16) {
                            Label("State Log", systemImage: "brain.head.profile")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundStyle(.secondary)

                            Divider()

                            // Mood Picker Sub-section
                            VStack(alignment: .leading) {
                                Text("Mood")
                                    .font(.headline)
                                Picker("Mood", selection: Binding(
                                    get: { viewModel.mood },
                                    set: { viewModel.mood = $0; viewModel.saveLog() }
                                )) {
                                    Text("🔥").tag("🔥")
                                    Text("🌫️").tag("🌫️")
                                    Text("⚡️").tag("⚡️")
                                }
                                .pickerStyle(.segmented)
                            }

                            // Note Sub-section
                            VStack(alignment: .leading) {
                                Text("Note")
                                     .font(.headline) // Sub-header
                                TextField("Add a brief note (optional)...", text: Binding(
                                    get: { viewModel.note },
                                    set: { viewModel.note = $0 }
                                ), onCommit: {
                                    viewModel.saveLog()
                                })
                                .textFieldStyle(.roundedBorder)
                            }
                        }

                        // --- Reflection Section ---
                        VStack(alignment: .leading, spacing: 16) {
                            Label("Reflection", systemImage: "text.bubble")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundStyle(.secondary)

                            Divider()

                            // Reflection Prompt Sub-section
                            VStack(alignment: .leading) {
                                Text("Prompt:")
                                    .font(.headline)
                                Text("“Did your actions match your mission?”")
                                    .font(.callout)
                                    .foregroundStyle(.secondary)
                                    .padding(.bottom, 4)
                            }

                            TextField("Write your reflection...", text: Binding(
                                get: { viewModel.reflection },
                                set: { viewModel.reflection = $0 }
                            ), axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .lineLimit(5...10)
                            .onSubmit {
                                viewModel.saveLog()
                            }
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
