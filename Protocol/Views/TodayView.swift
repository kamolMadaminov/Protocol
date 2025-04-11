//
//  TodayView.swift
//  Protocol
//
//  Created by Kamol Madaminov on 11/04/25.
//

import SwiftUI

struct TodayView: View {
    @StateObject private var viewModel = ProtocolViewModel()
    
    let moodOptions = ["🔥", "🧊", "🌫️", "⚡️", "💀", "😤", "💤", "🚀"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Habits Section
                    Text("Habits")
                        .font(.headline)
                    
                    ForEach(viewModel.habits) { habit in
                        HStack {
                            Text(habit.name)
                            Spacer()
                            Image(systemName: habit.isCompleted ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(habit.isCompleted ? .green : .gray)
                                .onTapGesture {
                                    viewModel.toggleHabit(habit)
                                }
                        }
                        .padding(.vertical, 4)
                    }
                    
                    Divider()
                    
                    // Mood Section
                    Text("Mindset")
                        .font(.headline)
                    
                    Picker("Mood", selection: $viewModel.selectedMood) {
                        ForEach(moodOptions, id: \.self) { emoji in
                            Text(emoji).tag(emoji)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    Divider()
                    
                    // Reflection
                    Text("Reflection Prompt")
                        .font(.headline)
                    
                    Text(viewModel.dailyPrompt)
                        .font(.subheadline)
                        .italic()
                    
                    TextField("Your 1-line reflection", text: $viewModel.reflection)
                        .textFieldStyle(.roundedBorder)
                        .padding(.top, 4)
                    
                    Button("Save Today") {
                        viewModel.saveLog()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("Today")
        }
    }
}

#Preview {
    TodayView()
}
