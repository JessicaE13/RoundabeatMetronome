//
//  SongsView.swift (Fixed)
//  RoundabeatMetronome
//

import SwiftUI

// MARK: - Sort Options
enum SongsSortOption: String, CaseIterable {
    case none = "none"
    case aToZ = "A-Z"
    case zToA = "Z-A"
    
    var iconName: String {
        switch self {
        case .none:
            return "arrow.up.arrow.down"
        case .aToZ:
            return "arrow.up"
        case .zToA:
            return "arrow.down"
        }
    }
    
    var nextOption: SongsSortOption {
        switch self {
        case .none:
            return .aToZ
        case .aToZ:
            return .zToA
        case .zToA:
            return .none
        }
    }
}

// MARK: - Songs View (Fixed)
struct SongsView: View {
    @ObservedObject var metronome: MetronomeEngine
    @ObservedObject var songManager: SongManager
    @ObservedObject var setlistManager: SetlistManager
    
    @State private var showingAddSong = false
    @State private var selectedSong: Song? = nil
    @State private var showingEditSong = false
    @State private var showingApplyConfirmation = false
    @State private var songToApply: Song? = nil
    @State private var sortOption: SongsSortOption = .none
    
    var sortedSongs: [Song] {
        let filtered = songManager.filteredSongs
        switch sortOption {
        case .none:
            return filtered
        case .aToZ:
            return filtered.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        case .zToA:
            return filtered.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedDescending }
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Search and Actions Section
                Section {
                    HStack {
                        // Search field
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.secondary)
                                .font(.system(size: 16))
                            
                            TextField("Search songs...", text: $songManager.searchText)
                                .textFieldStyle(.plain)
                        }
                        
                        // Sort button on the right
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                sortOption = sortOption.nextOption
                            }
                        }) {
                            Image(systemName: sortOption.iconName)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(sortOption == .none ? .secondary : .white)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.vertical, 4)
                    
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            showingAddSong = true
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Add Song")
                            }
                            .foregroundColor(.accentColor)
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                // Current Metronome Settings Section
                if let currentSong = songManager.currentlySelectedSong {
                    Section("Currently Applied") {
                        SongsCurrentlyAppliedSongView(
                            song: currentSong,
                            metronome: metronome,
                            onClearSelection: {
                                songManager.clearCurrentlySelectedSong()
                            }
                        )
                    }
                }
                
                // Songs List Section
                if sortedSongs.isEmpty {
                    Section {
                        emptySongsView
                    }
                } else {
                    Section("My Songs") {
                        ForEach(sortedSongs) { song in
                            SongsEnhancedSongFormRowView(
                                song: song,
                                isCurrentlyApplied: songManager.currentlySelectedSongId == song.id,
                                setlistManager: setlistManager,
                                onTap: {
                                    if metronome.isPlaying {
                                        songToApply = song
                                        showingApplyConfirmation = true
                                    } else {
                                        songManager.applySongToMetronome(song, metronome: metronome)
                                    }
                                },
                                onEdit: {
                                    selectedSong = song
                                    showingEditSong = true
                                },
                                onDelete: {
                                    songManager.deleteSong(song)
                                },
                                onToggleFavorite: {
                                    songManager.toggleFavorite(song)
                                }
                            )
                        }
                    }
                }
            }
            .navigationTitle("Song Library")
            .navigationBarTitleDisplayMode(.large)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $showingAddSong) {
            AddEditSongView(songManager: songManager)
        }
        .sheet(isPresented: $showingEditSong) {
            if let song = selectedSong {
                AddEditSongView(songManager: songManager, editingSong: song)
            }
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
    }
    
    private var emptySongsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "music.note.list")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
                .padding(.top, 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("No Songs Yet")
                    .font(.body)
                Text("Add songs with their BPM to quickly set your metronome tempo")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Button(action: {
                showingAddSong = true
            }) {
                Text("Add Your First Song")
                    .foregroundColor(.accentColor)
            }
            .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity)
        .multilineTextAlignment(.center)
    }
}

// MARK: - Currently Applied Song View
struct SongsCurrentlyAppliedSongView: View {
    let song: Song
    @ObservedObject var metronome: MetronomeEngine
    let onClearSelection: () -> Void
    
    var body: some View {
        HStack {
            // Music note icon
            Image(systemName: "music.note")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 30, height: 30)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.15))
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(song.title)
                    .font(.body)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    // Artist name first (if available)
                    if !song.artist.isEmpty {
                        Text(song.artist)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                        
                        Text("•")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
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
            
            // Status indicator
            Button(action: {
                metronome.isPlaying.toggle()
            }) {
                Image(systemName: metronome.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.accentColor)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 12)
    }
}

