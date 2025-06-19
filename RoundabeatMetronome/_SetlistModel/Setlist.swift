import Foundation
import SwiftUI

// MARK: - Song Model
struct Song: Identifiable, Codable, Equatable {
    let id = UUID()
    var title: String
    var artist: String
    var bpm: Int
    var timeSignatureNumerator: Int
    var timeSignatureDenominator: Int
    var subdivisionMultiplier: Double
    var notes: String
    var isPlaying: Bool = false
    
    init(title: String = "", artist: String = "", bpm: Int = 120, timeSignatureNumerator: Int = 4, timeSignatureDenominator: Int = 4, subdivisionMultiplier: Double = 1.0, notes: String = "") {
        self.title = title
        self.artist = artist
        self.bpm = max(40, min(400, bpm))
        self.timeSignatureNumerator = timeSignatureNumerator
        self.timeSignatureDenominator = timeSignatureDenominator
        self.subdivisionMultiplier = subdivisionMultiplier
        self.notes = notes
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
}

// MARK: - Setlist Model
struct Setlist: Identifiable, Codable, Equatable {
    let id = UUID()
    var name: String
    var songs: [Song]
    var createdDate: Date
    var lastModified: Date
    
    init(name: String = "", songs: [Song] = []) {
        self.name = name
        self.songs = songs
        self.createdDate = Date()
        self.lastModified = Date()
    }
    
    mutating func updateLastModified() {
        lastModified = Date()
    }
    
    var songCount: Int {
        return songs.count
    }
    
    var totalDuration: TimeInterval {
        // Estimate 3 minutes per song as default
        return TimeInterval(songs.count * 180)
    }
    
    var formattedDuration: String {
        let minutes = Int(totalDuration) / 60
        return "\(minutes) min"
    }
}

// MARK: - Setlist Manager
class SetlistManager: ObservableObject {
    @Published var setlists: [Setlist] = []
    @Published var currentSetlist: Setlist?
    @Published var currentSongIndex: Int = 0
    
    private let userDefaults = UserDefaults.standard
    private let setlistsKey = "saved_setlists"
    private let currentSetlistKey = "current_setlist_id"
    private let currentSongIndexKey = "current_song_index"
    
    init() {
        loadSetlists()
        loadCurrentSetlistState()
    }
    
    // MARK: - Setlist Management
    
    func createSetlist(name: String) -> Setlist {
        var newSetlist = Setlist(name: name)
        setlists.append(newSetlist)
        saveSetlists()
        return newSetlist
    }
    
    func updateSetlist(_ setlist: Setlist) {
        if let index = setlists.firstIndex(where: { $0.id == setlist.id }) {
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
    }
    
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
    
    func duplicateSetlist(_ setlist: Setlist) {
        var newSetlist = setlist
        newSetlist = Setlist(name: "\(setlist.name) Copy", songs: setlist.songs)
        setlists.append(newSetlist)
        saveSetlists()
    }
    
    // MARK: - Song Management
    
    func addSong(to setlist: Setlist, song: Song) {
        if let index = setlists.firstIndex(where: { $0.id == setlist.id }) {
            setlists[index].songs.append(song)
            setlists[index].updateLastModified()
            
            if currentSetlist?.id == setlist.id {
                currentSetlist = setlists[index]
            }
            
            saveSetlists()
            saveCurrentSetlistState()
        }
    }
    
    func updateSong(in setlist: Setlist, song: Song) {
        if let setlistIndex = setlists.firstIndex(where: { $0.id == setlist.id }),
           let songIndex = setlists[setlistIndex].songs.firstIndex(where: { $0.id == song.id }) {
            setlists[setlistIndex].songs[songIndex] = song
            setlists[setlistIndex].updateLastModified()
            
            if currentSetlist?.id == setlist.id {
                currentSetlist = setlists[setlistIndex]
            }
            
            saveSetlists()
            saveCurrentSetlistState()
        }
    }
    
    func deleteSong(from setlist: Setlist, song: Song) {
        if let setlistIndex = setlists.firstIndex(where: { $0.id == setlist.id }) {
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
    }
    
    func moveSongs(in setlist: Setlist, from source: IndexSet, to destination: Int) {
        if let index = setlists.firstIndex(where: { $0.id == setlist.id }) {
            setlists[index].songs.move(fromOffsets: source, toOffset: destination)
            setlists[index].updateLastModified()
            
            if currentSetlist?.id == setlist.id {
                currentSetlist = setlists[index]
            }
            
            saveSetlists()
            saveCurrentSetlistState()
        }
    }
    
    // MARK: - Current Setlist Navigation
    
    func setCurrentSetlist(_ setlist: Setlist?) {
        currentSetlist = setlist
        currentSongIndex = 0
        saveCurrentSetlistState()
    }
    
    func setCurrentSong(index: Int) {
        if let setlist = currentSetlist, index >= 0 && index < setlist.songs.count {
            currentSongIndex = index
            saveCurrentSetlistState()
        }
    }
    
    func nextSong() {
        if let setlist = currentSetlist, currentSongIndex < setlist.songs.count - 1 {
            currentSongIndex += 1
            saveCurrentSetlistState()
        }
    }
    
    func previousSong() {
        if currentSongIndex > 0 {
            currentSongIndex -= 1
            saveCurrentSetlistState()
        }
    }
    
    var currentSong: Song? {
        guard let setlist = currentSetlist,
              currentSongIndex < setlist.songs.count else {
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
        if let encoded = try? JSONEncoder().encode(setlists) {
            userDefaults.set(encoded, forKey: setlistsKey)
        }
    }
    
    private func loadSetlists() {
        if let data = userDefaults.data(forKey: setlistsKey),
           let decodedSetlists = try? JSONDecoder().decode([Setlist].self, from: data) {
            setlists = decodedSetlists
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
}
