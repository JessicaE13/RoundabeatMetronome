//
//  FilterSortSheet.swift
//  RoundabeatMetronome
//

import SwiftUI

// MARK: - Filter & Sort Sheet
struct FilterSortSheet: View {
    @ObservedObject var songManager: SongManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section("Sort By") {
                    Picker("Sort Option", selection: $songManager.sortBy) {
                        ForEach(SongManager.SortOption.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    Toggle("Ascending Order", isOn: $songManager.sortAscending)
                }
                
                Section {
                    Button("Clear All Filters") {
                        songManager.searchText = ""
                        songManager.sortBy = .dateAdded
                        songManager.sortAscending = false
                    }
                }
            }
            .navigationTitle("Filter & Sort")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    FilterSortSheet(songManager: SongManager())
}
