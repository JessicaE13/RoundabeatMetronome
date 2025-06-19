import Foundation
import SwiftUI

struct Song: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var artist: String
    var bpm: Int
    var timeSignatureNumerator: Int
    var timeSignatureDenominator: Int
    var subdivisionMultiplier: Double
    var notes: String
    var isPlaying: Bool = false
    var dateCreated: Date = Date()
    var lastModified: Date = Date()
    
    init(title: String = "", artist: String = "", bpm: Int = 120, timeSignatureNumerator: Int = 4, timeSignatureDenominator: Int = 4, subdivisionMultiplier: Double = 1.0, notes: String = "") {
        self.id = UUID() // Initialize id here instead of as default value
        self.title = title
        self.artist = artist
        self.bpm = max(40, min(400, bpm))
        self.timeSignatureNumerator = max(1, min(32, timeSignatureNumerator))
        self.timeSignatureDenominator = max(1, timeSignatureDenominator)
        self.subdivisionMultiplier = max(1.0, min(4.0, subdivisionMultiplier))
        self.notes = notes
        self.dateCreated = Date()
        self.lastModified = Date()
    }
    
    // Custom Codable implementation to handle default values for new properties
    enum CodingKeys: String, CodingKey {
        case id, title, artist, bpm, timeSignatureNumerator, timeSignatureDenominator
        case subdivisionMultiplier, notes, isPlaying, dateCreated, lastModified
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode required fields
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        artist = try container.decode(String.self, forKey: .artist)
        bpm = max(40, min(400, try container.decode(Int.self, forKey: .bpm)))
        timeSignatureNumerator = max(1, min(32, try container.decode(Int.self, forKey: .timeSignatureNumerator)))
        timeSignatureDenominator = max(1, try container.decode(Int.self, forKey: .timeSignatureDenominator))
        subdivisionMultiplier = max(1.0, min(4.0, try container.decode(Double.self, forKey: .subdivisionMultiplier)))
        notes = try container.decode(String.self, forKey: .notes)
        
        // Decode optional fields with defaults
        isPlaying = try container.decodeIfPresent(Bool.self, forKey: .isPlaying) ?? false
        dateCreated = try container.decodeIfPresent(Date.self, forKey: .dateCreated) ?? Date()
        lastModified = try container.decodeIfPresent(Date.self, forKey: .lastModified) ?? Date()
    }
    
    // Rest of your Song struct methods remain the same...
    mutating func updateLastModified() {
        lastModified = Date()
    }
    
    var timeSignatureDisplay: String {
        return "\(timeSignatureNumerator)/\(timeSignatureDenominator)"
    }
    
    var subdivisionSymbol: String {
        switch subdivisionMultiplier {
        case 1.0:
            return "♩"
        case 2.0:
            return "♫"
        case 3.0:
            return "3♫"
        case 4.0:
            return "♬"
        default:
            return "♩"
        }
    }
    
    var isValid: Bool {
        return !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               bpm >= 40 && bpm <= 400 &&
               timeSignatureNumerator >= 1 && timeSignatureNumerator <= 32 &&
               timeSignatureDenominator >= 1 &&
               subdivisionMultiplier >= 1.0 && subdivisionMultiplier <= 4.0
    }
}

