//
//  SongSetlistComponents.swift
//  RoundabeatMetronome
//

import SwiftUI

// MARK: - Song Setlist Picker (for adding songs to setlists)
struct SongSetlistPickerView: View {
    let song: Song
    @ObservedObject var setlistManager: SetlistManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedSetlists: Set<UUID> = []
    @State private var showingCreateSetlist = false
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Adding to Setlists:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Image(systemName: "music.note")
                                .foregroundColor(.accentColor)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(song.title)
                                    .font(.body)
                                    .fontWeight(.medium)
                                
                                if !song.artist.isEmpty {
                                    Text(song.artist)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                Section {
                    Button(action: {
                        showingCreateSetlist = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.accentColor)
                            Text("Create New Setlist")
                                .foregroundColor(.accentColor)
                        }
                    }
                }
                
                if setlistManager.setlists.isEmpty {
                    Section {
                        VStack(spacing: 12) {
                            Image(systemName: "music.note.list")
                                .font(.system(size: 30))
                                .foregroundColor(.secondary)
                            
                            Text("No Setlists Yet")
                                .font(.body)
                                .fontWeight(.medium)
                            
                            Text("Create your first setlist to organize your songs")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                    }
                } else {
                    Section("Your Setlists") {
                        ForEach(setlistManager.setlists) { setlist in
                            SetlistSelectionRow(
                                setlist: setlist,
                                song: song,
                                isSelected: selectedSetlists.contains(setlist.id),
                                onToggle: {
                                    if selectedSetlists.contains(setlist.id) {
                                        selectedSetlists.remove(setlist.id)
                                    } else {
                                        selectedSetlists.insert(setlist.id)
                                    }
                                }
                            )
                        }
                    }
                }
            }
            .navigationTitle("Add to Setlists")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        addToSelectedSetlists()
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingCreateSetlist) {
            CreateEditSetlistView(
                setlistManager: setlistManager,
                editingSetlist: nil
            )
        }
        .onAppear {
            // Pre-select setlists that already contain this song
            selectedSetlists = Set(setlistManager.getSetlistsContainingSong(song.id).map { $0.id })
        }
    }
    
    private func addToSelectedSetlists() {
        let currentSetlists = Set(setlistManager.getSetlistsContainingSong(song.id).map { $0.id })
        
        // Add to newly selected setlists
        for setlistId in selectedSetlists {
            if !currentSetlists.contains(setlistId) {
                setlistManager.addSongToSetlist(songId: song.id, setlistId: setlistId)
            }
        }
        
        // Remove from unselected setlists
        for setlistId in currentSetlists {
            if !selectedSetlists.contains(setlistId) {
                setlistManager.removeSongFromSetlist(songId: song.id, setlistId: setlistId)
            }
        }
    }
}

// MARK: - Setlist Selection Row
struct SetlistSelectionRow: View {
    let setlist: Setlist
    let song: Song
    let isSelected: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(setlist.name)
                        .font(.body)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack {
                        Text("\(setlist.songIds.count) song\(setlist.songIds.count == 1 ? "" : "s")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if !setlist.notes.isEmpty {
                            Text("•")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text(setlist.notes)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? .accentColor : .secondary)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Song Setlist Badge View (shows which setlists contain a song)
struct SongSetlistBadgeView: View {
    let song: Song
    @ObservedObject var setlistManager: SetlistManager
    
    private var setlistsContainingSong: [Setlist] {
        setlistManager.getSetlistsContainingSong(song.id)
    }
    
    var body: some View {
        if !setlistsContainingSong.isEmpty {
            Menu {
                ForEach(setlistsContainingSong) { setlist in
                    // Fixed: Use Button instead of Label to avoid conformance issues
                    Button(action: {
                        // Optional: Add navigation to setlist if needed
                    }) {
                        HStack {
                            Image(systemName: "music.note.list")
                            Text(setlist.name)
                        }
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "music.note.list")
                        .font(.system(size: 10))
                    Text("\(setlistsContainingSong.count)")
                        .font(.system(size: 10, weight: .medium))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.accentColor)
                )
            }
        }
    }
}
