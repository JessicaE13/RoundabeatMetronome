import SwiftUI

// MARK: - Edit Song View
struct EditSongView: View {
    let song: Song
    let setlist: Setlist
    @ObservedObject var setlistManager: SetlistManager
    @ObservedObject var metronome: MetronomeEngine
    @Environment(\.presentationMode) var presentationMode
    
    @State private var title: String
    @State private var artist: String
    @State private var bpm: Int
    @State private var timeSignatureNumerator: Int
    @State private var timeSignatureDenominator: Int
    @State private var subdivisionMultiplier: Double
    @State private var notes: String
    
    @State private var showingBPMPicker = false
    @State private var showingTimeSignaturePicker = false
    @State private var showingSubdivisionPicker = false
    @State private var showingDeleteAlert = false
    
    // Get screen dimensions directly
    private var screenWidth: CGFloat {
        UIScreen.main.bounds.width
    }
    
    // Check if device is iPad
    private var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    init(song: Song, setlist: Setlist, setlistManager: SetlistManager, metronome: MetronomeEngine) {
        self.song = song
        self.setlist = setlist
        self.setlistManager = setlistManager
        self.metronome = metronome
        
        // Initialize state with song values
        _title = State(initialValue: song.title)
        _artist = State(initialValue: song.artist)
        _bpm = State(initialValue: song.bpm)
        _timeSignatureNumerator = State(initialValue: song.timeSignatureNumerator)
        _timeSignatureDenominator = State(initialValue: song.timeSignatureDenominator)
        _subdivisionMultiplier = State(initialValue: song.subdivisionMultiplier)
        _notes = State(initialValue: song.notes)
    }
    
    var body: some View {
        Form {
            // Basic Info Section
            Section("Song Information") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Title")
                        .font(.system(size: labelSize, weight: .medium))
                        .foregroundColor(.primary)
                    
                    TextField("Song title", text: $title)
                        .font(.system(size: textFieldSize))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Artist")
                        .font(.system(size: labelSize, weight: .medium))
                        .foregroundColor(.primary)
                    
                    TextField("Artist name (optional)", text: $artist)
                        .font(.system(size: textFieldSize))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            }
            
            // Musical Settings Section
            Section("Musical Settings") {
                // BPM
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Tempo")
                            .font(.system(size: labelSize, weight: .medium))
                            .foregroundColor(.primary)
                        
                        Text("\(bpm) BPM")
                            .font(.system(size: valueSize, weight: .semibold))
                            .foregroundColor(.accentColor)
                    }
                    
                    Spacer()
                    
                    Button("Change") {
                        showingBPMPicker = true
                    }
                    .font(.system(size: buttonSize, weight: .medium))
                    .foregroundColor(.accentColor)
                }
                
                // Time Signature
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Time Signature")
                            .font(.system(size: labelSize, weight: .medium))
                            .foregroundColor(.primary)
                        
