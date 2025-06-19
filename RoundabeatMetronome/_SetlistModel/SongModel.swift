//
//  SongModel.swift
//  RoundabeatMetronome
//

import SwiftUI
import Foundation

// MARK: - Song Model
struct Song: Identifiable, Codable, Equatable {
    var id: UUID
    var title: String
    var artist: String
    var bpm: Int
    var timeSignature: TimeSignature
    var notes: String
    var dateAdded: Date
    var isFavorite: Bool
    
    init(title: String, artist: String, bpm: Int, timeSignature: TimeSignature = TimeSignature(numerator: 4, denominator: 4), notes: String = "", isFavorite: Bool = false) {
        self.id = UUID()
        self.title = title
        self.artist = artist
        self.bpm = max(40, min(400, bpm))
        self.timeSignature = timeSignature
        self.notes = notes
        self.dateAdded = Date()
        self.isFavorite = isFavorite
    }
    
    var displayName: String {
        if artist.isEmpty {
            return title
        } else {
            return "\(title) - \(artist)"
        }
    }
    
    // MARK: - Codable Implementation with Migration Support
    enum CodingKeys: String, CodingKey {
        case id, title, artist, bpm, timeSignature, notes, dateAdded, isFavorite
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Try to decode existing UUID, or generate new one if missing (for migration)
        if let existingId = try? container.decode(UUID.self, forKey: .id) {
            id = existingId
        } else {
            id = UUID() // Generate new UUID for legacy data
        }
        
        title = try container.decode(String.self, forKey: .title)
        artist = try container.decode(String.self, forKey: .artist)
        bpm = try container.decode(Int.self, forKey: .bpm)
        timeSignature = try container.decode(TimeSignature.self, forKey: .timeSignature)
        notes = try container.decode(String.self, forKey: .notes)
        dateAdded = try container.decode(Date.self, forKey: .dateAdded)
        isFavorite = try container.decode(Bool.self, forKey: .isFavorite)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(artist, forKey: .artist)
        try container.encode(bpm, forKey: .bpm)
        try container.encode(timeSignature, forKey: .timeSignature)
        try container.encode(notes, forKey: .notes)
        try container.encode(dateAdded, forKey: .dateAdded)
        try container.encode(isFavorite, forKey: .isFavorite)
    }
}

// MARK: - Time Signature Model
struct TimeSignature: Codable, Equatable {
    var numerator: Int
    var denominator: Int
    
    var displayString: String {
        return "\(numerator)/\(denominator)"
    }
}

// MARK: - Song Manager
class SongManager: ObservableObject {
    @Published var songs: [Song] = []
    @Published var searchText: String = ""
    @Published var sortBy: SortOption = .dateAdded
    @Published var sortAscending: Bool = false
    
    private let userDefaultsKey = "SavedSongs"
    
    enum SortOption: String, CaseIterable {
        case title = "Title"
        case artist = "Artist"
        case bpm = "BPM"
        case dateAdded = "Date Added"
    }
    
    init() {
        loadSongs()
    }
    
    // MARK: - Core CRUD Operations
    
    func addSong(_ song: Song) {
        songs.append(song)
        saveSongs()
    }
    
    func updateSong(_ song: Song) {
        if let index = songs.firstIndex(where: { $0.id == song.id }) {
            songs[index] = song
            saveSongs()
        }
    }
    
    func deleteSong(_ song: Song) {
        songs.removeAll { $0.id == song.id }
        saveSongs()
    }
    
    func toggleFavorite(_ song: Song) {
        if let index = songs.firstIndex(where: { $0.id == song.id }) {
            songs[index].isFavorite.toggle()
            saveSongs()
        }
    }
    
    // MARK: - Filtering and Sorting
    
