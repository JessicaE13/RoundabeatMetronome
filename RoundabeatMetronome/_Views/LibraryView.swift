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

// MARK: - Library Tab Types
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

// MARK: - Main Library View
struct LibraryView: View {
    @ObservedObject var metronome: MetronomeEngine
    @ObservedObject var songManager: SongManager
    @ObservedObject var setlistManager: SetlistManager
    @State private var selectedTab: LibraryTab = .sounds
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                horizontalPillSegmentedControl
                
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
        .navigationViewStyle(.stack)
    }
    
    private var horizontalPillSegmentedControl: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(LibraryTab.allCases, id: \.self) { tab in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            selectedTab = tab
                        }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: tab.iconName)
                                .font(.system(size: 18))
                            Text(tab.rawValue)
                                .font(.system(size: 14))
                        }
                        .foregroundColor(selectedTab == tab ? .black : .primary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(
                                    selectedTab == tab ?
                                    AnyShapeStyle(LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color("AccentColor").opacity(0.8),
                                            Color("AccentColor").opacity(0.75)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )) :
                                    AnyShapeStyle(Color("Background2"))
                                )
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
        }
    }
}

// MARK: - Fixed Sound Preview System
struct SoundsViewForLibrary: View {
    @ObservedObject var metronome: MetronomeEngine
    @State private var currentlyPreviewingSound: SyntheticSound? = nil
    @State private var previewWorkItem: DispatchWorkItem? = nil
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
            filteredByOption = filtered
        case .applied:
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
    
