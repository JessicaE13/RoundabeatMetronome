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
                    
                    TimeSignaturePicker(
                        numerator: $timeSignatureNumerator,
                        denominator: $timeSignatureDenominator
                    )
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

// MARK: - Time Signature Picker Component
struct TimeSignaturePicker: View {
    @Binding var numerator: Int
    @Binding var denominator: Int
    @State private var showingPicker = false
    
    var body: some View {
        HStack {
            Text("Time Signature")
            Spacer()
            
            Button(action: {
                showingPicker = true
            }) {
                Text("\(numerator)/\(denominator)")
                    .foregroundColor(.primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(.systemGray6))
                    .cornerRadius(6)
            }
            .sheet(isPresented: $showingPicker) {
                TimeSignaturePickerSheet(
                    numerator: $numerator,
                    denominator: $denominator,
                    isPresented: $showingPicker
                )
            }
        }
    }
}

// MARK: - Time Signature Picker Sheet
struct TimeSignaturePickerSheet: View {
    @Binding var numerator: Int
    @Binding var denominator: Int
    @Binding var isPresented: Bool
    
    @State private var tempNumerator: Int
    @State private var tempDenominator: Int
    
    init(numerator: Binding<Int>, denominator: Binding<Int>, isPresented: Binding<Bool>) {
        self._numerator = numerator
        self._denominator = denominator
        self._isPresented = isPresented
        self._tempNumerator = State(initialValue: numerator.wrappedValue)
        self._tempDenominator = State(initialValue: denominator.wrappedValue)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Spacer()
                Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 24)
                .padding(.trailing, 16)
            }
            
            Text("Select Time Signature")
                .font(.title2)
                .fontWeight(.semibold)
            
            HStack(spacing: 20) {
                VStack {
                    Text("Beats")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Picker("Beats", selection: $tempNumerator) {
                        ForEach(1...32, id: \.self) { num in
                            Text("\(num)")
                                .font(.title)
                                .tag(num)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 80, height: 120)
                }
                
                Text("/")
                    .font(.largeTitle)
                    .foregroundColor(.secondary)
                
                VStack {
                    Text("Note Value")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Picker("Note Value", selection: $tempDenominator) {
                        ForEach([1, 2, 4, 8, 16, 32], id: \.self) { denom in
                            Text("\(denom)")
                                .font(.title)
                                .tag(denom)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 80, height: 120)
                }
            }
            
            Button(action: {
                if #available(iOS 10.0, *) {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }
                numerator = tempNumerator
                denominator = tempDenominator
                isPresented = false
            }) {
                Text("SET TIME")
                    .font(.system(size: 14, weight: .medium))
                    .kerning(1)
                    .foregroundColor(Color.white.opacity(0.9))
                    .frame(width: 180)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.15))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(LinearGradient(
                                        gradient: Gradient(colors: [Color.white.opacity(0.3), Color.white.opacity(0.1)]),
                                        startPoint: .top,
                                        endPoint: .bottom), lineWidth: 1)
                            )
                    )
            }
            .padding(.horizontal)
            
            Spacer().frame(height: 10)
        }
        .presentationDetents([.height(320)])
    }
}
