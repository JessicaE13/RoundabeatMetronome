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