    var filteredSongs: [Song] {
        var filtered = songs
        
        // Filter by search text
        if !searchText.isEmpty {
            filtered = filtered.filter { song in
                song.title.localizedCaseInsensitiveContains(searchText) ||
                song.artist.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Sort
        switch sortBy {
        case .title:
            filtered.sort { sortAscending ? $0.title < $1.title : $0.title > $1.title }
        case .artist:
            filtered.sort { sortAscending ? $0.artist < $1.artist : $0.artist > $1.artist }
        case .bpm:
            filtered.sort { sortAscending ? $0.bpm < $1.bpm : $0.bpm > $1.bpm }
        case .dateAdded:
            filtered.sort { sortAscending ? $0.dateAdded < $1.dateAdded : $0.dateAdded > $1.dateAdded }
        }
        
        return filtered
    }
    
    var favoriteSongs: [Song] {
        return songs.filter { $0.isFavorite }.sorted { $0.title < $1.title }
    }
    
    // MARK: - Persistence
    
    private func saveSongs() {
        if let encoded = try? JSONEncoder().encode(songs) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    private func loadSongs() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode([Song].self, from: data) {
            songs = decoded
        }
    }
    
    // MARK: - Sample Data
    
    func addSampleSongs() {
        let sampleSongs = [
            Song(title: "Don't Stop Believin'", artist: "Journey", bpm: 119),
            Song(title: "Billie Jean", artist: "Michael Jackson", bpm: 117),
            Song(title: "Take Five", artist: "Dave Brubeck", bpm: 176, timeSignature: TimeSignature(numerator: 5, denominator: 4)),
            Song(title: "Bohemian Rhapsody", artist: "Queen", bpm: 72),
            Song(title: "Uptown Funk", artist: "Mark Ronson ft. Bruno Mars", bpm: 115)
        ]
        
        for song in sampleSongs {
            if !songs.contains(where: { $0.title == song.title && $0.artist == song.artist }) {
                addSong(song)
            }
        }
    }
}

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

// MARK: - Song Row View
struct SongRowView: View {
    let song: Song
    let onTap: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onToggleFavorite: () -> Void
    
    @State private var showingActionSheet = false
    
    // Get screen dimensions directly
    private var screenWidth: CGFloat {
        UIScreen.main.bounds.width
    }
    
    // Check if device is iPad
    private var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Music note icon
                Image(systemName: "music.note")
                    .font(.system(size: iconSize, weight: .medium))
                    .foregroundColor(.accentColor)
                    .frame(width: iconFrameSize, height: iconFrameSize)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.accentColor.opacity(0.1))
                    )
                
                // Song info
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(song.title)
                            .font(.system(size: titleFontSize, weight: .semibold))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        
                        if song.isFavorite {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.red)
                        }
                        
                        Spacer()
                    }
                    
                    if !song.artist.isEmpty {
                        Text(song.artist)
                            .font(.system(size: subtitleFontSize))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    
                    HStack(spacing: 8) {
                        // BPM
                        Text("\(song.bpm) BPM")
                            .font(.system(size: detailFontSize, weight: .medium))
                            .foregroundColor(.accentColor)
                        
                        // Time signature
                        if song.timeSignature.numerator != 4 || song.timeSignature.denominator != 4 {
                            Text(song.timeSignature.displayString)
                                .font(.system(size: detailFontSize))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                }
                
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
        }
        .buttonStyle(.plain)
        .padding(rowPadding)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
        .confirmationDialog("Song Options", isPresented: $showingActionSheet, titleVisibility: .visible) {
            Button(song.isFavorite ? "Remove from Favorites" : "Add to Favorites") {
                onToggleFavorite()
            }
            
            Button("Edit Song") {
                onEdit()
            }
            
            Button("Delete Song", role: .destructive) {
                onDelete()
            }
            
            Button("Cancel", role: .cancel) { }
        }
    }
    
    // MARK: - Responsive Properties
    
    private var iconSize: CGFloat {
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
    
    private var iconFrameSize: CGFloat {
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
    
    private var titleFontSize: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 16 :
                   screenWidth <= 834 ? 18 :
                   screenWidth <= 1024 ? 20 :
                   22
        } else {
            return screenWidth <= 320 ? 14 :
                   screenWidth <= 375 ? 16 :
                   screenWidth <= 393 ? 18 :
                   20
        }
    }
    
    private var subtitleFontSize: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 14 :
                   screenWidth <= 834 ? 15 :
                   screenWidth <= 1024 ? 16 :
                   17
        } else {
            return screenWidth <= 320 ? 12 :
                   screenWidth <= 375 ? 13 :
                   screenWidth <= 393 ? 14 :
                   15
        }
    }
    
    private var detailFontSize: CGFloat {
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
    
    private var rowPadding: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 16 :
                   screenWidth <= 834 ? 18 :
                   screenWidth <= 1024 ? 20 :
                   22
        } else {
            return screenWidth <= 320 ? 12 :
                   screenWidth <= 375 ? 14 :
                   screenWidth <= 393 ? 16 :
                   18
        }
    }
}

