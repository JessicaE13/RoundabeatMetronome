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

// MARK: - Filter Options
enum LibraryFilterOption: String, CaseIterable {
    case all = "All"
    case favorites = "Favorites"
    case applied = "Currently Applied"
    
    var iconName: String {
        switch self {
        case .all:
            return "line.3.horizontal.decrease.circle"
        case .favorites:
            return "heart.circle"
        case .applied:
            return "checkmark.circle"
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
                // Horizontal Pill Segmented Control
                horizontalPillSegmentedControl
                
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
    
    private var horizontalPillSegmentedControl: some View {
        VStack(spacing: 0) {
            // Horizontal scrolling pill buttons
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(LibraryTab.allCases, id: \.self) { tab in
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                selectedTab = tab
                            }
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: tab.iconName)
                                    .font(.system(size: 12, weight: .medium))
                                Text(tab.rawValue)
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .foregroundColor(selectedTab == tab ? .black : .primary)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(selectedTab == tab ? Color.primary : Color(.systemGray5))
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.vertical, 12)
        }
        .background(
            Color(.systemBackground)
                .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
        )
    }
}

// MARK: - Songs Tab View (Modified with Icons in Search Bar)
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
    @State private var filterOption: LibraryFilterOption = .all
    @State private var isScrolling = false
    
    var sortedSongs: [Song] {
        let filtered = songManager.filteredSongs
        let filteredByOption: [Song]
        
        switch filterOption {
        case .all:
            filteredByOption = filtered
        case .favorites:
            filteredByOption = filtered.filter { $0.isFavorite }
        case .applied:
            if let currentSongId = songManager.currentlySelectedSongId {
                filteredByOption = filtered.filter { $0.id == currentSongId }
            } else {
                filteredByOption = []
            }
        }
        
        switch sortOption {
        case .none:
            return filteredByOption
        case .aToZ:
            return filteredByOption.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        case .zToA:
            return filteredByOption.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedDescending }
        }
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Search Section with embedded icons
                VStack(spacing: 0) {
                    HStack {
                        // Search bar with embedded icons
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.secondary)
                                .font(.system(size: 16))
                            
                            TextField("Search songs...", text: $songManager.searchText)
                                .textFieldStyle(.plain)
                            
                            Spacer()
                            
                            // Sort button inside search bar
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    sortOption = sortOption.nextOption
                                }
                            }) {
                                Image(systemName: sortOption.iconName)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(sortOption == .none ? .secondary : .accentColor)
                            }
                            .buttonStyle(.plain)
                            
                            // Filter button inside search bar
                            Menu {
                                ForEach(LibraryFilterOption.allCases, id: \.self) { option in
                                    Button(action: {
                                        filterOption = option
                                    }) {
                                        HStack {
                                            Text(option.rawValue)
                                            if filterOption == option {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                            } label: {
                                Image(systemName: filterOption.iconName)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(filterOption == .all ? .secondary : .accentColor)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(.systemGray6))
                        )
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 12)
                    
                    Divider()
                        .background(Color.white.opacity(0.2))
                }
                .background(Color(.systemBackground))
                
                // Scrollable content with DragGesture scroll detection
                ScrollView {
                    LazyVStack(spacing: 0) {
                        // Songs List Section - Modified
                        if sortedSongs.isEmpty {
                            emptySongsView
                                .padding(.top, 20)
                        } else {
                            VStack(alignment: .leading, spacing: 0) {
                                Text("\(sortedSongs.count) song\(sortedSongs.count == 1 ? "" : "s")")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 16)
                                    .padding(.top, 16)
                                    .padding(.bottom, 8)
                                
                                // Songs list
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
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 4)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(songManager.currentlySelectedSongId == song.id ? Color(.systemGray6) : Color.clear)
                                            .padding(.horizontal, 16)
                                    )
                                }
                            }
                        }
                        
                        // Add bottom padding to prevent FAB overlap
                        Color.clear.frame(height: 100)
                    }
                }
                .simultaneousGesture(
                    DragGesture()
                        .onChanged { value in
                            withAnimation(.easeOut(duration: 0.2)) {
                                // Collapse when scrolling down, expand when scrolling up
                                if abs(value.translation.height) > 10 {
                                    isScrolling = value.translation.height < 0 // Scrolling down
                                }
                            }
                        }
                )
                
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
            
            // Floating Add Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    FloatingActionButton(
                        isCollapsed: isScrolling,
                        iconName: "plus",
                        text: "Add Song",
                        action: { showingAddSong = true }
                    )
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
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

