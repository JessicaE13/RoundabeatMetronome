////
////  SongsView.swift (Fixed)
////  RoundabeatMetronome
////
//
//import SwiftUI
//
//// MARK: - Songs View (Fixed)
//struct SongsView: View {
//    @ObservedObject var metronome: MetronomeEngine
//    @ObservedObject var songManager: SongManager
//    @ObservedObject var setlistManager: SetlistManager
//    
//    @State private var showingAddSong = false
//    @State private var selectedSong: Song? = nil
//    @State private var showingEditSong = false
//    @State private var showingFilterSheet = false
//    @State private var showingApplyConfirmation = false
//    @State private var songToApply: Song? = nil
//    
//    var body: some View {
//        NavigationView {
//            Form {
//                // Search and Filter Section
//                Section {
//                    HStack {
//                        Image(systemName: "magnifyingglass")
//                            .foregroundColor(.secondary)
//                            .font(.system(size: 16))
//                        
//                        TextField("Search songs...", text: $songManager.searchText)
//                            .textFieldStyle(.plain)
//                    }
//                    .padding(.vertical, 4)
//                    
//                    HStack {
//                        Button(action: {
//                            showingFilterSheet = true
//                        }) {
//                            HStack {
//                                Image(systemName: "line.3.horizontal.decrease.circle")
//                                Text("Filter & Sort")
//                            }
//                            .foregroundColor(.accentColor)
//                        }
//                        
//                        Spacer()
//                        
//                        Button(action: {
//                            showingAddSong = true
//                        }) {
//                            HStack {
//                                Image(systemName: "plus.circle.fill")
//                                Text("Add Song")
//                            }
//                            .foregroundColor(.accentColor)
//                        }
//                    }
//                    .padding(.vertical, 4)
//                }
//                
//                // Current Metronome Settings Section
//                if let currentSong = songManager.currentlySelectedSong {
//                    Section("Currently Applied") {
//                        CurrentlyAppliedSongView(
//                            song: currentSong,
//                            metronome: metronome,
//                            onClearSelection: {
//                                songManager.clearCurrentlySelectedSong()
//                            }
//                        )
//                    }
//                }
//                
//                // Songs List Section
//                if songManager.filteredSongs.isEmpty {
//                    Section {
//                        emptySongsView
//                    }
//                } else {
//                    Section("My Songs") {
//                        ForEach(songManager.filteredSongs) { song in
//                            EnhancedSongFormRowView(
//                                song: song,
//                                isCurrentlyApplied: songManager.currentlySelectedSongId == song.id,
//                                setlistManager: setlistManager,
//                                onTap: {
//                                    if metronome.isPlaying {
//                                        songToApply = song
//                                        showingApplyConfirmation = true
//                                    } else {
//                                        songManager.applySongToMetronome(song, metronome: metronome)
//                                    }
//                                },
//                                onEdit: {
//                                    selectedSong = song
//                                    showingEditSong = true
//                                },
//                                onDelete: {
//                                    songManager.deleteSong(song)
//                                },
//                                onToggleFavorite: {
//                                    songManager.toggleFavorite(song)
//                                }
//                            )
//                        }
//                    }
//                }
//            }
//            .navigationTitle("Song Library")
//            .navigationBarTitleDisplayMode(.large)
//        }
//        .navigationViewStyle(StackNavigationViewStyle())
//        .sheet(isPresented: $showingAddSong) {
//            AddEditSongView(songManager: songManager)
//        }
//        .sheet(isPresented: $showingEditSong) {
//            if let song = selectedSong {
//                AddEditSongView(songManager: songManager, editingSong: song)
//            }
//        }
//        .sheet(isPresented: $showingFilterSheet) {
//            FilterSortSheet(songManager: songManager)
//        }
//        .alert("Apply Song Settings?", isPresented: $showingApplyConfirmation) {
//            Button("Cancel", role: .cancel) {
//                songToApply = nil
//            }
//            Button("Stop & Apply") {
//                if let song = songToApply {
//                    metronome.isPlaying = false
//                    songManager.applySongToMetronome(song, metronome: metronome)
//                }
//                songToApply = nil
//            }
//            Button("Apply Without Stopping") {
//                if let song = songToApply {
//                    songManager.applySongToMetronome(song, metronome: metronome)
//                }
//                songToApply = nil
//            }
//        } message: {
//            if let song = songToApply {
//                Text("The metronome is currently playing. Do you want to stop it and apply \"\(song.title)\" settings, or apply the settings while continuing to play?")
//            }
//        }
//    }
//    
//    private var emptySongsView: some View {
//        VStack(spacing: 16) {
//            Image(systemName: "music.note.list")
//                .font(.system(size: 40))
//                .foregroundColor(.secondary)
//                .padding(.top, 20)
//            
//            VStack(alignment: .leading, spacing: 2) {
//                Text("No Songs Yet")
//                    .font(.body)
//                Text("Add songs with their BPM to quickly set your metronome tempo")
//                    .font(.caption)
//                    .foregroundColor(.secondary)
//                    .fixedSize(horizontal: false, vertical: true)
//            }
//            
//            Button(action: {
//                showingAddSong = true
//            }) {
//                Text("Add Your First Song")
//                    .foregroundColor(.accentColor)
//            }
//            .padding(.bottom, 20)
//        }
//        .frame(maxWidth: .infinity)
//        .multilineTextAlignment(.center)
//    }
//}
//
//// MARK: - Currently Applied Song View (Unchanged)
//struct CurrentlyAppliedSongView: View {
//    let song: Song
//    @ObservedObject var metronome: MetronomeEngine
//    let onClearSelection: () -> Void
//    
//    var body: some View {
//        HStack {
//            // Music note icon
//            Image(systemName: "music.note")
//                .font(.system(size: 20, weight: .medium))
//                .foregroundColor(.white)
//                .frame(width: 30, height: 30)
//                .background(
//                    RoundedRectangle(cornerRadius: 8)
//                        .fill(Color.white.opacity(0.15))
//                )
//            
//            VStack(alignment: .leading, spacing: 2) {
//                Text(song.title)
//                    .font(.body)
//                    .fontWeight(.medium)
//                    .lineLimit(1)
//                
//                if !song.artist.isEmpty {
//                    Text(song.artist)
//                        .font(.caption)
//                        .foregroundColor(.secondary)
//                        .lineLimit(1)
//                }
//                
//                HStack(spacing: 8) {
//                    Text("\(song.bpm) BPM")
//                        .font(.caption)
//                        .foregroundColor(.white)
//                        .fontWeight(.medium)
//                    
//                    Text("•")
//                        .font(.caption)
//                        .foregroundColor(.secondary)
//                    
//                    Text("\(song.timeSignature.numerator)/\(song.timeSignature.denominator)")
//                        .font(.caption)
//                        .foregroundColor(.white)
//                        .fontWeight(.medium)
//                }
//            }
//            
//            Spacer()
//            
//            // Status indicator
//            VStack(alignment: .trailing, spacing: 4) {
//                Text("APPLIED")
//                    .font(.system(size: 10, weight: .bold))
//                    .foregroundColor(.white)
//                    .kerning(0.5)
//                
//                Button("Clear") {
//                    onClearSelection()
//                }
//                .font(.caption)
//                .foregroundColor(.secondary)
//            }
//        }
//        .padding(.vertical, 8)
//        .background(
//            RoundedRectangle(cornerRadius: 12)
//                .fill(Color.white.opacity(0.05))
//                .overlay(
//                    RoundedRectangle(cornerRadius: 12)
//                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
//                )
//        )
//        .padding(.horizontal, 4)
//    }
//}
//
//// MARK: - Enhanced Song Form Row View (Fixed)
//struct EnhancedSongFormRowView: View {
//    let song: Song
//    let isCurrentlyApplied: Bool
//    @ObservedObject var setlistManager: SetlistManager
//    let onTap: () -> Void
//    let onEdit: () -> Void
//    let onDelete: () -> Void
//    let onToggleFavorite: () -> Void
//    
//    @State private var showingSetlistPicker = false
//    
//    var body: some View {
//        HStack {
//            // Heart icon on the left
//            Button {
//                onToggleFavorite()
//            } label: {
//                Image(systemName: song.isFavorite ? "heart.fill" : "heart")
//                    .font(.system(size: 16, weight: .medium))
//                    .foregroundColor(song.isFavorite ? .red : .secondary)
//                    .frame(width: 20, height: 20)
//            }
//            .buttonStyle(.plain)
//            
//            Spacer()
//                .frame(width: 22)
//            
//            VStack(alignment: .leading) {
//                // Song title with applied indicator and setlist badge
//                HStack {
//                    Text(song.title)
//                        .font(.body)
//                        .fontWeight(isCurrentlyApplied ? .semibold : .regular)
//                        .foregroundColor(isCurrentlyApplied ? .white : .primary)
//                        .lineLimit(1)
//                    
//                    if isCurrentlyApplied {
//                        Image(systemName: "checkmark.circle.fill")
//                            .font(.system(size: 12))
//                            .foregroundColor(.white)
//                    }
//                    
//                    // Setlist badge
//                    SongSetlistBadgeView(
//                        song: song,
//                        setlistManager: setlistManager
//                    )
//                }
//                
//                // Artist name (if available)
//                if !song.artist.isEmpty {
//                    Text(song.artist)
//                        .font(.caption)
//                        .foregroundColor(isCurrentlyApplied ? .white.opacity(0.8) : .secondary)
//                        .lineLimit(1)
//                }
//                
//                // BPM and time signature
//                HStack(spacing: 8) {
//                    Text("\(song.bpm) BPM")
//                        .font(.caption)
//                        .foregroundColor(isCurrentlyApplied ? .white : .secondary)
//                        .fontWeight(isCurrentlyApplied ? .medium : .regular)
//                    
//                    Text("•")
//                        .font(.caption)
//                        .foregroundColor(.secondary)
//                    
//                    Text("\(song.timeSignature.numerator)/\(song.timeSignature.denominator)")
//                        .font(.caption)
//                        .foregroundColor(isCurrentlyApplied ? .white : .secondary)
//                        .fontWeight(isCurrentlyApplied ? .medium : .regular)
//                }
//            }
//            
//            Spacer()
//            
//            // Action buttons
//            HStack(spacing: 12) {
//                // Apply button (only show if not currently applied)
//                if !isCurrentlyApplied {
//                    Button {
//                        onTap()
//                    } label: {
//                        Text("Apply")
//                            .font(.caption)
//                            .fontWeight(.medium)
//                            .foregroundColor(.accentColor)
//                            .padding(.horizontal, 12)
//                            .padding(.vertical, 6)
//                            .background(
//                                RoundedRectangle(cornerRadius: 8)
//                                    .fill(Color.accentColor.opacity(0.1))
//                                    .overlay(
//                                        RoundedRectangle(cornerRadius: 8)
//                                            .stroke(Color.accentColor.opacity(0.3), lineWidth: 1)
//                                    )
//                            )
//                    }
//                    .buttonStyle(.plain)
//                }
//                
//                // Enhanced menu with setlist options
//                Menu {
//                    Button {
//                        showingSetlistPicker = true
//                    } label: {
//                        HStack {
//                            Image(systemName: "music.note.list")
//                            Text("Add to Setlists")
//                        }
//                    }
//                    
//                    Button {
//                        onToggleFavorite()
//                    } label: {
//                        HStack {
//                            Image(systemName: song.isFavorite ? "heart.slash" : "heart")
//                            Text(song.isFavorite ? "Remove from Favorites" : "Add to Favorites")
//                        }
//                    }
//                    
//                    Button {
//                        onEdit()
//                    } label: {
//                        HStack {
//                            Image(systemName: "pencil")
//                            Text("Edit Song")
//                        }
//                    }
//                    
//                    Button(role: .destructive) {
//                        onDelete()
//                    } label: {
//                        HStack {
//                            Image(systemName: "trash")
//                            Text("Delete Song")
//                        }
//                    }
//                } label: {
//                    Image(systemName: "ellipsis.circle")
//                        .font(.body)
//                        .foregroundColor(.secondary)
//                }
//                .buttonStyle(.plain)
//            }
//        }
//        .padding(.vertical, 4)
//        .background(
//            RoundedRectangle(cornerRadius: 12)
//                .fill(isCurrentlyApplied ? Color.white.opacity(0.05) : Color.clear)
//        )
//        .overlay(
//            RoundedRectangle(cornerRadius: 12)
//                .stroke(isCurrentlyApplied ? Color.white.opacity(0.2) : Color.clear, lineWidth: 1)
//        )
//        .sheet(isPresented: $showingSetlistPicker) {
//            SongSetlistPickerView(
//                song: song,
//                setlistManager: setlistManager
//            )
//        }
//    }
//}
//
//#Preview {
//    let metronome = MetronomeEngine()
//    let songManager = SongManager()
//    let setlistManager = SetlistManager()
//    return SongsView(
//        metronome: metronome,
//        songManager: songManager,
//        setlistManager: setlistManager
//    )
//}