// MARK: - Add/Edit Song View
struct AddEditSongView: View {
    @ObservedObject var songManager: SongManager
    let editingSong: Song?
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String = ""
    @State private var artist: String = ""
    @State private var bpmText: String = "120"
    @State private var timeSignatureNumerator: Int = 4
    @State private var timeSignatureDenominator: Int = 4
    @State private var notes: String = ""
    @State private var isFavorite: Bool = false
    
    init(songManager: SongManager, editingSong: Song? = nil) {
        self.songManager = songManager
        self.editingSong = editingSong
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Song Details") {
                    TextField("Song Title", text: $title)
                    TextField("Artist", text: $artist)
                }
                
                Section("Tempo & Time Signature") {
                    HStack {
                        Text("BPM")
                        Spacer()
                        TextField("120", text: $bpmText)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                    
                    HStack {
                        Text("Time Signature")
                        Spacer()
                        
                        Picker("Numerator", selection: $timeSignatureNumerator) {
                            ForEach(1...32, id: \.self) { num in
                                Text("\(num)").tag(num)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(width: 60)
                        
                        Text("/")
                        
                        Picker("Denominator", selection: $timeSignatureDenominator) {
                            ForEach([1, 2, 4, 8, 16, 32], id: \.self) { denom in
                                Text("\(denom)").tag(denom)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(width: 60)
                    }
                }
                
                Section("Additional Info") {
                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(3, reservesSpace: true)
                    
                    Toggle("Add to Favorites", isOn: $isFavorite)
                }
            }
            .navigationTitle(editingSong == nil ? "Add Song" : "Edit Song")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveSong()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .onAppear {
            if let song = editingSong {
                title = song.title
                artist = song.artist
                bpmText = "\(song.bpm)"
                timeSignatureNumerator = song.timeSignature.numerator
                timeSignatureDenominator = song.timeSignature.denominator
                notes = song.notes
                isFavorite = song.isFavorite
            }
        }
    }
    
    private func saveSong() {
        let bpm = Int(bpmText) ?? 120
        let clampedBPM = max(40, min(400, bpm))
        
        let timeSignature = TimeSignature(numerator: timeSignatureNumerator, denominator: timeSignatureDenominator)
        
        if let editingSong = editingSong {
            // Update existing song
            var updatedSong = editingSong
            updatedSong.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
            updatedSong.artist = artist.trimmingCharacters(in: .whitespacesAndNewlines)
            updatedSong.bpm = clampedBPM
            updatedSong.timeSignature = timeSignature
            updatedSong.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
            updatedSong.isFavorite = isFavorite
            
            songManager.updateSong(updatedSong)
        } else {
            // Add new song
            let newSong = Song(
                title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                artist: artist.trimmingCharacters(in: .whitespacesAndNewlines),
                bpm: clampedBPM,
                timeSignature: timeSignature,
                notes: notes.trimmingCharacters(in: .whitespacesAndNewlines),
                isFavorite: isFavorite
            )
            
            songManager.addSong(newSong)
        }
        
        dismiss()
    }
}

// MARK: - Filter & Sort Sheet
struct FilterSortSheet: View {
    @ObservedObject var songManager: SongManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section("Sort By") {
                    Picker("Sort Option", selection: $songManager.sortBy) {
                        ForEach(SongManager.SortOption.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    Toggle("Ascending Order", isOn: $songManager.sortAscending)
                }
                
                Section {
                    Button("Clear All Filters") {
                        songManager.searchText = ""
                        songManager.sortBy = .dateAdded
                        songManager.sortAscending = false
                    }
                }
            }
            .navigationTitle("Filter & Sort")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SongsView(metronome: MetronomeEngine())
}
