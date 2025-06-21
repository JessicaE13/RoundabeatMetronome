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
                                onTap: {
                                    applySongToMetronome(song)
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
            .navigationTitle("Songs")
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
    
    private func applySongToMetronome(_ song: Song) {
        // Apply song settings to metronome
        metronome.bpm = song.bpm
        metronome.updateTimeSignature(numerator: song.timeSignature.numerator, denominator: song.timeSignature.denominator)
        
        // Haptic feedback
        if #available(iOS 10.0, *) {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
    }
}

// MARK: - Song Form Row View (matching SettingsView aesthetic)
struct SongFormRowView: View {
    let song: Song
    let onTap: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onToggleFavorite: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(song.title)
                        .font(.body)
                        .lineLimit(1)
                    
                    if song.isFavorite {
                        Image(systemName: "heart.fill")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
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
                    
                    if !song.artist.isEmpty {
                        Text("•")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(song.artist)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
            }
            
            Spacer()
            
            // Action buttons
            HStack(spacing: 8) {
                Button(action: onToggleFavorite) {
                    Image(systemName: song.isFavorite ? "heart.fill" : "heart")
                        .font(.caption)
                        .foregroundColor(song.isFavorite ? .red : .secondary)
                }
                .buttonStyle(.plain)
                
                Menu {
                    Button("Edit", action: onEdit)
                    Button("Delete", role: .destructive, action: onDelete)
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}

#Preview {
    SongsView(metronome: MetronomeEngine())
}
