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
                            .onMove(perform: setlistManager.moveSetlist)
                        }
                    }
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