    var body: some View {
        VStack(spacing: 0) {
            // Search Section - Updated to match setlists styling
            VStack(spacing: 4) {
                HStack(spacing: 2) {
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 17, weight: .regular))
                            .foregroundColor(.secondary)
                        
                        TextField("Search sounds", text: $searchText)
                            .font(.system(size: 17))
                            .textFieldStyle(.plain)
                        
                        HStack(spacing: 2) {
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    sortOption = sortOption.nextOption
                                }
                            }) {
                                Image(systemName: sortOption.iconName)
                                    .font(.system(size: 17, weight: .medium))
                                    .foregroundColor(sortOption == .none ? .secondary : Color("AccentColor"))
                            }
                            .buttonStyle(.plain)
                            .frame(minWidth: 28, minHeight: 28)
                            
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
                                    .font(.system(size: 17, weight: .medium))
                                    .foregroundColor(filterOption == .all ? .secondary : Color("AccentColor"))
                            }
                            .buttonStyle(.plain)
                            .frame(minWidth: 28, minHeight: 28)
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color("Background2"))
                    )
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
            
            ScrollView {
                LazyVStack(spacing: 8) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("\(filteredAndSortedSounds.count) SOUND\(filteredAndSortedSounds.count == 1 ? "" : "S")")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 24)
                            .padding(.top, 12)
                            .padding(.bottom, 4)
                        
                        ForEach(filteredAndSortedSounds, id: \.self) { sound in
                            LibrarySoundRowView(
                                sound: sound,
                                isCurrentlyApplied: metronome.selectedSoundType == sound,
                                metronome: metronome,
                                isPreviewPlaying: .constant(currentlyPreviewingSound == sound),
                                onTap: {
                                    if #available(iOS 10.0, *) {
                                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                    }
                                    metronome.updateSoundType(to: sound)
                                    if !metronome.isPlaying {
                                        playPreview(sound)
                                    }
                                },
                                onPreview: {
                                    playPreview(sound)
                                }
                            )
                            .padding(.horizontal, 24)
                        }
                    }
                    
                    Color.clear.frame(height: 80)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                LibraryCurrentlyAppliedSoundView(
                    sound: metronome.selectedSoundType,
                    metronome: metronome,
                    isPreviewPlaying: .constant(currentlyPreviewingSound == metronome.selectedSoundType),
                    playPreview: { sound in
                        playPreview(sound)
                    }
                )
                .padding(.horizontal, 12) // Extra padding to match the sound rows
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color("Background2"))
                )
                .padding(.horizontal, 12)
            }
            .padding(.vertical, 12)
        }
    }
    
    // **MARK: - Simplified Preview Function (Allows Overlapping Sounds)**
    private func playPreview(_ sound: SyntheticSound) {
        // Set visual feedback immediately
        currentlyPreviewingSound = sound
        
        // Play the preview - multiple sounds can overlap
        metronome.playSoundPreviewAdvanced(sound)
        
        // Reset visual feedback after a short duration
        let previewDuration: TimeInterval = 0.25
        DispatchQueue.main.asyncAfter(deadline: .now() + previewDuration) {
            // Only reset if this sound is still the current one being shown
            if self.currentlyPreviewingSound == sound {
                self.currentlyPreviewingSound = nil
            }
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
}

// MARK: - Updated Sound Row View with Song View Styling
struct LibrarySoundRowView: View {
    let sound: SyntheticSound
    let isCurrentlyApplied: Bool
    @ObservedObject var metronome: MetronomeEngine
    @Binding var isPreviewPlaying: Bool
    let onTap: () -> Void
    let onPreview: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: soundIcon(for: sound))
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(isCurrentlyApplied ? .primary : .secondary)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(sound.rawValue)
                    .font(.body) // Matches song view font
                    .foregroundColor(isCurrentlyApplied ? Color("AccentColor") : .primary.opacity(0.8)) // Updated color logic
                    .lineLimit(1)
                
                Text(sound.description)
                    .font(.caption) // Matches song view font
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                if !isCurrentlyApplied && !metronome.isPlaying {
                    Button(action: {
                        onPreview()
                    }) {
                        Image(systemName: isPreviewPlaying ? "waveform" : "play.circle")
                            .font(.system(size: 20))
                            .foregroundColor(isPreviewPlaying ? .primary : .secondary)
                    }
                    .buttonStyle(.plain)
                    .frame(minWidth: 44, minHeight: 44)
                }
                
                if !isCurrentlyApplied && metronome.isPlaying {
                    Image(systemName: "speaker.slash.circle")
                        .font(.system(size: 20))
                        .foregroundColor(isPreviewPlaying ? .primary : .secondary)
                        .frame(minWidth: 44, minHeight: 44)
                }
                
                if isCurrentlyApplied {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.primary)
                        .frame(minWidth: 44, minHeight: 44)
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
        .padding(.vertical, 10) // Updated to match song view padding
        .frame(minHeight: 44)
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
}

// MARK: - Currently Applied Song View (Updated with white icons)
struct LibraryCurrentlyAppliedSongView: View {
    let song: Song
    @ObservedObject var metronome: MetronomeEngine
    let onClearSelection: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "music.note")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.white) // Changed from Color("AccentColor") to .white
                .frame(width: 32, height: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(song.title)
                    .font(.body)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
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
            
            Button(action: {
                metronome.isPlaying.toggle()
            }) {
                Image(systemName: metronome.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.white) // Changed from Color("AccentColor") to .white
            }
            .buttonStyle(.plain)
            .frame(minWidth: 44, minHeight: 44)
        }
        .padding(.vertical, 10)
        .frame(minHeight: 44)
    }
}

// MARK: - Enhanced Song Form Row View
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
        HStack(spacing: 12) {
            Button {
                onToggleFavorite()
            } label: {
                Image(systemName: song.isFavorite ? "heart.fill" : "heart")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(song.isFavorite ? .red : .secondary)
                    .frame(width: 24, height: 24)
            }
            .buttonStyle(.plain)
            .frame(minWidth: 44, minHeight: 44)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(song.title)
                        .font(.body)
                        .foregroundColor(isCurrentlyApplied ? .primary : .primary.opacity(0.8))
                        .lineLimit(1)
                    
                    LibraryFixedSongSetlistBadgeView(
                        song: song,
                        setlistManager: setlistManager
                    )
                }
                
                HStack(spacing: 8) {
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
                    .font(.system(size: 20))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
            .frame(minWidth: 44, minHeight: 44)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
        .padding(.vertical, 10)
        .frame(minHeight: 44)
        .sheet(isPresented: $showingSetlistPicker) {
            SongSetlistPickerView(
                song: song,
                setlistManager: setlistManager
            )
        }
    }
}




