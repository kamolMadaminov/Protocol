//
//  DataRetentionSelectionView.swift
//  Protocol
//
//  Created by Kamol Madaminov on 15/04/25.
//

import SwiftUI

struct DataRetentionSelectionView: View {
    // Binding to the @AppStorage variable from SettingsView
    @Binding var selectedPeriod: String

    var body: some View {
        List {
            Picker("Delete Logs Older Than", selection: $selectedPeriod) {
                ForEach(DataRetentionPeriod.allCases) { period in
                    Text(period.rawValue).tag(period.rawValue)
                }
            }
            .pickerStyle(.inline)
            .labelsHidden()

            Section {
                Text("Logs older than the selected period will be deleted automatically the next time the app starts.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Data Retention")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Preview for DataRetentionSelectionView
#Preview {
    struct PreviewWrapper: View {
        @State var selection = DataRetentionPeriod.indefinite.rawValue
        var body: some View {
            NavigationStack { 
                DataRetentionSelectionView(selectedPeriod: $selection)
            }
        }
    }
    return PreviewWrapper()
}