// MARK: - Setlists Tab View (Modified with Icons in Search Bar)
struct SetlistsTabView: View {
    @ObservedObject var setlistManager: SetlistManager
    @ObservedObject var songManager: SongManager
    @ObservedObject var metronome: MetronomeEngine
    
    @State private var showingCreateSetlist = false
    @State private var selectedSetlist: Setlist? = nil
    @State private var showingEditSetlist = false
    @State private var sortOption: LibrarySortOption = .none
    @State private var filterOption: LibraryFilterOption = .all
    @State private var isScrolling = false
    
    var sortedSetlists: [Setlist] {
        let filtered = setlistManager.filteredSetlists
        let filteredByOption: [Setlist]
        
        switch filterOption {
        case .all:
            filteredByOption = filtered
        case .favorites:
            // For setlists, we'll filter by those containing favorite songs
            filteredByOption = filtered.filter { setlist in
                setlist.songIds.contains { songId in
                    if let song = songManager.songs.first(where: { $0.id == songId }) {
                        return song.isFavorite
                    }
                    return false
                }
            }
        case .applied:
            // For setlists, we'll filter by those containing the currently applied song
            if let currentSongId = songManager.currentlySelectedSongId {
                filteredByOption = filtered.filter { setlist in
                    setlist.songIds.contains(currentSongId)
                }
            } else {
                filteredByOption = []
            }
        }
        
        switch sortOption {
        case .none:
            return filteredByOption
        case .aToZ:
            return filteredByOption.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .zToA:
            return filteredByOption.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedDescending }
        }
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Search Section with embedded icons
                VStack(spacing: 0) {
                    HStack {
                        // Search bar with embedded icons
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.secondary)
                                .font(.system(size: 16))
                            
                            TextField("Search setlists...", text: $setlistManager.searchText)
                                .textFieldStyle(.plain)
                            
                            Spacer()
                            
                            // Sort button inside search bar
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    sortOption = sortOption.nextOption
                                }
                            }) {
                                Image(systemName: sortOption.iconName)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(sortOption == .none ? .secondary : .accentColor)
                            }
                            .buttonStyle(.plain)
                            
                            // Filter button inside search bar
                            Menu {
                                ForEach(LibraryFilterOption.allCases, id: \.self) { option in
                                    Button(action: {
                                        filterOption = option
                                    }) {
                                        HStack {
                                            Text(option.rawValue)
                                            if filterOption == option {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                            } label: {
                                Image(systemName: filterOption.iconName)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(filterOption == .all ? .secondary : .accentColor)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(.systemGray6))
                        )
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 12)
                    
                    Divider()
                        .background(Color.white.opacity(0.09))
                }
                .background(Color(.systemBackground))
                
                // Scrollable content with DragGesture scroll detection
                ScrollView {
                    LazyVStack(spacing: 0) {
                        // Setlists List Section
                        if sortedSetlists.isEmpty {
                            emptySetlistsView
                                .padding(.top, 20)
                        } else {
                            VStack(alignment: .leading, spacing: 0) {
                                Text("My Setlists")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 16)
                                    .padding(.top, 16)
                                    .padding(.bottom, 8)
                                
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
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                        
                        // Add bottom padding to prevent FAB overlap
                        Color.clear.frame(height: 100)
                    }
                }
                .simultaneousGesture(
                    DragGesture()
                        .onChanged { value in
                            withAnimation(.easeOut(duration: 0.2)) {
                                // Collapse when scrolling down, expand when scrolling up
                                if abs(value.translation.height) > 10 {
                                    isScrolling = value.translation.height < 0 // Scrolling down
                                }
                            }
                        }
                )
            }
            
            // Floating Add Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    FloatingActionButton(
                        isCollapsed: isScrolling,
                        iconName: "plus",
                        text: "Add Setlist",
                        action: { showingCreateSetlist = true }
                    )
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
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