// MARK: - Enhanced Song Form Row View
struct SongsEnhancedSongFormRowView: View {
    let song: Song
    let isCurrentlyApplied: Bool
    @ObservedObject var setlistManager: SetlistManager
    let onTap: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onToggleFavorite: () -> Void
    
    @State private var showingSetlistPicker = false
    
    var body: some View {
        HStack {
            // Heart icon on the left
            Button {
                onToggleFavorite()
            } label: {
                Image(systemName: song.isFavorite ? "heart.fill" : "heart")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(song.isFavorite ? .red : .secondary)
                    .frame(width: 20, height: 20)
            }
            .buttonStyle(.plain)
            
            Spacer()
                .frame(width: 22)
            
            VStack(alignment: .leading) {
                // Song title with setlist badge
                HStack {
                    Text(song.title)
                        .font(.body)
                        .foregroundColor(isCurrentlyApplied ? .white : .primary)
                        .brightness(isCurrentlyApplied ? 0.3 : -0.3) // Brighter for selected, much duller for unselected
                        .lineLimit(1)
                    
                    // Setlist badge with improved contrast
                    SongsFixedSongSetlistBadgeView(
                        song: song,
                        setlistManager: setlistManager
                    )
                }
                
                // Artist, BPM, and time signature on same line
                HStack(spacing: 8) {
                    // Artist name first (if available)
                    if !song.artist.isEmpty {
                        Text(song.artist)
                            .font(.caption)
                            .foregroundColor(isCurrentlyApplied ? .white.opacity(0.8) : .secondary)
                            .brightness(isCurrentlyApplied ? 0.3 : -0.3) // Brighter for selected, much duller for unselected
                            .lineLimit(1)
                        
                        Text("•")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Text("\(song.bpm) BPM")
                        .font(.caption)
                        .foregroundColor(isCurrentlyApplied ? .white : .secondary)
                        .brightness(isCurrentlyApplied ? 0.3 : -0.3) // Brighter for selected, much duller for unselected
                    
                    Text("•")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(song.timeSignature.numerator)/\(song.timeSignature.denominator)")
                        .font(.caption)
                        .foregroundColor(isCurrentlyApplied ? .white : .secondary)
                        .brightness(isCurrentlyApplied ? 0.3 : -0.3) // Brighter for selected, much duller for unselected
                }
            }
            
            Spacer()
            
            // Action buttons - Only show menu button, no apply button
            HStack(spacing: 12) {
                // Enhanced menu with setlist options
                Menu {
                    Button {
                        showingSetlistPicker = true
                    } label: {
                        HStack {
                            Image(systemName: "music.note.list")
                            Text("Add to Setlists")
                        }
                    }
                    
                    Button {
                        onToggleFavorite()
                    } label: {
                        HStack {
                            Image(systemName: song.isFavorite ? "heart.slash" : "heart")
                            Text(song.isFavorite ? "Remove from Favorites" : "Add to Favorites")
                        }
                    }
                    
                    Button {
                        onEdit()
                    } label: {
                        HStack {
                            Image(systemName: "pencil")
                            Text("Edit Song")
                        }
                    }
                    
                    Button(role: .destructive) {
                        onDelete()
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                            Text("Delete Song")
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .contentShape(Rectangle()) // Makes the entire row tappable
        .onTapGesture {
            onTap() // Apply song when tapping anywhere on the row
        }
        .padding(.vertical, 8) // Add padding to make rows taller
        .sheet(isPresented: $showingSetlistPicker) {
            SongSetlistPickerView(
                song: song,
                setlistManager: setlistManager
            )
        }
    }
}

// MARK: - Fixed Song Setlist Badge View with better contrast
struct SongsFixedSongSetlistBadgeView: View {
    let song: Song
    @ObservedObject var setlistManager: SetlistManager
    
    private var setlistsContainingSong: [Setlist] {
        setlistManager.getSetlistsContainingSong(song.id)
    }
    
    var body: some View {
        if !setlistsContainingSong.isEmpty {
            Menu {
                ForEach(setlistsContainingSong) { setlist in
                    Button(action: {
                        // Optional: Add navigation to setlist if needed
                    }) {
                        HStack {
                            Image(systemName: "list.bullet.rectangle")
                            Text(setlist.name)
                        }
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "list.bullet.rectangle")
                        .font(.system(size: 10))
                    Text("\(setlistsContainingSong.count)")
                        .font(.system(size: 10, weight: .medium))
                }
                .foregroundColor(.black)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white)
                )
            }
        }
    }
}

#Preview {
    let metronome = MetronomeEngine()
    let songManager = SongManager()
    let setlistManager = SetlistManager()
    return SongsView(
        metronome: metronome,
        songManager: songManager,
        setlistManager: setlistManager
    )
}