// MARK: - Songs Tab View (Updated to match Sounds View styling with collapsing button)
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
    @State private var isScrolling = false // Added for collapsing button
    
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
        ZStack { // Changed from VStack to ZStack to match setlists view
            VStack(spacing: 0) {
                // Search Section - Matching sounds view styling exactly
                VStack(spacing: 4) {
                    HStack(spacing: 2) {
                        HStack(spacing: 8) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 17, weight: .regular))
                                .foregroundColor(.secondary)
                            
                            TextField("Search songs", text: $songManager.searchText)
                                .font(.system(size: 17))
                                .textFieldStyle(.plain)
                            
                            HStack(spacing: 2) {
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        sortOption = sortOption.nextOption
                                    }
                                }) {
                                    Image(systemName: sortOption.iconName)
                                        .font(.system(size: 17, weight: .medium))
                                        .foregroundColor(sortOption == .none ? .secondary : Color("AccentColor"))
                                }
                                .buttonStyle(.plain)
                                .frame(minWidth: 28, minHeight: 28)
                                
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
                                        .font(.system(size: 17, weight: .medium))
                                        .foregroundColor(filterOption == .all ? .secondary : Color("AccentColor"))
                                }
                                .buttonStyle(.plain)
                                .frame(minWidth: 28, minHeight: 28)
                            }
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color("Background2"))
                        )
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                }
                .background(Color(.systemBackground)) // Added background like setlists view
                
                ScrollView {
                    LazyVStack(spacing: 8) {
                        if sortedSongs.isEmpty {
                            emptySongsView
                                .padding(.top, 24)
                        } else {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("\(sortedSongs.count) SONG\(sortedSongs.count == 1 ? "" : "S")")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 24)
                                    .padding(.top, 12)
                                    .padding(.bottom, 4)
                                
                                ForEach(sortedSongs) { song in
                                    LibrarySongRowView(
                                        song: song,
                                        isCurrentlyApplied: songManager.currentlySelectedSongId == song.id,
                                        setlistManager: setlistManager,
                                        onTap: {
                                            if #available(iOS 10.0, *) {
                                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                            }
                                            if songManager.currentlySelectedSongId == song.id {
                                                // Deselect if the same song is tapped
                                                songManager.clearCurrentlySelectedSong()
                                            } else if metronome.isPlaying {
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
                                    .padding(.horizontal, 24)
                                }
                            }
                        }
                        
                        Color.clear.frame(height: 80)
                    }
                }
                .simultaneousGesture( // Added scroll detection like setlists view
                    DragGesture()
                        .onChanged { value in
                            withAnimation(.easeOut(duration: 0.2)) {
                                isScrolling = value.translation.height < 0
                            }
                        }
                )
                
                // Currently Applied Song Section - Matching sounds view layout
                if let currentSong = songManager.currentlySelectedSong {
                    VStack(alignment: .leading, spacing: 8) {
                        LibraryCurrentlyAppliedSongView(
                            song: currentSong,
                            metronome: metronome,
                            onClearSelection: {
                                songManager.clearCurrentlySelectedSong()
                            }
                        )
                        .padding(.horizontal, 12) // Extra padding to match the sound rows
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color("Background2"))
                        )
                        .padding(.horizontal, 12)
                    }
                    .padding(.vertical, 12)
                }
            }
            
            // Floating Add Button - moved outside VStack and updated to use isScrolling
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    FloatingActionButton(
                        isCollapsed: isScrolling, // Now uses isScrolling state
                        iconName: "plus",
                        text: "Add Song",
                        action: { showingAddSong = true }
                    )
                    .padding(.trailing, 16)
                    .padding(.bottom, songManager.currentlySelectedSong != nil ? 84 : 16)
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
        VStack(spacing: 12) {
            Image(systemName: "music.note.list")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            
            VStack(spacing: 4) {
                Text("No Songs Yet")
                    .font(.body)
                    .fontWeight(.medium)
                Text("Add songs with their BPM to quickly set your metronome tempo")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: {
                showingAddSong = true
            }) {
                Text("Add Your First Song")
                    .font(.subheadline)
                    .foregroundColor(Color("AccentColor"))
                    .padding(.vertical, 8)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
    }
}



