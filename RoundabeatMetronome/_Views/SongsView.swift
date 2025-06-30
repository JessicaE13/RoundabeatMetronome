//
//  SongsView.swift
//  RoundabeatMetronome
//
//  Created by Jessica Estes on 6/19/25.
//

import SwiftUI

// MARK: - Songs View
struct SongsView: View {
    @ObservedObject var metronome: MetronomeEngine
    @StateObject private var songManager = SongManager()
    @State private var showingAddSong = false
    @State private var selectedSong: Song? = nil
    @State private var showingEditSong = false
    @State private var showingFilterSheet = false
    @State private var currentlySelectedSongId: UUID? = nil
    @State private var showingApplyConfirmation = false
    @State private var songToApply: Song? = nil
    
    var body: some View {
        NavigationView {
            Form {
                // Search and Filter Section
                Section {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                            .font(.system(size: 16))
                        
                        TextField("Search songs...", text: $songManager.searchText)
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
                if let currentSong = currentlyAppliedSong {
                    Section("Currently Applied") {
                        CurrentlyAppliedSongView(
                            song: currentSong,
                            metronome: metronome,
                            onClearSelection: {
                                currentlySelectedSongId = nil
                            }
                        )
                    }
                }
                
                // Songs List Section
                if songManager.filteredSongs.isEmpty {
                    Section {
                        emptySongsView
                    }
                } else {
                    Section("My Songs") {
                        ForEach(songManager.filteredSongs) { song in
                            SongFormRowView(
                                song: song,
                                isCurrentlyApplied: currentlySelectedSongId == song.id,
                                onTap: {
                                    if metronome.isPlaying {
                                        // If metronome is playing, show confirmation dialog
                                        songToApply = song
                                        showingApplyConfirmation = true
                                    } else {
                                        // Apply immediately if metronome is not playing
                                        applySongToMetronome(song)
                                    }
                                },
                                onEdit: {
                                    selectedSong = song
                                    showingEditSong = true
                                },
                                onDelete: {
                                    // If deleting the currently applied song, clear the selection
                                    if currentlySelectedSongId == song.id {
                                        currentlySelectedSongId = nil
                                    }
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
        .sheet(isPresented: $showingFilterSheet) {
            FilterSortSheet(songManager: songManager)
        }
        .alert("Apply Song Settings?", isPresented: $showingApplyConfirmation) {
            Button("Cancel", role: .cancel) {
                songToApply = nil
            }
            Button("Stop & Apply") {
                if let song = songToApply {
                    metronome.isPlaying = false
                    applySongToMetronome(song)
                }
                songToApply = nil
            }
            Button("Apply Without Stopping") {
                if let song = songToApply {
                    applySongToMetronome(song)
                }
                songToApply = nil
            }
        } message: {
            if let song = songToApply {
                Text("The metronome is currently playing. Do you want to stop it and apply \"\(song.title)\" settings, or apply the settings while continuing to play?")
            }
        }
        .onAppear {
            if songManager.songs.isEmpty {
                songManager.addSampleSongs()
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
    
    // Find the currently applied song based on matching BPM and time signature
    private var currentlyAppliedSong: Song? {
        if let songId = currentlySelectedSongId {
            return songManager.songs.first { $0.id == songId }
        }
        return nil
    }
    
    private func applySongToMetronome(_ song: Song) {
        // Store the currently selected song ID
        currentlySelectedSongId = song.id
        
        // Apply song settings to metronome
        metronome.bpm = song.bpm
        metronome.updateTimeSignature(numerator: song.timeSignature.numerator, denominator: song.timeSignature.denominator)
        
        // Haptic feedback
        if #available(iOS 10.0, *) {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
        
        // Show brief success feedback
        withAnimation(.easeInOut(duration: 0.2)) {
            // Could add a success indicator here if desired
        }
    }
}

// MARK: - Currently Applied Song View
struct CurrentlyAppliedSongView: View {
    let song: Song
    @ObservedObject var metronome: MetronomeEngine
    let onClearSelection: () -> Void
    
    var body: some View {
        HStack {
            // Music note icon
            Image(systemName: "music.note")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.green)
                .frame(width: 30, height: 30)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.green.opacity(0.15))
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(song.title)
                    .font(.body)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                if !song.artist.isEmpty {
                    Text(song.artist)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                HStack(spacing: 8) {
                    Text("\(song.bpm) BPM")
                        .font(.caption)
                        .foregroundColor(.green)
                        .fontWeight(.medium)
                    
                    Text("•")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(song.timeSignature.numerator)/\(song.timeSignature.denominator)")
                        .font(.caption)
                        .foregroundColor(.green)
                        .fontWeight(.medium)
                }
            }
            
            Spacer()
            
            // Status indicator
            VStack(alignment: .trailing, spacing: 4) {
                Text("APPLIED")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.green)
                    .kerning(0.5)
                
                Button("Clear") {
                    onClearSelection()
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.green.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.green.opacity(0.2), lineWidth: 1)
                )
        )
        .padding(.horizontal, 4)
    }
}

// MARK: - Enhanced Song Form Row View
struct SongFormRowView: View {
    let song: Song
    let isCurrentlyApplied: Bool
    let onTap: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onToggleFavorite: () -> Void
    
    var body: some View {
        HStack {
            // Heart icon on the left with equal padding
            Button(action: onToggleFavorite) {
                Image(systemName: song.isFavorite ? "heart.fill" : "heart")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(song.isFavorite ? .red : .secondary)
                    .frame(width: 20, height: 20)
            }
            .buttonStyle(.plain)
            
            Spacer()
                .frame(width: 22)
            
            VStack(alignment: .leading) {
                // Song title with applied indicator
                HStack {
                    Text(song.title)
                        .font(.body)
                        .fontWeight(isCurrentlyApplied ? .semibold : .regular)
                        .foregroundColor(isCurrentlyApplied ? .green : .primary)
                        .lineLimit(1)
                    
                    if isCurrentlyApplied {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.green)
                    }
                }
                
                // Artist name first (if available)
                if !song.artist.isEmpty {
                    Text(song.artist)
                        .font(.caption)
                        .foregroundColor(isCurrentlyApplied ? .green.opacity(0.8) : .secondary)
                        .lineLimit(1)
                }
                
                // BPM and time signature
                HStack(spacing: 8) {
                    Text("\(song.bpm) BPM")
                        .font(.caption)
                        .foregroundColor(isCurrentlyApplied ? .green : .secondary)
                        .fontWeight(isCurrentlyApplied ? .medium : .regular)
                    
                    Text("•")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(song.timeSignature.numerator)/\(song.timeSignature.denominator)")
                        .font(.caption)
                        .foregroundColor(isCurrentlyApplied ? .green : .secondary)
                        .fontWeight(isCurrentlyApplied ? .medium : .regular)
                }
            }
            
            Spacer()
            
            // Action buttons
            HStack(spacing: 12) {
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
                
                Menu {
                    Button("Edit", action: onEdit)
                    Button("Delete", role: .destructive, action: onDelete)
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isCurrentlyApplied ? Color.green.opacity(0.05) : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isCurrentlyApplied ? Color.green.opacity(0.2) : Color.clear, lineWidth: 1)
        )
    }
}

#Preview {
    SongsView(metronome: MetronomeEngine())
}