// MARK: - Setlist Model
struct Setlist: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var songs: [Song]
    var createdDate: Date
    var lastModified: Date
    var description: String
    var color: String // Store color as string for serialization
    
    init(name: String = "", songs: [Song] = [], description: String = "", color: String = "blue") {
        self.id = UUID() // Initialize id here instead of as default value
        self.name = name
        self.songs = songs
        self.description = description
        self.color = color
        self.createdDate = Date()
        self.lastModified = Date()
    }
    
    // Custom Codable implementation for backward compatibility
    enum CodingKeys: String, CodingKey {
        case id, name, songs, createdDate, lastModified, description, color
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        songs = try container.decode([Song].self, forKey: .songs)
        createdDate = try container.decode(Date.self, forKey: .createdDate)
        lastModified = try container.decode(Date.self, forKey: .lastModified)
        
        // New fields with defaults for backward compatibility
        description = try container.decodeIfPresent(String.self, forKey: .description) ?? ""
        color = try container.decodeIfPresent(String.self, forKey: .color) ?? "blue"
    }
    
    // Rest of your Setlist struct methods remain the same...
    mutating func updateLastModified() {
        lastModified = Date()
    }
    
    mutating func addSong(_ song: Song) {
        songs.append(song)
        updateLastModified()
    }
    
    mutating func removeSong(at index: Int) {
        guard index >= 0 && index < songs.count else { return }
        songs.remove(at: index)
        updateLastModified()
    }
    
    mutating func moveSong(from sourceIndex: Int, to destinationIndex: Int) {
        guard sourceIndex >= 0 && sourceIndex < songs.count &&
              destinationIndex >= 0 && destinationIndex <= songs.count else { return }
        
        let song = songs.remove(at: sourceIndex)
        let insertIndex = destinationIndex > sourceIndex ? destinationIndex - 1 : destinationIndex
        songs.insert(song, at: insertIndex)
        updateLastModified()
    }
    
    var songCount: Int {
        return songs.count
    }
    
    var averageBPM: Double {
        guard !songs.isEmpty else { return 0 }
        let totalBPM = songs.reduce(0) { $0 + $1.bpm }
        return Double(totalBPM) / Double(songs.count)
    }
    
    var bpmRange: (min: Int, max: Int)? {
        guard !songs.isEmpty else { return nil }
        let bpms = songs.map { $0.bpm }
        return (min: bpms.min() ?? 0, max: bpms.max() ?? 0)
    }
    
    var estimatedDuration: TimeInterval {
        // Estimate 3 minutes per song as default, could be improved with actual song durations
        return TimeInterval(songs.count * 180)
    }
    
    var formattedDuration: String {
        let minutes = Int(estimatedDuration) / 60
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        
        if hours > 0 {
            return "\(hours)h \(remainingMinutes)m"
        } else {
            return "\(minutes) min"
        }
    }
    
    var isValid: Bool {
        return !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // Get songs in a specific BPM range
    func songs(inBPMRange range: ClosedRange<Int>) -> [Song] {
        return songs.filter { range.contains($0.bpm) }
    }
    
    // Get songs with specific time signature
    func songs(withTimeSignature numerator: Int, denominator: Int) -> [Song] {
        return songs.filter { $0.timeSignatureNumerator == numerator && $0.timeSignatureDenominator == denominator }
    }
}

// MARK: - Setlist Manager
class SetlistManager: ObservableObject {
    @Published var setlists: [Setlist] = []
    @Published var currentSetlist: Setlist?
    @Published var currentSongIndex: Int = 0
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let userDefaults = UserDefaults.standard
    private let setlistsKey = "saved_setlists"
    private let currentSetlistKey = "current_setlist_id"
    private let currentSongIndexKey = "current_song_index"
    
    // Queue for background operations
    private let backgroundQueue = DispatchQueue(label: "setlist.manager.background", qos: .utility)
    
    init() {
        loadSetlists()
        loadCurrentSetlistState()
    }
    
    // MARK: - Setlist Management
    
    @MainActor
    func createSetlist(name: String, description: String = "", color: String = "blue") -> Setlist? {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedName.isEmpty else {
            errorMessage = "Setlist name cannot be empty"
            return nil
        }
        
        guard !setlists.contains(where: { $0.name.lowercased() == trimmedName.lowercased() }) else {
            errorMessage = "A setlist with this name already exists"
            return nil
        }
        
        let newSetlist = Setlist(name: trimmedName, description: description, color: color)
        setlists.append(newSetlist)
        saveSetlists()
        return newSetlist
    }
    
    @MainActor
    func updateSetlist(_ setlist: Setlist) {
        guard let index = setlists.firstIndex(where: { $0.id == setlist.id }) else {
            errorMessage = "Setlist not found"
            return
        }
        
        var updatedSetlist = setlist
        updatedSetlist.updateLastModified()
        setlists[index] = updatedSetlist
        
        // Update current setlist if it's the same one
        if currentSetlist?.id == setlist.id {
            currentSetlist = updatedSetlist
        }
        
        saveSetlists()
        saveCurrentSetlistState()
    }
    
    @MainActor
    func deleteSetlist(_ setlist: Setlist) {
        setlists.removeAll { $0.id == setlist.id }
        
        // Clear current setlist if it was deleted
        if currentSetlist?.id == setlist.id {
            currentSetlist = nil
            currentSongIndex = 0
        }
        
        saveSetlists()
        saveCurrentSetlistState()
    }
    
    @MainActor
    func duplicateSetlist(_ setlist: Setlist) -> Setlist? {
        let copyName = generateUniqueName(baseName: "\(setlist.name) Copy")
        let newSetlist = Setlist(
            name: copyName,
            songs: setlist.songs,
            description: setlist.description,
            color: setlist.color
        )
        setlists.append(newSetlist)
        saveSetlists()
        return newSetlist
    }
    
    // MARK: - Song Management
    
    @MainActor
    func addSong(to setlist: Setlist, song: Song) {
        guard let index = setlists.firstIndex(where: { $0.id == setlist.id }) else {
            errorMessage = "Setlist not found"
            return
        }
        
        guard song.isValid else {
            errorMessage = "Invalid song data"
            return
        }
        
        var updatedSong = song
        updatedSong.updateLastModified()
        setlists[index].songs.append(updatedSong)
        setlists[index].updateLastModified()
        
        if currentSetlist?.id == setlist.id {
            currentSetlist = setlists[index]
        }
        
        saveSetlists()
        saveCurrentSetlistState()
    }
    
