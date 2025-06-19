//
//  AddEditSongView.swift
//  RoundabeatMetronome
//

import SwiftUI

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

#Preview {
    AddEditSongView(songManager: SongManager())
}
