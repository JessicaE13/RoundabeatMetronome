//
//  SetlistModel.swift
//  RoundabeatMetronome
//

import SwiftUI
import Foundation

// MARK: - Setlist Model
struct Setlist: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var songIds: [UUID] // References to Song IDs
    var dateCreated: Date
    var dateModified: Date
    var notes: String
    
    init(name: String, notes: String = "") {
        self.id = UUID()
        self.name = name
        self.songIds = []
        self.dateCreated = Date()
        self.dateModified = Date()
        self.notes = notes
    }
    
    // Helper methods
    mutating func addSong(_ songId: UUID) {
        if !songIds.contains(songId) {
            songIds.append(songId)
            dateModified = Date()
        }
    }
    
    mutating func removeSong(_ songId: UUID) {
        songIds.removeAll { $0 == songId }
        dateModified = Date()
    }
    
    mutating func reorderSongs(from sourceIndex: Int, to destinationIndex: Int) {
        guard sourceIndex < songIds.count && destinationIndex < songIds.count else { return }
        let movedSong = songIds.remove(at: sourceIndex)
        songIds.insert(movedSong, at: destinationIndex)
        dateModified = Date()
    }
    
    mutating func updateName(_ newName: String) {
        name = newName
        dateModified = Date()
    }
    
    mutating func updateNotes(_ newNotes: String) {
        notes = newNotes
        dateModified = Date()
    }
}

// MARK: - Setlist Manager
class SetlistManager: ObservableObject {
    @Published var setlists: [Setlist] = []
    @Published var searchText: String = ""
    @Published var sortBy: SortOption = .dateModified
    @Published var sortAscending: Bool = false
    
    private let userDefaultsKey = "SavedSetlists"
    
    enum SortOption: String, CaseIterable {
        case name = "Name"
        case dateCreated = "Date Created"
        case dateModified = "Date Modified"
        case songCount = "Song Count"
    }
    
    init() {
        loadSetlists()
    }
    
    
    // Replace the moveSetlist method in SetlistManager with this improved version:

    func moveSetlist(from source: IndexSet, to destination: Int) {
        // If we're working with filtered results, we need to map indices back to the original array
        let filteredSetlists = self.filteredSetlists
        
        guard let sourceIndex = source.first,
              sourceIndex < filteredSetlists.count,
              destination <= filteredSetlists.count else {
            return
        }
        
        // Get the setlist being moved
        let setlistToMove = filteredSetlists[sourceIndex]
        
        // Find the original indices in the main setlists array
        guard let originalSourceIndex = setlists.firstIndex(where: { $0.id == setlistToMove.id }) else {
            return
        }
        
        // If there are filters applied, we need to handle this differently
        if searchText.isEmpty && sortBy == .dateModified && !sortAscending {
            // No filtering/sorting applied, direct move
            setlists.move(fromOffsets: source, toOffset: destination)
        } else {
            // Filtering/sorting is applied, we need to reorder based on the filtered view
            let destinationSetlist = destination < filteredSetlists.count ? filteredSetlists[destination] : nil
            
            // Remove from original position
            setlists.remove(at: originalSourceIndex)
            
            // Find where to insert in the original array
            var insertIndex = setlists.count
            if let destinationSetlist = destinationSetlist,
               let originalDestinationIndex = setlists.firstIndex(where: { $0.id == destinationSetlist.id }) {
                insertIndex = destination < sourceIndex ? originalDestinationIndex : originalDestinationIndex
            }
            
            // Insert at new position
            setlists.insert(setlistToMove, at: min(insertIndex, setlists.count))
        }
        
        saveSetlists()
    }

    // MARK: - Core CRUD Operations
    
    func createSetlist(_ setlist: Setlist) {
        setlists.append(setlist)
        saveSetlists()
    }
    
    func updateSetlist(_ setlist: Setlist) {
        if let index = setlists.firstIndex(where: { $0.id == setlist.id }) {
            setlists[index] = setlist
            saveSetlists()
        }
    }
    
    func deleteSetlist(_ setlist: Setlist) {
        setlists.removeAll { $0.id == setlist.id }
        saveSetlists()
    }
    
    func duplicateSetlist(_ setlist: Setlist) {
        var newSetlist = setlist
        newSetlist.id = UUID()
        newSetlist.name = "\(setlist.name) Copy"
        newSetlist.dateCreated = Date()
        newSetlist.dateModified = Date()
        createSetlist(newSetlist)
    }
    
    // MARK: - Song Management
    
    func addSongToSetlist(songId: UUID, setlistId: UUID) {
        if let index = setlists.firstIndex(where: { $0.id == setlistId }) {
            setlists[index].addSong(songId)
            saveSetlists()
        }
    }
    
    func removeSongFromSetlist(songId: UUID, setlistId: UUID) {
        if let index = setlists.firstIndex(where: { $0.id == setlistId }) {
            setlists[index].removeSong(songId)
            saveSetlists()
        }
    }
    
    func reorderSongsInSetlist(setlistId: UUID, from sourceIndex: Int, to destinationIndex: Int) {
        if let index = setlists.firstIndex(where: { $0.id == setlistId }) {
            setlists[index].reorderSongs(from: sourceIndex, to: destinationIndex)
            saveSetlists()
        }
    }
    
    // MARK: - Query Methods
    
    func getSongsForSetlist(_ setlist: Setlist, from songManager: SongManager) -> [Song] {
        return setlist.songIds.compactMap { songId in
            songManager.songs.first { $0.id == songId }
        }
    }
    
    func getSetlistsContainingSong(_ songId: UUID) -> [Setlist] {
        return setlists.filter { $0.songIds.contains(songId) }
    }
    
    var filteredSetlists: [Setlist] {
        var filtered = setlists
        
        // Filter by search text
        if !searchText.isEmpty {
            filtered = filtered.filter { setlist in
                setlist.name.localizedCaseInsensitiveContains(searchText) ||
                setlist.notes.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Sort
        switch sortBy {
        case .name:
            filtered.sort { sortAscending ? $0.name < $1.name : $0.name > $1.name }
        case .dateCreated:
            filtered.sort { sortAscending ? $0.dateCreated < $1.dateCreated : $0.dateCreated > $1.dateCreated }
        case .dateModified:
            filtered.sort { sortAscending ? $0.dateModified < $1.dateModified : $0.dateModified > $1.dateModified }
        case .songCount:
            filtered.sort { sortAscending ? $0.songIds.count < $1.songIds.count : $0.songIds.count > $1.songIds.count }
        }
        
        return filtered
    }
    
    // MARK: - Persistence
    
    private func saveSetlists() {
        if let encoded = try? JSONEncoder().encode(setlists) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    private func loadSetlists() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode([Setlist].self, from: data) {
            setlists = decoded
        }
    }
    
    // MARK: - Sample Data
    
    func createSampleSetlists(with songManager: SongManager) {
        guard setlists.isEmpty && !songManager.songs.isEmpty else { return }
        
        // Create a sample setlist with a few songs
        var rockSetlist = Setlist(name: "Rock Classics", notes: "High energy rock songs")
        let availableSongs = Array(songManager.songs.prefix(3))
        for song in availableSongs {
            rockSetlist.addSong(song.id)
        }
        createSetlist(rockSetlist)
        
        // Create another sample setlist
        var practiceSetlist = Setlist(name: "Practice Session", notes: "Songs to practice this week")
        if songManager.songs.count > 1 {
            practiceSetlist.addSong(songManager.songs[1].id)
        }
        createSetlist(practiceSetlist)
    }
}