    @MainActor
    func updateSong(in setlist: Setlist, song: Song) {
        guard let setlistIndex = setlists.firstIndex(where: { $0.id == setlist.id }),
              let songIndex = setlists[setlistIndex].songs.firstIndex(where: { $0.id == song.id }) else {
            errorMessage = "Song or setlist not found"
            return
        }
        
        guard song.isValid else {
            errorMessage = "Invalid song data"
            return
        }
        
        var updatedSong = song
        updatedSong.updateLastModified()
        setlists[setlistIndex].songs[songIndex] = updatedSong
        setlists[setlistIndex].updateLastModified()
        
        if currentSetlist?.id == setlist.id {
            currentSetlist = setlists[setlistIndex]
        }
        
        saveSetlists()
        saveCurrentSetlistState()
    }
    
    @MainActor
    func deleteSong(from setlist: Setlist, song: Song) {
        guard let setlistIndex = setlists.firstIndex(where: { $0.id == setlist.id }) else {
            errorMessage = "Setlist not found"
            return
        }
        
        setlists[setlistIndex].songs.removeAll { $0.id == song.id }
        setlists[setlistIndex].updateLastModified()
        
        if currentSetlist?.id == setlist.id {
            currentSetlist = setlists[setlistIndex]
            // Adjust current song index if necessary
            if currentSongIndex >= setlists[setlistIndex].songs.count {
                currentSongIndex = max(0, setlists[setlistIndex].songs.count - 1)
            }
        }
        
        saveSetlists()
        saveCurrentSetlistState()
    }
    
    @MainActor
    func moveSongs(in setlist: Setlist, from source: IndexSet, to destination: Int) {
        guard let index = setlists.firstIndex(where: { $0.id == setlist.id }) else {
            errorMessage = "Setlist not found"
            return
        }
        
        setlists[index].songs.move(fromOffsets: source, toOffset: destination)
        setlists[index].updateLastModified()
        
        if currentSetlist?.id == setlist.id {
            currentSetlist = setlists[index]
            // Update current song index if the current song was moved
            if let sourceIndex = source.first, sourceIndex == currentSongIndex {
                currentSongIndex = destination > sourceIndex ? destination - 1 : destination
            }
        }
        
        saveSetlists()
        saveCurrentSetlistState()
    }
    
    // MARK: - Current Setlist Navigation
    
    @MainActor
    func setCurrentSetlist(_ setlist: Setlist?) {
        currentSetlist = setlist
        currentSongIndex = 0
        saveCurrentSetlistState()
    }
    
    @MainActor
    func setCurrentSong(index: Int) {
        guard let setlist = currentSetlist, index >= 0 && index < setlist.songs.count else {
            errorMessage = "Invalid song index"
            return
        }
        currentSongIndex = index
        saveCurrentSetlistState()
    }
    
    @MainActor
    func nextSong() -> Bool {
        guard let setlist = currentSetlist, currentSongIndex < setlist.songs.count - 1 else {
            return false
        }
        currentSongIndex += 1
        saveCurrentSetlistState()
        return true
    }
    
    @MainActor
    func previousSong() -> Bool {
        guard currentSongIndex > 0 else {
            return false
        }
        currentSongIndex -= 1
        saveCurrentSetlistState()
        return true
    }
    
    var currentSong: Song? {
        guard let setlist = currentSetlist,
              currentSongIndex >= 0 && currentSongIndex < setlist.songs.count else {
            return nil
        }
        return setlist.songs[currentSongIndex]
    }
    
    var hasNextSong: Bool {
        guard let setlist = currentSetlist else { return false }
        return currentSongIndex < setlist.songs.count - 1
    }
    
    var hasPreviousSong: Bool {
        return currentSongIndex > 0
    }
    
    // MARK: - Persistence
    
