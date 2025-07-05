//
//  LibraryView.swift
//  RoundabeatMetronome
//

import SwiftUI

// MARK: - Sort Options
enum LibrarySortOption: String, CaseIterable {
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
    
    var nextOption: LibrarySortOption {
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

// MARK: - Library Tab Types (Updated with Sounds First)
enum LibraryTab: String, CaseIterable {
    case sounds = "Sounds"
    case songs = "Songs"
    case setlists = "Setlists"
    
    var iconName: String {
        switch self {
        case .sounds:
            return "speaker.wave.3"
        case .songs:
            return "music.note.list"
        case .setlists:
            return "list.bullet.rectangle"
        }
    }
}

// MARK: - Main Library View (Updated)
struct LibraryView: View {
    @ObservedObject var metronome: MetronomeEngine
    @ObservedObject var songManager: SongManager
    @ObservedObject var setlistManager: SetlistManager
    
    @State private var selectedTab: LibraryTab = .sounds // Changed default to sounds
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Segmented Picker Tab Bar (Updated for new order)
                segmentedPickerTabBar
                
                // Content based on selected tab (Updated order)
                Group {
                    switch selectedTab {
                    case .sounds:
                        SoundsTabView(metronome: metronome)
                    case .songs:
                        SongsTabView(
                            metronome: metronome,
                            songManager: songManager,
                            setlistManager: setlistManager
                        )
                    case .setlists:
                        SetlistsTabView(
                            setlistManager: setlistManager,
                            songManager: songManager,
                            metronome: metronome
                        )
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .navigationTitle("Library")
            .navigationBarTitleDisplayMode(.large)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private var segmentedPickerTabBar: some View {
        VStack(spacing: 0) {
            // Segmented Control with custom styling (Updated for new order)
            HStack {
                Spacer()
                
                HStack(spacing: 0) {
                    ForEach(LibraryTab.allCases, id: \.self) { tab in
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                selectedTab = tab
                            }
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: tab.iconName)
                                    .font(.system(size: 14, weight: .medium))
                                Text(tab.rawValue)
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .foregroundColor(selectedTab == tab ? .primary : .secondary)
                            .padding(.horizontal, 16) // Reduced padding for 3 tabs
                            .padding(.vertical, 8)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .background(
                    // Sliding background - now handles new order (Sounds, Songs, Setlists)
                    GeometryReader { geometry in
                        HStack {
                            if selectedTab == .songs {
                                Spacer()
                            } else if selectedTab == .setlists {
                                Spacer()
                                Spacer()
                            }
                            
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color(.systemGray6))
                                .frame(width: geometry.size.width / 3 - 4) // Third width minus padding
                            
                            if selectedTab == .sounds {
                                Spacer()
                                Spacer()
                            } else if selectedTab == .songs {
                                Spacer()
                            }
                        }
                        .padding(2)
                    }
                    .animation(.easeInOut(duration: 0.3), value: selectedTab)
                )
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.clear)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.systemGray3), lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 8))
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            
            // Bottom border/divider
            Divider()
                .background(Color.white.opacity(0.2))
        }
        .background(
            Color(.systemBackground)
                .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
        )
    }
}

// MARK: - Songs Tab View (Unchanged)
struct SongsTabView: View {
    @ObservedObject var metronome: MetronomeEngine
    @ObservedObject var songManager: SongManager
    @ObservedObject var setlistManager: SetlistManager
    
    @State private var showingAddSong = false
    @State private var selectedSong: Song? = nil
    @State private var showingEditSong = false
    @State private var showingApplyConfirmation = false
    @State private var songToApply: Song? = nil
    @State private var sortOption: LibrarySortOption = .none
    
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
        VStack(spacing: 0) {
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
                
                // Songs List Section
                if sortedSongs.isEmpty {
                    Section {
                        emptySongsView
                    }
                } else {
                    Section("My Songs") {
                        ForEach(sortedSongs) { song in
                            LibraryEnhancedSongFormRowView(
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
                            .listRowBackground(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(songManager.currentlySelectedSongId == song.id ? Color(.systemGray6) : Color.clear)
                                    .padding(.vertical, 2)
                            )
                            .listRowSeparator(.hidden) // Hide separator lines
                        }
                    }
                }
            }
            
            // Fixed "Currently Applied" section at bottom - Always visible
            if let currentSong = songManager.currentlySelectedSong {
                VStack(spacing: 0) {
                    Divider()
                        .background(Color.white.opacity(0.2))
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Currently Applied")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        LibraryCurrentlyAppliedSongView(
                            song: currentSong,
                            metronome: metronome,
                            onClearSelection: {
                                songManager.clearCurrentlySelectedSong()
                            }
                        )
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(.systemBackground))
                }
            }
        }
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