// MARK: - Updated Song Row View (Simplified to match sounds view)
struct LibrarySongRowView: View {
    let song: Song
    let isCurrentlyApplied: Bool
    @ObservedObject var setlistManager: SetlistManager
    let onTap: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onToggleFavorite: () -> Void
    
    @State private var showingSetlistPicker = false
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "music.note")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(isCurrentlyApplied ? .primary : .secondary)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(song.title)
                        .font(.body) // Matches sound view font
                        .foregroundColor(isCurrentlyApplied ? Color("AccentColor") : .primary.opacity(0.8)) // Updated color logic to match sounds
                        .lineLimit(1)
                    
                    if song.isFavorite {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.red)
                    }
                    
                    LibraryFixedSongSetlistBadgeView(
                        song: song,
                        setlistManager: setlistManager
                    )
                }
                
                HStack(spacing: 8) {
                    if !song.artist.isEmpty {
                        Text(song.artist)
                            .font(.caption) // Matches sound view font
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
            
            HStack(spacing: 12) {
                if !isCurrentlyApplied {
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
                            .font(.system(size: 20))
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                    .frame(minWidth: 44, minHeight: 44)
                }
                
                if isCurrentlyApplied {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.primary)
                        .frame(minWidth: 44, minHeight: 44)
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
        .padding(.vertical, 10) // Updated to match sound view padding
        .frame(minHeight: 44)
        .sheet(isPresented: $showingSetlistPicker) {
            SongSetlistPickerView(
                song: song,
                setlistManager: setlistManager
            )
        }
    }
}
// MARK: - Setlists Tab View
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
            filteredByOption = filtered.filter { setlist in
                setlist.songIds.contains { songId in
                    if let song = songManager.songs.first(where: { $0.id == songId }) {
                        return song.isFavorite
                    }
                    return false
                }
            }
        case .applied:
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
                VStack(spacing: 4) {
                    HStack(spacing: 2) {
                        HStack(spacing: 8) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 17, weight: .regular))
                                .foregroundColor(.secondary)
                            
                            TextField("Search setlists", text: $setlistManager.searchText)
                                .font(.system(size: 17))
                                .textFieldStyle(.plain)
                            
                            HStack(spacing: 2) {
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        sortOption = sortOption.nextOption
                                    }
                                }) {
                                    Image(systemName: sortOption.iconName)
                                        .font(.system(size: 17, weight: .medium))
                                        .foregroundColor(sortOption == .none ? .secondary : Color("AccentColor"))
                                }
                                .buttonStyle(.plain)
                                .frame(minWidth: 28, minHeight: 28)
                                
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
                                        .font(.system(size: 17, weight: .medium))
                                        .foregroundColor(filterOption == .all ? .secondary : Color("AccentColor"))
                                }
                                .buttonStyle(.plain)
                                .frame(minWidth: 28, minHeight: 28)
                            }
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color("Background2"))
                        )
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                }
                .background(Color(.systemBackground))
                
                ScrollView {
                    LazyVStack(spacing: 8) {
                        if sortedSetlists.isEmpty {
                            emptySetlistsView
                                .padding(.top, 24)
                        } else {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("\(sortedSetlists.count) SETLIST\(sortedSetlists.count == 1 ? "" : "S")")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 24)
                                    .padding(.top, 12)
                                    .padding(.bottom, 4)
                                
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
                                        .padding(.horizontal, 24)
                                        .padding(.vertical, 4)
                                    }
                                }
                            }
                        }
                        
                        Color.clear.frame(height: 80)
                    }
                }
                .simultaneousGesture(
                    DragGesture()
                        .onChanged { value in
                            withAnimation(.easeOut(duration: 0.2)) {
                                isScrolling = value.translation.height < 0
                            }
                        }
                )
            }
            
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
                    .padding(.trailing, 16)
                    .padding(.bottom, 16)
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
        VStack(spacing: 12) {
            Image(systemName: "music.note.list")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            
            VStack(spacing: 4) {
                Text("No Setlists Yet")
                    .font(.body)
                    .fontWeight(.medium)
                Text("Create setlists to organize your songs for performances or practice sessions")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: {
                showingCreateSetlist = true
            }) {
                Text("Create Your First Setlist")
                    .font(.subheadline)
                    .foregroundColor(Color("AccentColor"))
                    .padding(.vertical, 8)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
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
                Section(header: Text("Setlist Details")) {
                    TextField("Setlist Name", text: $name)
                        .font(.body)
                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                        .font(.body)
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
                    .font(.system(size: 16))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveSetlist()
                    }
                    .font(.system(size: 16))
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

// MARK: - Sounds Tab View
struct SoundsTabView: View {
    @ObservedObject var metronome: MetronomeEngine
    
    var body: some View {
        SoundsViewForLibrary(metronome: metronome)
    }
}


// MARK: - Fixed Song Setlist Badge View
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
                    Button(action: {}) {
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
                .foregroundColor(.primary)
                .padding(.horizontal, 24)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray5))
                )
            }
        }
    }
}

