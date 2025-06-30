//
//  SetlistDetailView.swift
//  RoundabeatMetronome
//

import SwiftUI

// MARK: - Setlist Detail View
struct SetlistDetailView: View {
    let setlist: Setlist
    @ObservedObject var setlistManager: SetlistManager
    @ObservedObject var songManager: SongManager
    @ObservedObject var metronome: MetronomeEngine
    
    @State private var showingAddSongs = false
    @State private var showingEditSetlist = false
    @State private var showingApplyConfirmation = false
    @State private var songToApply: Song? = nil
    @State private var currentSetlist: Setlist
    
    init(setlist: Setlist, setlistManager: SetlistManager, songManager: SongManager, metronome: MetronomeEngine) {
        self.setlist = setlist
        self.setlistManager = setlistManager
        self.songManager = songManager
        self.metronome = metronome
        self._currentSetlist = State(initialValue: setlist)
    }
    
    private var songsInSetlist: [Song] {
        return setlistManager.getSongsForSetlist(currentSetlist, from: songManager)
    }
    
    var body: some View {
        Form {
            // Setlist Info Section
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(currentSetlist.name)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Button("Edit") {
                            showingEditSetlist = true
                        }
                        .foregroundColor(.accentColor)
                    }
                    
                    if !currentSetlist.notes.isEmpty {
                        Text(currentSetlist.notes)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("\(currentSetlist.songIds.count) song\(currentSetlist.songIds.count == 1 ? "" : "s")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("Modified \(formatDate(currentSetlist.dateModified))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 8)
            }
            
            // Add Songs Section
            Section {
                Button(action: {
                    showingAddSongs = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.accentColor)
                        Text("Add Songs to Setlist")
                            .foregroundColor(.accentColor)
                    }
                }
            }
            
            // Songs in Setlist Section
            if songsInSetlist.isEmpty {
                Section {
                    emptySetlistView
                }
            } else {
                Section("Songs in Setlist") {
                    ForEach(Array(songsInSetlist.enumerated()), id: \.element.id) { index, song in
                        SetlistSongRowView(
                            song: song,
                            position: index + 1,
                            isCurrentlyApplied: songManager.currentlySelectedSongId == song.id,
                            onTap: {
                                if metronome.isPlaying {
                                    songToApply = song
                                    showingApplyConfirmation = true
                                } else {
                                    songManager.applySongToMetronome(song, metronome: metronome)
                                }
                            },
                            onRemove: {
                                setlistManager.removeSongFromSetlist(songId: song.id, setlistId: currentSetlist.id)
                                refreshCurrentSetlist()
                            }
                        )
                    }
                    .onMove(perform: moveItems)
                }
            }
        }
        .navigationTitle("Setlist")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
        }
        .sheet(isPresented: $showingAddSongs) {
            AddSongsToSetlistView(
                setlist: currentSetlist,
                setlistManager: setlistManager,
                songManager: songManager
            )
        }
        .sheet(isPresented: $showingEditSetlist) {
            CreateEditSetlistView(
                setlistManager: setlistManager,
                editingSetlist: currentSetlist
            )
        }
        .alert("Apply Song Settings?", isPresented: $showingApplyConfirmation) {
            Button("Cancel", role: .cancel) {
                songToApply = nil
            }
            Button("Stop & Apply") {
                if let song = songToApply {
                    metronome.isPlaying = false
                    songManager.applySongToMetronome(song, metronome: metronome)
                }
                songToApply = nil
            }
            Button("Apply Without Stopping") {
                if let song = songToApply {
                    songManager.applySongToMetronome(song, metronome: metronome)
                }
                songToApply = nil
            }
        } message: {
            if let song = songToApply {
                Text("The metronome is currently playing. Do you want to stop it and apply \"\(song.title)\" settings, or apply the settings while continuing to play?")
            }
        }
        .onAppear {
            refreshCurrentSetlist()
        }
    }
    
    private var emptySetlistView: some View {
        VStack(spacing: 12) {
            Image(systemName: "music.note")
                .font(.system(size: 30))
                .foregroundColor(.secondary)
                .padding(.top, 16)
            
            Text("No Songs in Setlist")
                .font(.body)
                .fontWeight(.medium)
            
            Text("Add songs to this setlist to get started")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Add Songs") {
                showingAddSongs = true
            }
            .foregroundColor(.accentColor)
            .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity)
    }
    
    private func moveItems(from source: IndexSet, to destination: Int) {
        guard let sourceIndex = source.first else { return }
        setlistManager.reorderSongsInSetlist(
            setlistId: currentSetlist.id,
            from: sourceIndex,
            to: destination
        )
        refreshCurrentSetlist()
    }
    
    private func refreshCurrentSetlist() {
        if let updatedSetlist = setlistManager.setlists.first(where: { $0.id == currentSetlist.id }) {
            currentSetlist = updatedSetlist
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Setlist Song Row View
struct SetlistSongRowView: View {
    let song: Song
    let position: Int
    let isCurrentlyApplied: Bool
    let onTap: () -> Void
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Position number
            Text("\(position)")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.secondary)
                .frame(width: 24, alignment: .trailing)
            
            // Song info
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(song.title)
                        .font(.body)
                        .fontWeight(isCurrentlyApplied ? .semibold : .regular)
                        .foregroundColor(isCurrentlyApplied ? .white : .primary)
                        .lineLimit(1)
                    
                    if isCurrentlyApplied {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                    }
                }
                
                if !song.artist.isEmpty {
                    Text(song.artist)
                        .font(.caption)
                        .foregroundColor(isCurrentlyApplied ? .white.opacity(0.8) : .secondary)
                        .lineLimit(1)
                }
                
                HStack(spacing: 8) {
                    Text("\(song.bpm) BPM")
                        .font(.caption)
                        .foregroundColor(isCurrentlyApplied ? .white : .secondary)
                        .fontWeight(isCurrentlyApplied ? .medium : .regular)
                    
                    Text("•")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(song.timeSignature.numerator)/\(song.timeSignature.denominator)")
                        .font(.caption)
                        .foregroundColor(isCurrentlyApplied ? .white : .secondary)
                        .fontWeight(isCurrentlyApplied ? .medium : .regular)
                }
            }
            
            Spacer()
            
            // Apply button (only show if not currently applied)
            if !isCurrentlyApplied {
                Button(action: onTap) {
                    Text("Apply")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.accentColor)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.accentColor.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.accentColor.opacity(0.3), lineWidth: 1)
                                )
                        )
                }
                .buttonStyle(.plain)
            }
            
            // Remove button
            Button(action: onRemove) {
                Image(systemName: "minus.circle.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.red)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isCurrentlyApplied ? Color.white.opacity(0.05) : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isCurrentlyApplied ? Color.white.opacity(0.2) : Color.clear, lineWidth: 1)
        )
    }
}

