//
//  SettingsViewModel.swift
//  Protocol
//
//  Created by Kamol Madaminov on 15/04/25.
//

import SwiftUI
import SwiftData

@Observable
class SettingsViewModel {
    var exportFileURL: URL? = nil
    var exportError: String? = nil
    var showingExportErrorAlert: Bool = false
    
    var isExporting: Bool = false

    private let modelContext: ModelContext

    // Inject ModelContext on initialization
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    @MainActor // Ensure UI updates happen on the main thread
    func triggerExport() async {
        guard !isExporting else { return } // Prevent multiple exports at once

        print("ViewModel: Triggering export...")
        isExporting = true
        exportError = nil // Clear previous errors
        exportFileURL = nil // Clear previous URL

        let exportManager = DataExportManager(modelContext: modelContext)
        do {
            let url = try exportManager.exportToJSON()
            print("ViewModel: Export success, URL: \(url)")
            self.exportFileURL = url // Set the URL to trigger the ShareLink sheet
        } catch {
            print("ViewModel: Export failed: \(error)")
            self.exportError = "Failed to export data: \(error.localizedDescription)"
            self.showingExportErrorAlert = true
            self.exportFileURL = nil // Ensure sheet doesn't show on error
        }
        
        isExporting = false // Mark export as finished
    }
}
