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
    @AppStorage("hapticsEnabled") var hapticsEnabled: Bool = true
    
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \Habit.creationDate) private var habitsFromQuery: [Habit]
    
    @State private var viewModel: TodayViewModel?
    
    @State private var showingDeleteConfirmAlert = false
    
    @State private var showingAddHabitSheet = false
    
    private enum FocusableField: Hashable {
        case note
        case reflection
    }
    
    @FocusState private var focusedField: FocusableField?
    
    var body: some View {
        NavigationStack {
            Group {
                if let viewModel = viewModel {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 30) {
                            // --- Habits Section ---
                            VStack(alignment: .leading, spacing: 16) {
                                Label("Habits", systemImage: "list.bullet.clipboard")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.secondary)
                                
                                Divider()
                                
                                if viewModel.sortedHabits.isEmpty {
                                    Text("No habits defined yet. Add some in Settings!")
                                } else {
                                    ForEach(viewModel.sortedHabits, id: \.persistentModelID) { habit in
                                        let habitToggleRow = Toggle(isOn: Binding(
                                            get: { viewModel.habits[habit.name] ?? false },
                                            set: { newValue in
                                                viewModel.habits[habit.name] = newValue
                                                viewModel.saveLog()
                                            }
                                        )) {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(habit.name)
                                                if let description = habit.habitDescription, !description.isEmpty {
                                                    Text(description)
                                                }
                                            }
                                            .padding(.vertical, 4)
                                        }
                                            .tint(.accentColor)
                                        
                                        if hapticsEnabled {
                                            habitToggleRow
                                                .sensoryFeedback(.success, trigger: viewModel.habits[habit.name] == true)
                                        } else {
                                            habitToggleRow
                                        }
                                        
                                        Divider()
                                    }
                                }
                            }
                            
                            // --- State Log Section ---
                            VStack(alignment: .leading, spacing: 16) {
                                Label("State Log", systemImage: "brain.head.profile") // ... Title formatting ...
                                Divider()
                                
                                // Mood Picker Sub-section
                                VStack(alignment: .leading) {
                                    Text("Mood").font(.headline)
                                    
                                    let moodPicker = Picker("Mood", selection: Binding(
                                        get: { viewModel.mood },
                                        set: { viewModel.mood = $0; viewModel.saveLog() }
                                    )) {
                                        Text("🔥").tag("🔥")
                                        Text("🌫️").tag("🌫️")
                                        Text("⚡️").tag("⚡️")
                                    }
                                        .pickerStyle(.segmented)
                                    if hapticsEnabled {
                                        moodPicker
                                            .sensoryFeedback(.selection, trigger: viewModel.mood)
                                    } else {
                                        moodPicker
                                    }
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
                                    .focused($focusedField, equals: .note)
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
                                .focused($focusedField, equals: .reflection)
                            }
                        }
                        .padding()
                        .contentShape(Rectangle())
                        .onTapGesture {
                            focusedField = nil // <-- Set focus state to nil to dismiss
                        }
                    }
                    .alert("Clear Today's Log?", isPresented: $showingDeleteConfirmAlert) {
                        Button("Clear Data", role: .destructive) {
                            viewModel.deleteTodaysLog()
                        }
                        Button("Cancel", role: .cancel) { }
                    } message: {
                        Text("Are you sure you want to clear all logged data for today? This cannot be undone.")
                    }
                    .navigationTitle("Today’s Protocol")
                    .navigationBarTitleDisplayMode(.large)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(role: .destructive) {
                                showingDeleteConfirmAlert = true
                            } label: {
                                Label("Reset Today", systemImage: "repeat")
                            }
                            .disabled(viewModel.log == nil && viewModel.habits.values.allSatisfy { !$0 } && viewModel.mood == "🔥" && viewModel.note.isEmpty && viewModel.reflection.isEmpty)
                        }
                        
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                showingAddHabitSheet = true
                            } label: {
                                Label("Add Habit", systemImage: "plus")
                            }
                        }
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
            .sheet(isPresented: $showingAddHabitSheet) {
                NavigationStack {
                    AddEditHabitView(habitToEdit: nil)
                }
            }
            .task(id: habitsFromQuery) {
                if viewModel == nil {
                    viewModel = TodayViewModel(context: modelContext, initialHabits: habitsFromQuery)
                } else {
                    viewModel?.updateHabits(habitsFromQuery)
                }
            }
        }
    }
}


#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: DailyLog.self, Habit.self, configurations: config)
        
        // Add sample habits WITH descriptions for preview
        let habit1 = Habit(name: "Workout", habitDescription: "Morning strength training")
        let habit2 = Habit(name: "Read 30 Mins", habitDescription: "Read 'Atomic Habits'")
        let habit3 = Habit(name: "Meditate") // No description
        container.mainContext.insert(habit1)
        container.mainContext.insert(habit2)
        container.mainContext.insert(habit3)
        
        return TodayView()
            .modelContainer(container)
    } catch {
        fatalError("Failed to create model container for preview: \(error)")
    }
}