// MARK: - Add Songs to Setlist View
struct AddSongsToSetlistView: View {
    let setlist: Setlist
    @ObservedObject var setlistManager: SetlistManager
    @ObservedObject var songManager: SongManager
    
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var selectedSongs: Set<UUID> = []
    
    private var availableSongs: [Song] {
        let songsNotInSetlist = songManager.songs.filter { song in
            !setlist.songIds.contains(song.id)
        }
        
        if searchText.isEmpty {
            return songsNotInSetlist
        } else {
            return songsNotInSetlist.filter { song in
                song.title.localizedCaseInsensitiveContains(searchText) ||
                song.artist.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("Search songs...", text: $searchText)
                    }
                }
                
                if availableSongs.isEmpty {
                    Section {
                        VStack(spacing: 12) {
                            Image(systemName: "music.note.list")
                                .font(.system(size: 30))
                                .foregroundColor(.secondary)
                            
                            if searchText.isEmpty {
                                Text("All songs are already in this setlist")
                                    .font(.body)
                                    .multilineTextAlignment(.center)
                            } else {
                                Text("No songs found matching '\(searchText)'")
                                    .font(.body)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                    }
                } else {
                    Section("Available Songs") {
                        ForEach(availableSongs) { song in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(song.title)
                                        .font(.body)
                                    
                                    if !song.artist.isEmpty {
                                        Text(song.artist)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    HStack(spacing: 8) {
                                        Text("\(song.bpm) BPM")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        
                                        Text("•")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        
                                        Text("\(song.timeSignature.numerator)/\(song.timeSignature.denominator)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    if selectedSongs.contains(song.id) {
                                        selectedSongs.remove(song.id)
                                    } else {
                                        selectedSongs.insert(song.id)
                                    }
                                }) {
                                    Image(systemName: selectedSongs.contains(song.id) ? "checkmark.circle.fill" : "circle")
                                        .font(.system(size: 20))
                                        .foregroundColor(selectedSongs.contains(song.id) ? .accentColor : .secondary)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add Songs")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add (\(selectedSongs.count))") {
                        addSelectedSongs()
                    }
                    .disabled(selectedSongs.isEmpty)
                }
            }
        }
    }
    
    private func addSelectedSongs() {
        for songId in selectedSongs {
            setlistManager.addSongToSetlist(songId: songId, setlistId: setlist.id)
        }
        dismiss()
    }
}