    private func saveSetlists() {
        backgroundQueue.async { [weak self] in
            guard let self = self else { return }
            
            do {
                let encoder = JSONEncoder()
                encoder.dateEncodingStrategy = .iso8601
                let encoded = try encoder.encode(self.setlists)
                
                DispatchQueue.main.async {
                    self.userDefaults.set(encoded, forKey: self.setlistsKey)
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to save setlists: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func loadSetlists() {
        isLoading = true
        
        backgroundQueue.async { [weak self] in
            guard let self = self else { return }
            
            defer {
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
            
            guard let data = self.userDefaults.data(forKey: self.setlistsKey) else {
                return // No saved data
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let decodedSetlists = try decoder.decode([Setlist].self, from: data)
                
                DispatchQueue.main.async {
                    self.setlists = decodedSetlists
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to load setlists: \(error.localizedDescription)"
                    // Attempt to load with fallback decoder
                    self.loadSetlistsWithFallback(data: data)
                }
            }
        }
    }
    
    private func loadSetlistsWithFallback(data: Data) {
        do {
            // Try with default date decoding strategy as fallback
            let decoder = JSONDecoder()
            let decodedSetlists = try decoder.decode([Setlist].self, from: data)
            setlists = decodedSetlists
            errorMessage = nil
        } catch {
            errorMessage = "Failed to load setlists with fallback: \(error.localizedDescription)"
        }
    }
    
    private func saveCurrentSetlistState() {
        if let currentSetlist = currentSetlist {
            userDefaults.set(currentSetlist.id.uuidString, forKey: currentSetlistKey)
        } else {
            userDefaults.removeObject(forKey: currentSetlistKey)
        }
        userDefaults.set(currentSongIndex, forKey: currentSongIndexKey)
    }
    
    private func loadCurrentSetlistState() {
        if let setlistIdString = userDefaults.string(forKey: currentSetlistKey),
           let setlistId = UUID(uuidString: setlistIdString),
           let setlist = setlists.first(where: { $0.id == setlistId }) {
            currentSetlist = setlist
        }
        
        currentSongIndex = userDefaults.integer(forKey: currentSongIndexKey)
        
        // Validate current song index
        if let setlist = currentSetlist, currentSongIndex >= setlist.songs.count {
            currentSongIndex = max(0, setlist.songs.count - 1)
        }
    }
    
    // MARK: - Helper Methods
    
    func applySongToMetronome(_ song: Song, metronome: MetronomeEngine) {
        metronome.bpm = song.bpm
        metronome.updateTimeSignature(numerator: song.timeSignatureNumerator, denominator: song.timeSignatureDenominator)
        metronome.updateSubdivision(to: song.subdivisionMultiplier)
    }
    
    func createSongFromMetronome(_ metronome: MetronomeEngine, title: String = "", artist: String = "", notes: String = "") -> Song {
        return Song(
            title: title,
            artist: artist,
            bpm: metronome.bpm,
            timeSignatureNumerator: metronome.beatsPerMeasure,
            timeSignatureDenominator: metronome.beatUnit,
            subdivisionMultiplier: metronome.subdivisionMultiplier,
            notes: notes
        )
    }
    
    private func generateUniqueName(baseName: String) -> String {
        var counter = 1
        var candidateName = baseName
        
        while setlists.contains(where: { $0.name.lowercased() == candidateName.lowercased() }) {
            counter += 1
            candidateName = "\(baseName) \(counter)"
        }
        
        return candidateName
    }
    
    // MARK: - Search and Filter
    
    func searchSongs(query: String) -> [Song] {
        guard !query.isEmpty else { return [] }
        
        let lowercaseQuery = query.lowercased()
        var allSongs: [Song] = []
        
        for setlist in setlists {
            allSongs.append(contentsOf: setlist.songs)
        }
        
        return allSongs.filter { song in
            song.title.lowercased().contains(lowercaseQuery) ||
            song.artist.lowercased().contains(lowercaseQuery) ||
            song.notes.lowercased().contains(lowercaseQuery)
        }
    }
    
    func filterSetlists(query: String) -> [Setlist] {
        guard !query.isEmpty else { return setlists }
        
        let lowercaseQuery = query.lowercased()
        return setlists.filter { setlist in
            setlist.name.lowercased().contains(lowercaseQuery) ||
            setlist.description.lowercased().contains(lowercaseQuery)
        }
    }
    
    // MARK: - Statistics
    
    var totalSongs: Int {
        return setlists.reduce(0) { $0 + $1.songCount }
    }
    
    var averageSetlistSize: Double {
        guard !setlists.isEmpty else { return 0 }
        return Double(totalSongs) / Double(setlists.count)
    }
    
    var mostCommonTimeSignature: (numerator: Int, denominator: Int)? {
        var timeSignatureCounts: [String: Int] = [:]
        
        for setlist in setlists {
            for song in setlist.songs {
                let key = "\(song.timeSignatureNumerator)/\(song.timeSignatureDenominator)"
                timeSignatureCounts[key, default: 0] += 1
            }
        }
        
        guard let mostCommon = timeSignatureCounts.max(by: { $0.value < $1.value }) else {
            return nil
        }
        
        let components = mostCommon.key.split(separator: "/")
        guard components.count == 2,
              let numerator = Int(components[0]),
              let denominator = Int(components[1]) else {
            return nil
        }
        
        return (numerator: numerator, denominator: denominator)
    }
}
