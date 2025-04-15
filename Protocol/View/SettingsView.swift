//
//  SettingsView.swift
//  Protocol
//
//  Created by Kamol Madaminov on 13/04/25.
//

import SwiftUI
import UniformTypeIdentifiers

enum SettingsNavigation: Hashable {
    case habitList
    case dataRetention
}

struct SettingsView: View {
    
    @AppStorage("hapticsEnabled") var hapticsEnabled: Bool = true
    @AppStorage("dataRetentionPeriod") var selectedRetentionPeriod: String = DataRetentionPeriod.indefinite.rawValue
    
    // --- ViewModel ---
    @State private var viewModel: SettingsViewModel? = nil
    
    // Inject ModelContext via Environment
    @Environment(\.modelContext) private var modelContext
    
    @State private var showRetentionInfoPopover = false
    
    var body: some View {
        NavigationStack {
            // Use Group to apply modifiers conditionally based on viewModel
            Group {
                if let vm = viewModel {
                    List {
                        Section("Preferences") {
                            Toggle("Enable Haptics", isOn: $hapticsEnabled)
                        }
                        
                        Section("Data Management") {
                            NavigationLink(value: SettingsNavigation.habitList) {
                                Label("Manage Habits", systemImage: "list.bullet.rectangle.portrait")
                            }
                            
                            // Inside Section("Data Management")
                            
                            NavigationLink(value: SettingsNavigation.dataRetention) {
                                HStack {
                                    Label("Data Retention", systemImage: "hourglass")
                                    
                                    Button {
                                        showRetentionInfoPopover = true
                                    } label: {
                                        Image(systemName: "questionmark.circle")
                                            .foregroundStyle(.secondary)
                                    }
                                    .buttonStyle(.plain)
                                    
                                    Spacer()
                                    
                                    Text(selectedRetentionPeriod)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .popover(isPresented: $showRetentionInfoPopover, arrowEdge: .bottom) {
                                Text("Logs older than the selected period will be deleted automatically the next time the app starts.")
                                    .font(.caption)
                                    .padding()
                                    .presentationCompactAdaptation(.popover)
                            }
                            
                            // Export Data Button
                            Button {
                                Task {
                                    await vm.triggerExport()
                                }
                            } label: {
                                if vm.isExporting {
                                    HStack { Text("Exporting..."); Spacer(); ProgressView() }
                                } else {
                                    Label("Export Log Data (JSON)", systemImage: "square.and.arrow.up")
                                }
                            }
                            .disabled(vm.isExporting)
                        }
                        
                        Section("About") {
                            HStack { Text("App Version"); Spacer(); Text("1.0.0").foregroundColor(.gray) }
                        }
                    }
                    .navigationTitle("Settings")
                    .navigationDestination(for: SettingsNavigation.self) { destination in
                        switch destination {
                        case .habitList:
                            HabitListView()
                        case .dataRetention:
                            DataRetentionSelectionView(selectedPeriod: $selectedRetentionPeriod)
                        }
                    }
                    .modifier(ExportShareSheet(fileURL: Binding(
                        get: { vm.exportFileURL },
                        set: { vm.exportFileURL = $0 }
                    )))
                    .alert("Export Error", isPresented: Binding(
                        get: { vm.showingExportErrorAlert },
                        set: { vm.showingExportErrorAlert = $0 }
                    )) {
                        Button("OK") {}
                    } message: {
                        Text(vm.exportError ?? "An unknown error occurred.")
                    }
                } else {
                    // Show loading view while ViewModel is initializing
                    ProgressView("Loading Settings...")
                }
            }
            .task {
                if viewModel == nil {
                    viewModel = SettingsViewModel(modelContext: modelContext)
                }
            }
        }
    }
}

struct ExportShareSheet: ViewModifier {
    @Binding var fileURL: URL?
    
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: Binding(get: { fileURL != nil }, set: { if !$0 { fileURL = nil } })) {
                if let urlToShare = fileURL {
                    ShareSheetView(urlToShare: urlToShare)
                }
            }
    }
}

// Simple view to host ShareLink inside the sheet (iOS 16+)
struct ShareSheetView: View {
    let urlToShare: URL
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            Text("Export Ready")
                .font(.title2)
                .padding()
            
            Text("Share or save the exported JSON file:")
                .padding(.bottom)
            
            ShareLink(item: urlToShare,
                      subject: Text("Protocol App Data Export"),
                      message: Text("Here's the data exported from the Protocol App."),
                      preview: SharePreview("Protocol_Export.json", icon: Image(systemName: "doc.text"))) {
                Label("Share Exported File", systemImage: "square.and.arrow.up")
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            
            Button("Done") {
                dismiss()
            }
            .padding(.top)
        }
        // Prevent interactive dismiss while sharing might be active
        .interactiveDismissDisabled()
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .modelContainer(for: Habit.self, inMemory: true)
    }
}
