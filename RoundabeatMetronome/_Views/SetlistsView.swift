//
//  SetlistViews.swift
//  RoundabeatMetronome
//

import SwiftUI

// MARK: - Main Setlists View
struct SetlistsView: View {
    @ObservedObject var setlistManager: SetlistManager
    @ObservedObject var songManager: SongManager
    @ObservedObject var metronome: MetronomeEngine
    
    @State private var showingCreateSetlist = false
    @State private var selectedSetlist: Setlist? = nil
    @State private var showingEditSetlist = false
    @State private var showingFilterSheet = false
    
    var body: some View {
        NavigationView {
            Form {
                // Search and Actions Section
                Section {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                            .font(.system(size: 16))
                        
                        TextField("Search setlists...", text: $setlistManager.searchText)
                            .textFieldStyle(.plain)
                    }
                    .padding(.vertical, 4)
                    
                    HStack {
                        Button(action: {
                            showingFilterSheet = true
                        }) {
                            HStack {
                                Image(systemName: "line.3.horizontal.decrease.circle")
                                Text("Filter & Sort")
                            }
                            .foregroundColor(.accentColor)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            showingCreateSetlist = true
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("New Setlist")
                            }
                            .foregroundColor(.accentColor)
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                // Setlists List Section
                if setlistManager.filteredSetlists.isEmpty {
                    Section {
                        emptySetlistsView
                    }
                } else {
                    // In SetlistsView.swift, find this section and replace it:

                    List {
                        Section("My Setlists") {
                            ForEach(setlistManager.filteredSetlists) { setlist in
                                NavigationLink(destination: SetlistDetailView(
                                    setlist: setlist,
                                    setlistManager: setlistManager,
                                    songManager: songManager,
                                    metronome: metronome
                                )) {
                                    SetlistRowView(
                                        setlist: setlist,
                                        songCount: setlist.songIds.count,
                                        onEdit: {
                                            selectedSetlist = setlist
                                            showingEditSetlist = true
                                        },
                                        onDelete: {
                                            setlistManager.deleteSetlist(setlist)
                                        },
                                        onDuplicate: {
                                            setlistManager.duplicateSetlist(setlist)
                                        }
                                    )
                                }
                            }
                            .onMove(perform: setlistManager.moveSetlist) // Fixed: use the manager method directly
                        }
                    }

                    // Remove this standalone function completely:
                    // private func moveSetlist(from source: IndexSet, to destination: Int) {
                    //     setlistManager.moveSetlist(from: source, to: destination)
                    // }
                    
                }
            }
            .navigationTitle("Setlists")
            .navigationBarTitleDisplayMode(.large)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $showingCreateSetlist) {
            CreateEditSetlistView(
                setlistManager: setlistManager,
                editingSetlist: nil
            )
        }
        .sheet(isPresented: $showingEditSetlist) {
            if let setlist = selectedSetlist {
                CreateEditSetlistView(
                    setlistManager: setlistManager,
                    editingSetlist: setlist
                )
            }
        }
        .sheet(isPresented: $showingFilterSheet) {
            SetlistFilterSortSheet(setlistManager: setlistManager)
        }
    }
    
    private var emptySetlistsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "music.note.list")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
                .padding(.top, 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("No Setlists Yet")
                    .font(.body)
                Text("Create setlists to organize your songs for performances or practice sessions")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Button(action: {
                showingCreateSetlist = true
            }) {
                Text("Create Your First Setlist")
                    .foregroundColor(.accentColor)
            }
            .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity)
        .multilineTextAlignment(.center)
    }
}




// MARK: - Setlist Row View
struct SetlistRowView: View {
    let setlist: Setlist
    let songCount: Int
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onDuplicate: () -> Void
    
    @State private var showingActionSheet = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Setlist icon
            Image(systemName: "music.note.list")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.accentColor)
                .frame(width: 36, height: 36)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.accentColor.opacity(0.1))
                )
            
            // Setlist info
            VStack(alignment: .leading, spacing: 4) {
                Text(setlist.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    Text("\(songCount) song\(songCount == 1 ? "" : "s")")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    if !setlist.notes.isEmpty {
                        Text("•")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        
                        Text(setlist.notes)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                
                Text("Modified \(formatDate(setlist.dateModified))")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // More button
            Button(action: {
                showingActionSheet = true
            }) {
                Image(systemName: "ellipsis")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
        }
        .confirmationDialog("Setlist Options", isPresented: $showingActionSheet, titleVisibility: .visible) {
            Button("Edit Setlist") {
                onEdit()
            }
            
            Button("Duplicate Setlist") {
                onDuplicate()
            }
            
            Button("Delete Setlist", role: .destructive) {
                onDelete()
            }
            
            Button("Cancel", role: .cancel) { }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Create/Edit Setlist View
struct CreateEditSetlistView: View {
    @ObservedObject var setlistManager: SetlistManager
    let editingSetlist: Setlist?
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var notes: String = ""
    
    init(setlistManager: SetlistManager, editingSetlist: Setlist? = nil) {
        self.setlistManager = setlistManager
        self.editingSetlist = editingSetlist
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Setlist Details") {
                    TextField("Setlist Name", text: $name)
                    
                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(3, reservesSpace: true)
                }
            }
            .navigationTitle(editingSetlist == nil ? "New Setlist" : "Edit Setlist")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveSetlist()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .onAppear {
            if let setlist = editingSetlist {
                name = setlist.name
                notes = setlist.notes
            }
        }
    }
    
    private func saveSetlist() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedNotes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let editingSetlist = editingSetlist {
            var updatedSetlist = editingSetlist
            updatedSetlist.updateName(trimmedName)
            updatedSetlist.updateNotes(trimmedNotes)
            setlistManager.updateSetlist(updatedSetlist)
        } else {
            let newSetlist = Setlist(name: trimmedName, notes: trimmedNotes)
            setlistManager.createSetlist(newSetlist)
        }
        
        dismiss()
    }
}

// MARK: - Setlist Filter/Sort Sheet
struct SetlistFilterSortSheet: View {
    @ObservedObject var setlistManager: SetlistManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section("Sort By") {
                    Picker("Sort Option", selection: $setlistManager.sortBy) {
                        ForEach(SetlistManager.SortOption.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    Toggle("Ascending Order", isOn: $setlistManager.sortAscending)
                }
                
                Section {
                    Button("Clear All Filters") {
                        setlistManager.searchText = ""
                        setlistManager.sortBy = .dateModified
                        setlistManager.sortAscending = false
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