// MARK: - Setlists Tab View (Unchanged)
struct SetlistsTabView: View {
    @ObservedObject var setlistManager: SetlistManager
    @ObservedObject var songManager: SongManager
    @ObservedObject var metronome: MetronomeEngine
    
    @State private var showingCreateSetlist = false
    @State private var selectedSetlist: Setlist? = nil
    @State private var showingEditSetlist = false
    @State private var sortOption: LibrarySortOption = .none
    
    var sortedSetlists: [Setlist] {
        let filtered = setlistManager.filteredSetlists
        switch sortOption {
        case .none:
            return filtered
        case .aToZ:
            return filtered.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .zToA:
            return filtered.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedDescending }
        }
    }
    
    var body: some View {
        Form {
            // Search and Actions Section
            Section {
                HStack {
                    // Search field
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                            .font(.system(size: 16))
                        
                        TextField("Search setlists...", text: $setlistManager.searchText)
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
            if sortedSetlists.isEmpty {
                Section {
                    emptySetlistsView
                }
            } else {
                Section("My Setlists") {
                    ForEach(sortedSetlists) { setlist in
                        NavigationLink(destination: SetlistDetailView(
                            setlist: setlist,
                            setlistManager: setlistManager,
                            songManager: songManager,
                            metronome: metronome
                        )) {
                            LibrarySetlistRowView(
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
                        .listRowSeparator(.hidden) // Hide separator lines
                    }
                    .onMove(perform: setlistManager.moveSetlist)
                }
            }
        }
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

// MARK: - Sounds Tab View (Wrapper for SoundsView)
struct SoundsTabView: View {
    @ObservedObject var metronome: MetronomeEngine
    
    var body: some View {
        // Use the existing SoundsView but remove the title since we're in a tab
        SoundsViewForLibrary(metronome: metronome)
    }
}

// MARK: - Modified SoundsView for Library (without title)
struct SoundsViewForLibrary: View {
    @ObservedObject var metronome: MetronomeEngine
    @State private var isPreviewPlaying = false
    
    // Get screen dimensions directly
    private var screenWidth: CGFloat {
        UIScreen.main.bounds.width
    }
    
    private var screenHeight: CGFloat {
        UIScreen.main.bounds.height
    }
    
    // Check if device is iPad
    private var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Current Sound Section
                VStack(alignment: .leading, spacing: settingsSectionSpacing) {
                    Text("Current Sound")
                        .font(.system(size: sectionHeaderFontSize, weight: .bold))
                        .padding(.bottom, settingsItemSpacing)
                    
                    currentSoundCard
                }
                .padding(.top, sectionPadding)
                .padding(.bottom, sectionSpacing)
                
                Divider()
                    .padding(.bottom, sectionSpacing)
                
                // Available Sounds Section
                VStack(alignment: .leading, spacing: settingsSectionSpacing) {
                    Text("Available Sounds")
                        .font(.system(size: sectionHeaderFontSize, weight: .bold))
                        .padding(.bottom, settingsItemSpacing)
                    
                    LazyVStack(spacing: soundItemSpacing) {
                        ForEach(SyntheticSound.allCases, id: \.self) { sound in
                            soundRowView(sound: sound)
                        }
                    }
                }
                
                // Add extra padding at the bottom
                Spacer()
                    .frame(height: isIPad ? 100 : 80)
            }
            .padding(.horizontal, horizontalPadding)
        }
    }
    
    private var currentSoundCard: some View {
        HStack(spacing: 16) {
            // Sound icon
            Image(systemName: soundIcon(for: metronome.selectedSoundType))
                .font(.system(size: isIPad ? 32 : 28, weight: .medium))
                .foregroundColor(.accentColor)
                .frame(width: isIPad ? 50 : 44, height: isIPad ? 50 : 44)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.accentColor.opacity(0.1))
                )
            
            // Sound info
            VStack(alignment: .leading, spacing: 4) {
                Text(metronome.selectedSoundType.rawValue)
                    .font(.system(size: currentSoundTitleSize, weight: .semibold))
                    .foregroundColor(.primary)
                
                
                HStack {
                    Text(metronome.selectedSoundType.description)
                        .font(.system(size: currentSoundDescSize))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                // Preview button
                Button(action: {
                    playPreview(metronome.selectedSoundType)
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: isPreviewPlaying ? "waveform" : "play.fill")
                            .font(.system(size: previewButtonIconSize, weight: .medium))
                        
                        Text(isPreviewPlaying ? "PLAYING" : "PREVIEW")
                            .font(.system(size: previewButtonTextSize, weight: .medium))
                            .kerning(0.5)
                    }
                    .foregroundColor(isPreviewPlaying ? .green : .accentColor)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(isPreviewPlaying ? Color.green.opacity(0.1) : Color.accentColor.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(isPreviewPlaying ? Color.green.opacity(0.3) : Color.accentColor.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
                .disabled(isPreviewPlaying)
                    
                }
            }
        }
        .padding(cardPadding)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.accentColor.opacity(0.2), lineWidth: 1.5)
                )
        )
    }
    


    private func soundRowView(sound: SyntheticSound) -> some View {
        let isSelected = sound == metronome.selectedSoundType
        
        return Button(action: {
            if #available(iOS 10.0, *) {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            }
            
            // Update the selected sound
            metronome.updateSoundType(to: sound)
            
            // Only play preview if metronome is NOT playing
            if !metronome.isPlaying {
                playPreview(sound)
            }
        }) {
            HStack(spacing: 16) {
                // Sound icon
                Image(systemName: soundIcon(for: sound))
                    .font(.system(size: soundIconSize, weight: .medium))
                    .foregroundColor(isSelected ? .white : .accentColor)
                    .frame(width: soundIconFrameSize, height: soundIconFrameSize)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(isSelected ? Color.accentColor : Color.accentColor.opacity(0.1))
                    )
                
                // Sound info
                VStack(alignment: .leading, spacing: 4) {
                    Text(sound.rawValue)
                        .font(.system(size: soundTitleSize, weight: .medium))
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(sound.description)
                        .font(.system(size: soundDescSize))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Spacer()
                
                HStack(spacing: 8) {
                    // Preview button - only show if not selected AND metronome is not playing
                    if !isSelected && !metronome.isPlaying {
                        Button(action: {
                            playPreview(sound)
                        }) {
                            Image(systemName: "play.circle")
                                .font(.system(size: actionButtonSize, weight: .medium))
                                .foregroundColor(.accentColor)
                        }
                        .disabled(isPreviewPlaying)
                    }
                    
                    // Show a different icon when metronome is playing to indicate preview is disabled
                    if !isSelected && metronome.isPlaying {
                        Image(systemName: "speaker.slash.circle")
                            .font(.system(size: actionButtonSize, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: actionButtonSize, weight: .medium))
                            .foregroundColor(.accentColor)
                    }
                }
            }
            .padding(soundRowPadding)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6).opacity(isSelected ? 1.0 : 0.5))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isSelected ? Color.accentColor.opacity(0.3) : Color.clear,
                                lineWidth: 1
                            )
                    )
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Helper Methods
    
    private func playPreview(_ sound: SyntheticSound) {
        guard !isPreviewPlaying else { return }
        
        isPreviewPlaying = true
        metronome.playSoundPreviewAdvanced(sound)
        
        // Reset preview state after a reasonable duration
        let previewDuration = sound == .snap ? 0.25 : 0.25
        DispatchQueue.main.asyncAfter(deadline: .now() + previewDuration) {
            isPreviewPlaying = false
        }
    }
    
    private func soundIcon(for sound: SyntheticSound) -> String {
        switch sound {
        case .click:
            return "waveform.path"
        case .snap:
            return "hand.point.up"
        case .beep:
            return "speaker.wave.2"
        case .blip:
            return "dot.radiowaves.left.and.right"
        }
    }
    
    // MARK: - Responsive Properties (Same as original SoundsView)
    
    private var sectionHeaderFontSize: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 20 :
                   screenWidth <= 834 ? 22 :
                   screenWidth <= 1024 ? 24 :
                   26
        } else {
            return screenWidth <= 320 ? 16 :
                   screenWidth <= 375 ? 18 :
                   screenWidth <= 393 ? 20 :
                   22
        }
    }
    
    private var currentSoundTitleSize: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 18 :
                   screenWidth <= 834 ? 20 :
                   screenWidth <= 1024 ? 22 :
                   24
        } else {
            return screenWidth <= 320 ? 14 :
                   screenWidth <= 375 ? 16 :
                   screenWidth <= 393 ? 18 :
                   19
        }
    }
    
    private var currentSoundDescSize: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 14 :
                   screenWidth <= 834 ? 15 :
                   screenWidth <= 1024 ? 16 :
                   17
        } else {
            return screenWidth <= 320 ? 11 :
                   screenWidth <= 375 ? 12 :
                   screenWidth <= 393 ? 13 :
                   14
        }
    }
    
    private var soundTitleSize: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 16 :
                   screenWidth <= 834 ? 18 :
                   screenWidth <= 1024 ? 20 :
                   22
        } else {
            return screenWidth <= 320 ? 12 :
                   screenWidth <= 375 ? 14 :
                   screenWidth <= 393 ? 16 :
                   17
        }
    }
    
    private var soundDescSize: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 13 :
                   screenWidth <= 834 ? 14 :
                   screenWidth <= 1024 ? 15 :
                   16
        } else {
            return screenWidth <= 320 ? 10 :
                   screenWidth <= 375 ? 11 :
                   screenWidth <= 393 ? 12 :
                   13
        }
    }
    
    private var previewButtonIconSize: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 12 :
                   screenWidth <= 834 ? 13 :
                   screenWidth <= 1024 ? 14 :
                   15
        } else {
            return screenWidth <= 320 ? 10 :
                   screenWidth <= 375 ? 11 :
                   screenWidth <= 393 ? 12 :
                   13
        }
    }
    
    private var previewButtonTextSize: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 11 :
                   screenWidth <= 834 ? 12 :
                   screenWidth <= 1024 ? 13 :
                   14
        } else {
            return screenWidth <= 320 ? 9 :
                   screenWidth <= 375 ? 10 :
                   screenWidth <= 393 ? 11 :
                   12
        }
    }
    
    private var soundIconSize: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 18 :
                   screenWidth <= 834 ? 20 :
                   screenWidth <= 1024 ? 22 :
                   24
        } else {
            return screenWidth <= 320 ? 14 :
                   screenWidth <= 375 ? 16 :
                   screenWidth <= 393 ? 18 :
                   20
        }
    }
    
    private var soundIconFrameSize: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 36 :
                   screenWidth <= 834 ? 40 :
                   screenWidth <= 1024 ? 44 :
                   48
        } else {
            return screenWidth <= 320 ? 28 :
                   screenWidth <= 375 ? 32 :
                   screenWidth <= 393 ? 36 :
                   40
        }
    }
    
    private var actionButtonSize: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 20 :
                   screenWidth <= 834 ? 22 :
                   screenWidth <= 1024 ? 24 :
                   26
        } else {
            return screenWidth <= 320 ? 16 :
                   screenWidth <= 375 ? 18 :
                   screenWidth <= 393 ? 20 :
                   22
        }
    }
    
    private var sectionPadding: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 32 :
                   screenWidth <= 834 ? 40 :
                   screenWidth <= 1024 ? 48 :
                   56
        } else {
            return screenWidth <= 320 ? 12 :
                   screenWidth <= 375 ? 16 :
                   screenWidth <= 393 ? 20 :
                   22
        }
    }
    
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
    
    private var settingsSectionSpacing: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 20 :
                   screenWidth <= 834 ? 24 :
                   screenWidth <= 1024 ? 28 :
                   32
        } else {
            return screenWidth <= 320 ? 12 :
                   screenWidth <= 375 ? 16 :
                   screenWidth <= 393 ? 18 :
                   20
        }
    }
    
    private var settingsItemSpacing: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 14 :
                   screenWidth <= 834 ? 16 :
                   screenWidth <= 1024 ? 18 :
                   20
        } else {
            return screenWidth <= 320 ? 8 :
                   screenWidth <= 375 ? 10 :
                   screenWidth <= 393 ? 12 :
                   14
        }
    }
    
    private var sectionSpacing: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 30 :
                   screenWidth <= 834 ? 35 :
                   screenWidth <= 1024 ? 40 :
                   45
        } else {
            return screenWidth <= 320 ? 16 :
                   screenWidth <= 375 ? 20 :
                   screenWidth <= 393 ? 25 :
                   28
        }
    }
    
    private var cardPadding: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 20 :
                   screenWidth <= 834 ? 24 :
                   screenWidth <= 1024 ? 28 :
                   32
        } else {
            return screenWidth <= 320 ? 12 :
                   screenWidth <= 375 ? 16 :
                   screenWidth <= 393 ? 18 :
                   20
        }
    }
    
    private var soundRowPadding: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 16 :
                   screenWidth <= 834 ? 18 :
                   screenWidth <= 1024 ? 20 :
                   22
        } else {
            return screenWidth <= 320 ? 10 :
                   screenWidth <= 375 ? 12 :
                   screenWidth <= 393 ? 14 :
                   16
        }
    }
    
    private var soundItemSpacing: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 12 :
                   screenWidth <= 834 ? 14 :
                   screenWidth <= 1024 ? 16 :
                   18
        } else {
            return screenWidth <= 320 ? 8 :
                   screenWidth <= 375 ? 10 :
                   screenWidth <= 393 ? 12 :
                   14
        }
    }
}

// MARK: - Currently Applied Song View (Reused from SongsView)
struct LibraryCurrentlyAppliedSongView: View {
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

// MARK: - Enhanced Song Form Row View (Reused from SongsView)
struct LibraryEnhancedSongFormRowView: View {
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
                    LibraryFixedSongSetlistBadgeView(
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
struct LibraryFixedSongSetlistBadgeView: View {
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

// MARK: - Setlist Row View (Reused from SetlistsView)
struct LibrarySetlistRowView: View {
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

#Preview {
    let metronome = MetronomeEngine()
    let songManager = SongManager()
    let setlistManager = SetlistManager()
    return LibraryView(
        metronome: metronome,
        songManager: songManager,
        setlistManager: setlistManager
    )
}
