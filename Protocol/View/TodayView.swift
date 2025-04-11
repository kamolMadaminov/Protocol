//
//  TodayView.swift
//  Protocol
//
//  Created by Kamol Madaminov on 11/04/25.
//

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

                            ForEach(viewModel.habits.keys.sorted(), id: \.self) { habit in
                                Toggle(isOn: Binding(
                                    get: { viewModel.habits[habit] ?? false },
                                    set: { viewModel.habits[habit] = $0; viewModel.saveLog() }
                                )) {
                                    Text(habit)
                                }
                            }
                        }

                        VStack(alignment: .leading, spacing: 12) {
                            Text("🧠 State Log")
                                .font(.headline)

                            Picker("Mood", selection: Binding(
                                get: { viewModel.mood },
                                set: { viewModel.mood = $0 }
                            )) {
                                Text("🔥").tag("🔥")
                                Text("🌫️").tag("🌫️")
                                Text("⚡️").tag("⚡️")
                            }
                            .pickerStyle(.segmented)
                            .onChange(of: viewModel.mood) { _, _ in viewModel.saveLog() }

                            TextField("Note (optional)", text: Binding(
                                get: { viewModel.note },
                                set: { viewModel.note = $0 }
                            ))
                            .textFieldStyle(.roundedBorder)
                            .onSubmit { viewModel.saveLog() }
                        }

                        VStack(alignment: .leading, spacing: 12) {
                            Text("📜 Reflection Prompt")
                                .font(.headline)

                            Text("“Did your actions match your mission?”") // Placeholder, dynamic later

                            TextField("Write your reflection...", text: Binding(
                                get: { viewModel.reflection },
                                set: { viewModel.reflection = $0 }
                            ))
                            .textFieldStyle(.roundedBorder)
                            .onSubmit { viewModel.saveLog() }
                        }
                    }
                    .padding()
                }
            } else {
                ProgressView("Loading Protocol...")
                    .onAppear {
                        self.viewModel = TodayViewModel(context: modelContext)
                    }
            }
        }
    }
}


#Preview {
    TodayView()
}
