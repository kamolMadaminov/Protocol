//
//  TodayView.swift
//  Protocol
//
//  Created by Kamol Madaminov on 11/04/25.
//
// TodayView.swift

import SwiftUI
import SwiftData

struct CardBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .background(.background.secondary)
            .background(.ultraThinMaterial)
        
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(.separator.opacity(0.5), lineWidth: 1))
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

struct TodayView: View {
    @AppStorage("hapticsEnabled") var hapticsEnabled: Bool = true
    
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \Habit.creationDate) private var habitsFromQuery: [Habit]
    
    @State private var viewModel: TodayViewModel?
    
    @State private var showingDeleteConfirmAlert = false
    
    @State private var showingAddHabitSheet = false
    @State private var habitToEditInSheet: Habit? = nil
    
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
                        VStack(alignment: .leading, spacing: 20) {
                            // --- Habits Section ---
                            VStack(alignment: .leading, spacing: 12) {
                                Label("Habits", systemImage: "list.bullet.clipboard")
                                    .font(.title2.bold())
                                    .foregroundStyle(.secondary)
                                
                                if viewModel.sortedHabits.isEmpty {
                                    Text("No habits defined yet. Add some in Settings!")
                                        .foregroundColor(.secondary)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .padding(.vertical)
                                } else {
                                    VStack(alignment: .leading, spacing: 0){
                                        ForEach(viewModel.sortedHabits, id: \.persistentModelID) { habit in
                                            HStack(spacing: 12) {
                                                let isCompleted = viewModel.habits[habit.name] ?? false
                                                
                                                Image(systemName: isCompleted ? "checkmark.square.fill" : "square")
                                                    .font(.title3)
                                                    .foregroundStyle(isCompleted ? Color.accentColor : Color.secondary)
                                                    .onTapGesture {
                                                        let newValue = !isCompleted
                                                        viewModel.habits[habit.name] = newValue
                                                        viewModel.saveLog()
                                                    }
                                                    .sensoryFeedback(.success, trigger: isCompleted && hapticsEnabled)
                                                
                                                VStack(alignment: .leading, spacing: 2) {
                                                    Text(habit.name)
                                                        .font(.body)
                                                        .foregroundColor(.primary)
                                                    if let description = habit.habitDescription, !description.isEmpty {
                                                        Text(description)
                                                            .font(.caption)
                                                            .foregroundColor(.secondary)
                                                    }
                                                }
                                                .padding(.vertical, 8)
                                                
                                                Spacer()
                                            }
                                            .contentShape(Rectangle())
                                            .contextMenu {
                                                // Your Button code goes here...
                                                Button {
                                                    self.habitToEditInSheet = habit
                                                } label: {
                                                    Label("Edit Habit", systemImage: "pencil")
                                                }
                                            }
                                            
                                            Divider().padding(.leading, 40)
                                        }
                                    }
                                }
                            }
                            .cardStyle()
                            // --- State Log Section ---
                            VStack(alignment: .leading, spacing: 16) {
                                Label("State Log", systemImage: "brain.head.profile")
                                    .font(.title2.bold())
                                    .foregroundStyle(.secondary)
                                
                                // Mood Picker Sub-section
                                VStack(alignment: .leading) {
                                    Text("Mood – \(viewModel.moodDescription(for: viewModel.mood))")
                                        .font(.headline)
                                    
                                    
                                    let moodPicker = Picker("Mood", selection: Binding(
                                        get: { viewModel.mood },
                                        set: { viewModel.mood = $0; viewModel.saveLog() }
                                    )) {
                                        Text("🥀").tag("🥀")
                                        Text("😮‍💨").tag("😮‍💨")
                                        Text("🙂").tag("🙂")
                                        Text("💪").tag("💪")
                                        Text("🚀").tag("🚀")
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
                                        .font(.headline)
                                    TextField("Add a brief note (optional)...", text: Binding(
                                        get: { viewModel.note },
                                        set: { viewModel.note = $0 }
                                    ), onCommit: {
                                        viewModel.saveLog()
                                    })
                                    .textFieldStyle(.plain)
                                    .padding(8)
                                    .background(.background)
                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                                    .focused($focusedField, equals: .note)
                                    .textFieldStyle(.roundedBorder)
                                    .focused($focusedField, equals: .note)
                                }
                            }
                            .cardStyle()
                            // --- Reflection Section ---
                            VStack(alignment: .leading, spacing: 12) {
                                Label("Reflection", systemImage: "text.bubble")
                                    .font(.title2.bold())
                                    .foregroundStyle(.secondary)
                                
                                // Reflection Prompt Sub-section
                                VStack(alignment: .leading) {
                                    Text("Prompt:")
                                        .font(.headline)
                                    Text("“Did your actions match your mission?”")
                                        .padding(.bottom, 4)
                                }
                                
                                TextField("Write your reflection...", text: Binding(
                                    get: { viewModel.reflection },
                                    set: { viewModel.reflection = $0 }
                                ), axis: .vertical)
                                .textFieldStyle(.plain)
                                .padding(8)
                                .background(.background)
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                                .lineLimit(5...10)
                                .onSubmit { viewModel.saveLog() }
                                .focused($focusedField, equals: .reflection)
                                .onChange(of: focusedField) { newFocus in
                                    if newFocus != .reflection {
                                        viewModel.saveLog()
                                    }
                                }
                                
                            }
                            .cardStyle()
                        }
                        .padding(.horizontal)
                        .padding(.vertical)
                        .background(Color(uiColor: .systemGroupedBackground))
                        .contentShape(Rectangle())
                        .onTapGesture {
                            focusedField = nil
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
                                Label("Reset Today", systemImage: "arrow.counterclockwise")
                            }
                            .disabled(viewModel.log == nil && viewModel.habits.values.allSatisfy { !$0 } && viewModel.mood == "🙂" && viewModel.note.isEmpty && viewModel.reflection.isEmpty)
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
            .sheet(item: $habitToEditInSheet) { habitToEdit in
                NavigationStack {
                    AddEditHabitView(habitToEdit: habitToEdit)
                }
            }
            .sheet(isPresented: $showingAddHabitSheet) {
                NavigationStack {
                    AddEditHabitView()
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

extension View {
    func cardStyle() -> some View {
        modifier(CardBackground())
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
