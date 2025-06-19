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
    
    // Get screen dimensions directly
    private var screenWidth: CGFloat {
        UIScreen.main.bounds.width
    }
    
    // Check if device is iPad
    private var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search and Filter Bar
                HStack(spacing: 12) {
                    // Search field
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                            .font(.system(size: 16))
                        
                        TextField("Search songs...", text: $songManager.searchText)
                            .textFieldStyle(.plain)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                    )
                    
                    // Filter button
                    Button(action: {
                        showingFilterSheet = true
                    }) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .font(.system(size: 20))
                            .foregroundColor(.accentColor)
                    }
                    
                    // Add button
                    Button(action: {
                        showingAddSong = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.accentColor)
                    }
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.top, 8)
                .padding(.bottom, 16)
                
                // Songs List
                if songManager.filteredSongs.isEmpty {
                    emptySongsView
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(songManager.filteredSongs) { song in
                                SongRowView(
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
                        .padding(.horizontal, horizontalPadding)
                        .padding(.bottom, 100) // Space for navigation bar
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
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "music.note.list")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text("No Songs Yet")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Add songs with their BPM to quickly set your metronome tempo")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Button(action: {
                showingAddSong = true
            }) {
                HStack {
                    Image(systemName: "plus")
                    Text("Add Your First Song")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.accentColor)
                .cornerRadius(25)
            }
            
            Spacer()
        }
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
    
    // MARK: - Responsive Properties
    
    private var horizontalPadding: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 48 :
                   screenWidth <= 834 ? 60 :
                   screenWidth <= 1024 ? 72 :
                   84
        } else {
            return screenWidth <= 320 ? 12 :
                   screenWidth <= 375 ? 16 :
                   screenWidth <= 393 ? 20 :
                   24
        }
    }
}
    
    
    
    
#Preview {
    SongsView(metronome: metronome)
}