// MARK: - Sounds Tab View (Modified with Icons in Search Bar)
struct SoundsTabView: View {
    @ObservedObject var metronome: MetronomeEngine
    
    var body: some View {
        // Use the existing SoundsView but remove the title since we're in a tab
        SoundsViewForLibrary(metronome: metronome)
    }
}

// MARK: - Modified SoundsView for Library (with icons in search bar)
struct SoundsViewForLibrary: View {
    @ObservedObject var metronome: MetronomeEngine
    @State private var isPreviewPlaying = false
    @State private var searchText = ""
    @State private var sortOption: LibrarySortOption = .none
    @State private var filterOption: LibraryFilterOption = .all
    
    var filteredAndSortedSounds: [SyntheticSound] {
        let filtered: [SyntheticSound]
        if searchText.isEmpty {
            filtered = SyntheticSound.allCases
        } else {
            filtered = SyntheticSound.allCases.filter { sound in
                sound.rawValue.localizedCaseInsensitiveContains(searchText) ||
                sound.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        let filteredByOption: [SyntheticSound]
        switch filterOption {
        case .all:
            filteredByOption = filtered
        case .favorites:
            // For sounds, we could potentially filter by user preferences if implemented
            // For now, this will just show all sounds
            filteredByOption = filtered
        case .applied:
            // Show only the currently selected sound
            filteredByOption = filtered.filter { $0 == metronome.selectedSoundType }
        }
        
        switch sortOption {
        case .none:
            return filteredByOption
        case .aToZ:
            return filteredByOption.sorted { $0.rawValue.localizedCaseInsensitiveCompare($1.rawValue) == .orderedAscending }
        case .zToA:
            return filteredByOption.sorted { $0.rawValue.localizedCaseInsensitiveCompare($1.rawValue) == .orderedDescending }
        }
    }
    
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
        VStack(spacing: 0) {
            // Search Section with embedded icons
            VStack(spacing: 0) {
                HStack {
                    // Search bar with embedded icons
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                            .font(.system(size: 16))
                        
                        TextField("Search sounds...", text: $searchText)
                            .textFieldStyle(.plain)
                        
                        Spacer()
                        
                        // Sort button inside search bar
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                sortOption = sortOption.nextOption
                            }
                        }) {
                            Image(systemName: sortOption.iconName)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(sortOption == .none ? .secondary : .accentColor)
                        }
                        .buttonStyle(.plain)
                        
                        // Filter button inside search bar
                        Menu {
                            ForEach(LibraryFilterOption.allCases, id: \.self) { option in
                                Button(action: {
                                    filterOption = option
                                }) {
                                    HStack {
                                        Text(option.rawValue)
                                        if filterOption == option {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            Image(systemName: filterOption.iconName)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(filterOption == .all ? .secondary : .accentColor)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.systemGray6))
                    )
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 12)
            }
            .background(Color(.systemBackground))
            
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
                        ForEach(filteredAndSortedSounds, id: \.self) { sound in
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
                    .foregroundColor(isSelected ? .black : .accentColor)
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

// MARK: - Scroll Detection Helper
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Floating Action Button
struct FloatingActionButton: View {
    let isCollapsed: Bool
    let iconName: String
    let text: String
    let action: () -> Void
    
    private var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    private var buttonHeight: CGFloat {
        isIPad ? 56 : 48
    }
    
    private var iconSize: CGFloat {
        isIPad ? 20 : 18
    }
    
    private var fontSize: CGFloat {
        isIPad ? 16 : 14
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: iconName)
                    .font(.system(size: iconSize, weight: .semibold))
                    .foregroundColor(.black)
                
                if !isCollapsed {
                    Text(text)
                        .font(.system(size: fontSize, weight: .semibold))
                        .foregroundColor(.black)
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .trailing)),
                            removal: .opacity.combined(with: .move(edge: .trailing))
                        ))
                }
            }
            .padding(.horizontal, isCollapsed ? 16 : 20)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: buttonHeight / 2)
                    .fill(Color.accentColor)
                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
            )
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isCollapsed)
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