// MARK: - Setlist Row View
struct LibrarySetlistRowView: View {
    let setlist: Setlist
    let songCount: Int
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onDuplicate: () -> Void
    
    @State private var showingActionSheet = false
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "music.note.list")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 36, height: 36)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(setlist.name)
                    .font(.body)
                    .fontWeight(.regular)
                    .foregroundColor(Color("AccentColor"))
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    Text("\(songCount) song\(songCount == 1 ? "" : "s")")
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
                
                Text("Modified \(formatDate(setlist.dateModified))")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: {
                showingActionSheet = true
            }) {
                Image(systemName: "ellipsis")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
            .frame(minWidth: 44, minHeight: 44)
        }
        .padding(.vertical, 10)
        .frame(minHeight: 44)
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


// MARK: - Floating Action Button
struct FloatingActionButton: View {
    let isCollapsed: Bool
    let iconName: String
    let text: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: iconName)
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(.black)
                
                if !isCollapsed {
                    Text(text)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.black)
                }
            }
            .padding(.horizontal, isCollapsed ? 14 : 20)
            .padding(.vertical, isCollapsed ? 14 : 12)
            .frame(minHeight: 44)
            .background(
                RoundedRectangle(cornerRadius: isCollapsed ? 22 : 22)
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [
                            Color("AccentColor").opacity(0.8),
                            Color("AccentColor").opacity(0.75)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
            )
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isCollapsed)
    }
}

// MARK: - Updated Currently Applied Sound View (Updated with white icons)
struct LibraryCurrentlyAppliedSoundView: View {
    let sound: SyntheticSound
    @ObservedObject var metronome: MetronomeEngine
    @Binding var isPreviewPlaying: Bool
    let playPreview: (SyntheticSound) -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: soundIcon(for: sound))
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.white) // Changed from Color("AccentColor") to .white
                .frame(width: 32, height: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(sound.rawValue)
                    .font(.body)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                Text(sound.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Button(action: {
                playPreview(sound)
            }) {
                Image(systemName: isPreviewPlaying ? "waveform" : "play.circle.fill")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.white) // Changed from Color("AccentColor") to .white
            }
            .buttonStyle(.plain)
            .frame(minWidth: 44, minHeight: 44)
            // Only disable when metronome is playing, not when previewing
            .disabled(metronome.isPlaying)
        }
        .padding(.vertical, 10)
        .frame(minHeight: 44)
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