                        Text("\(timeSignatureNumerator)/\(timeSignatureDenominator)")
                            .font(.system(size: valueSize, weight: .semibold))
                            .foregroundColor(.accentColor)
                    }
                    
                    Spacer()
                    
                    Button("Change") {
                        showingTimeSignaturePicker = true
                    }
                    .font(.system(size: buttonSize, weight: .medium))
                    .foregroundColor(.accentColor)
                }
                
                // Subdivision
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Subdivision")
                            .font(.system(size: labelSize, weight: .medium))
                            .foregroundColor(.primary)
                        
                        Text(subdivisionSymbol)
                            .font(.system(size: valueSize, weight: .semibold))
                            .foregroundColor(.accentColor)
                    }
                    
                    Spacer()
                    
                    Button("Change") {
                        showingSubdivisionPicker = true
                    }
                    .font(.system(size: buttonSize, weight: .medium))
                    .foregroundColor(.accentColor)
                }
            }
            
            // Notes Section
            Section("Notes") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Additional Notes")
                        .font(.system(size: labelSize, weight: .medium))
                        .foregroundColor(.primary)
                    
                    TextField("Performance notes, key changes, etc. (optional)", text: $notes, axis: .vertical)
                        .font(.system(size: textFieldSize))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(3...6)
                }
            }
            
            // Actions Section
            Section("Actions") {
                Button(action: {
                    showingDeleteAlert = true
                }) {
                    HStack {
                        Image(systemName: "trash")
                            .font(.system(size: actionIconSize, weight: .medium))
                        
                        Text("Delete Song")
                            .font(.system(size: actionTextSize, weight: .medium))
                        
                        Spacer()
                    }
                    .foregroundColor(.red)
                }
            }
        }
        .navigationTitle("Edit Song")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    saveSong()
                }
                .font(.system(size: toolbarButtonSize, weight: .medium))
                .fontWeight(.semibold)
                .disabled(!canSaveSong)
            }
        }
        .sheet(isPresented: $showingBPMPicker) {
            BPMPickerView(currentBPM: $bpm)
        }
        .sheet(isPresented: $showingTimeSignaturePicker) {
            TimeSignaturePickerModalView(
                numerator: $timeSignatureNumerator,
                denominator: $timeSignatureDenominator
            )
        }
        .sheet(isPresented: $showingSubdivisionPicker) {
            SubdivisionPickerModalView(subdivision: $subdivisionMultiplier)
        }
        .alert("Delete Song", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteSong()
            }
        } message: {
            Text("Are you sure you want to delete \"\(song.title.isEmpty ? "Untitled Song" : song.title)\"? This action cannot be undone.")
        }
    }
    
    // MARK: - Computed Properties
    
    private var canSaveSong: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private var subdivisionSymbol: String {
        switch subdivisionMultiplier {
        case 1.0:
            return "♩ Quarter Notes"
        case 2.0:
            return "♫ Eighth Notes"
        case 3.0:
            return "♩. Triplets"
        case 4.0:
            return "♬ Sixteenth Notes"
        default:
            return "♩ Quarter Notes"
        }
    }
    
    private var currentSong: Song {
        Song(
            title: title,
            artist: artist,
            bpm: bpm,
            timeSignatureNumerator: timeSignatureNumerator,
            timeSignatureDenominator: timeSignatureDenominator,
            subdivisionMultiplier: subdivisionMultiplier,
            notes: notes
        )
    }
    
    // MARK: - Actions
    
    private func saveSong() {
        var updatedSong = song
        updatedSong.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        updatedSong.artist = artist.trimmingCharacters(in: .whitespacesAndNewlines)
        updatedSong.bpm = bpm
        updatedSong.timeSignatureNumerator = timeSignatureNumerator
        updatedSong.timeSignatureDenominator = timeSignatureDenominator
        updatedSong.subdivisionMultiplier = subdivisionMultiplier
        updatedSong.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        
        setlistManager.updateSong(in: setlist, song: updatedSong)
        
        // Provide haptic feedback
        if #available(iOS 10.0, *) {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
        
        presentationMode.wrappedValue.dismiss()
    }
    
    private func deleteSong() {
        setlistManager.deleteSong(from: setlist, song: song)
        
        // Provide haptic feedback
        if #available(iOS 10.0, *) {
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
        }
        
        presentationMode.wrappedValue.dismiss()
    }
    
    private func loadFromMetronome() {
        bpm = metronome.bpm
        timeSignatureNumerator = metronome.beatsPerMeasure
        timeSignatureDenominator = metronome.beatUnit
        subdivisionMultiplier = metronome.subdivisionMultiplier
        
        // Provide haptic feedback
        if #available(iOS 10.0, *) {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
    }
    
    // MARK: - Responsive Properties
    
    private var labelSize: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 16 :
                   screenWidth <= 834 ? 17 :
                   screenWidth <= 1024 ? 18 :
                   19
        } else {
            return screenWidth <= 320 ? 14 :
                   screenWidth <= 375 ? 15 :
                   screenWidth <= 393 ? 16 :
                   17
        }
    }
    
    private var textFieldSize: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 16 :
                   screenWidth <= 834 ? 17 :
                   screenWidth <= 1024 ? 18 :
                   19
        } else {
            return screenWidth <= 320 ? 14 :
                   screenWidth <= 375 ? 15 :
                   screenWidth <= 393 ? 16 :
                   17
        }
    }
    
    private var valueSize: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 16 :
                   screenWidth <= 834 ? 17 :
                   screenWidth <= 1024 ? 18 :
                   19
        } else {
            return screenWidth <= 320 ? 14 :
                   screenWidth <= 375 ? 15 :
                   screenWidth <= 393 ? 16 :
                   17
        }
    }
    
    private var buttonSize: CGFloat {
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
    
    private var actionIconSize: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 16 :
                   screenWidth <= 834 ? 17 :
                   screenWidth <= 1024 ? 18 :
                   19
        } else {
            return screenWidth <= 320 ? 14 :
                   screenWidth <= 375 ? 15 :
                   screenWidth <= 393 ? 16 :
                   17
        }
    }
    
    private var actionTextSize: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 16 :
                   screenWidth <= 834 ? 17 :
                   screenWidth <= 1024 ? 18 :
                   19
        } else {
            return screenWidth <= 320 ? 14 :
                   screenWidth <= 375 ? 15 :
                   screenWidth <= 393 ? 16 :
                   17
        }
    }
    
    private var toolbarButtonSize: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 16 :
                   screenWidth <= 834 ? 17 :
                   screenWidth <= 1024 ? 18 :
                   19
        } else {
            return screenWidth <= 320 ? 14 :
                   screenWidth <= 375 ? 15 :
                   screenWidth <= 393 ? 16 :
                   17
        }
    }
}

#Preview {
    NavigationView {
        EditSongView(
            song: Song(title: "Sample Song", artist: "Sample Artist", bpm: 120),
            setlist: Setlist(name: "Sample Setlist"),
            setlistManager: SetlistManager(),
            metronome: MetronomeEngine()
        )
    }
}
                    setlistManager.applySongToMetronome(currentSong, metronome: metronome)
                    if #available(iOS 10.0, *) {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }
                }) {
                    HStack {
                        Image(systemName: "arrow.down.circle")
                            .font(.system(size: actionIconSize, weight: .medium))
                        
                        Text("Load to Metronome")
                            .font(.system(size: actionTextSize, weight: .medium))
                        
                        Spacer()
                    }
                    .foregroundColor(.accentColor)
                }
                
                Button(action: loadFromMetronome) {
                    HStack {
                        Image(systemName: "arrow.up.circle")
                            .font(.system(size: actionIconSize, weight: .medium))
                        
                        Text("Update from Current Metronome")
                            .font(.system(size: actionTextSize, weight: .medium))
                        
                        Spacer()
                    }
                    .foregroundColor(.accentColor)
                }
                
                Button(action: {
