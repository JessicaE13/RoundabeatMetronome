import SwiftUI
import AVFoundation

// MARK: - Metronome View
struct MetronomeView: View {
    @ObservedObject var metronome: MetronomeEngine
    @ObservedObject var songManager: SongManager
    
    // State for showing pickers - removed sound picker
    @State private var showingTimeSignaturePicker = false
    @State private var showingSubdivisionPicker = false
    @State private var showingNumberPad = false
    
    // Get screen dimensions directly
    private var screenWidth: CGFloat {
        UIScreen.main.bounds.width
    }
    
    // Check if device is iPad
    private var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    private var buttonFontSize: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 14 :
                   screenWidth <= 834 ? 16 :
                   screenWidth <= 1024 ? 18 :
                   20
        } else {
            return screenWidth <= 320 ? 10 :
                   screenWidth <= 375 ? 11 :
                   screenWidth <= 393 ? 12 :
                   13
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
//            // Show either tempo selector or selected song
//            if let selectedSong = songManager.currentlySelectedSong {
//                SelectedSongDisplayView(
//                    song: selectedSong,
//                    onClearSelection: {
//                        songManager.clearCurrentlySelectedSong()
//                    }
//                )
//            } else {
                TempoScrollView(
                    currentBPM: metronome.bpm,
                    onTempoChange: { newBPM in
                        metronome.bpm = newBPM
                    }
                )
         //   }
            
            Spacer()
            
            BPMView(
                metronome: metronome,
                showingNumberPad: $showingNumberPad
            )
            
      
            
            // BPM Label
            Text("BEATS PER MINUTE (BPM)")
                .font(.system(size: buttonFontSize, weight: .medium))
                .foregroundStyle(Color("Gray1"))
                .kerning(1.2)
                .padding(.top, 16)
            
            Spacer()
            
            UniformButtonsView(
                metronome: metronome,
                showingTimeSignaturePicker: $showingTimeSignaturePicker,
                showingSubdivisionPicker: $showingSubdivisionPicker
            )
            
            Spacer()
         
            LogoView()
                .padding(.top, 16)
  
            Spacer()
            
            //SwiftUIView()
           DialView(metronome: metronome)
            
            Spacer()
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, horizontalPadding)
        .padding(.top, topPadding) // Added top padding
        .overlay(
            // Modal Overlays - removed sound picker modal
            Group {
                // Time Signature Picker Modal
                if showingTimeSignaturePicker {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            showingTimeSignaturePicker = false
                        }
                    
                    TimeSignaturePickerView(
                        metronome: metronome,
                        isShowingPicker: $showingTimeSignaturePicker
                    )
                }
                
                // Subdivision Picker Modal
                if showingSubdivisionPicker {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            showingSubdivisionPicker = false
                        }
                    
                    SubdivisionPickerView(
                        metronome: metronome,
                        isShowingPicker: $showingSubdivisionPicker
                    )
                }
                
                // Number Pad Modal
                if showingNumberPad {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            showingNumberPad = false
                        }
                    
                    NumberPadView(
                        isShowingKeypad: $showingNumberPad,
                        currentTempo: Double(metronome.bpm),
                        onSubmit: { newBPM in
                            metronome.bpm = Int(newBPM)
                            // Clear selected song when BPM is manually changed
                            songManager.clearCurrentlySelectedSong()
                        }
                    )
                }
            }
        )
        .onChange(of: metronome.bpm) { oldValue, newValue in
            // If BPM changes and doesn't match the selected song, clear the selection
            if let selectedSong = songManager.currentlySelectedSong,
               selectedSong.bpm != newValue {
                songManager.clearCurrentlySelectedSong()
            }
        }
        .onChange(of: metronome.beatsPerMeasure) { oldValue, newValue in
            // If time signature changes and doesn't match the selected song, clear the selection
            if let selectedSong = songManager.currentlySelectedSong,
               selectedSong.timeSignature.numerator != newValue {
                songManager.clearCurrentlySelectedSong()
            }
        }
        .onChange(of: metronome.beatUnit) { oldValue, newValue in
            // If time signature changes and doesn't match the selected song, clear the selection
            if let selectedSong = songManager.currentlySelectedSong,
               selectedSong.timeSignature.denominator != newValue {
                songManager.clearCurrentlySelectedSong()
            }
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
    
    // Added responsive top padding
    private var topPadding: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 24 :
                   screenWidth <= 834 ? 28 :
                   screenWidth <= 1024 ? 32 :
                   36
        } else {
            return screenWidth <= 320 ? 16 :
                   screenWidth <= 375 ? 18 :
                   screenWidth <= 393 ? 20 :
                   22
        }
    }
}

// MARK: - Selected Song Display View
struct SelectedSongDisplayView: View {
    let song: Song
    let onClearSelection: () -> Void
    
    // Get screen dimensions directly
    private var screenWidth: CGFloat {
        UIScreen.main.bounds.width
    }
    
    // Check if device is iPad
    private var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // Song info card
            HStack {
                // Music note icon
                Image(systemName: "music.note")
                    .font(.system(size: iconSize, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: iconFrameSize, height: iconFrameSize)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.15))
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    // Song title
                    Text(song.title)
                        .font(.system(size: titleFontSize, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    // Artist (if available)
                    if !song.artist.isEmpty {
                        Text(song.artist)
                            .font(.system(size: artistFontSize, weight: .medium))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    
                    // Song details
                    HStack(spacing: 12) {
                        // BPM
                        HStack(spacing: 4) {
                            Image(systemName: "metronome")
                                .font(.system(size: detailIconSize))
                                .foregroundColor(.white)
                            Text("\(song.bpm) BPM")
                                .font(.system(size: detailFontSize, weight: .medium))
                                .foregroundColor(.white)
                        }
                        
                        // Time signature
                        HStack(spacing: 4) {
                            Image(systemName: "music.note.list")
                                .font(.system(size: detailIconSize))
                                .foregroundColor(.white)
                            Text("\(song.timeSignature.displayString)")
                                .font(.system(size: detailFontSize, weight: .medium))
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                    }
                }
                
                Spacer()
                
                // Clear button
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        onClearSelection()
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: clearButtonSize, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(cardPadding)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.25), lineWidth: 1.5)
                    )
            )
            
            // Status indicator
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: statusIconSize))
                    .foregroundColor(.white)
                
                Text("SONG APPLIED")
                    .font(.system(size: statusTextSize, weight: .bold))
                    .foregroundColor(.white)
                    .kerning(1.0)
                
                Spacer()
            }
        }
        .frame(height: selectedSongViewHeight)
    }
    
    // MARK: - Responsive Properties
    
    private var iconSize: CGFloat {
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
    
    private var iconFrameSize: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 40 :
                   screenWidth <= 834 ? 44 :
                   screenWidth <= 1024 ? 48 :
                   52
        } else {
            return screenWidth <= 320 ? 32 :
                   screenWidth <= 375 ? 36 :
                   screenWidth <= 393 ? 40 :
                   44
        }
    }
    
    private var titleFontSize: CGFloat {
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
    
    private var artistFontSize: CGFloat {
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
    
    private var detailIconSize: CGFloat {
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
    
    private var clearButtonSize: CGFloat {
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
    
    private var statusIconSize: CGFloat {
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
    
    private var statusTextSize: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 10 :
                   screenWidth <= 834 ? 11 :
                   screenWidth <= 1024 ? 12 :
                   13
        } else {
            return screenWidth <= 320 ? 8 :
                   screenWidth <= 375 ? 9 :
                   screenWidth <= 393 ? 10 :
                   11
        }
    }
    
    private var cardPadding: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 18 :
                   screenWidth <= 834 ? 20 :
                   screenWidth <= 1024 ? 22 :
                   24
        } else {
            return screenWidth <= 320 ? 12 :
                   screenWidth <= 375 ? 14 :
                   screenWidth <= 393 ? 16 :
                   18
        }
    }
    
    private var selectedSongViewHeight: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 100 :
                   screenWidth <= 834 ? 110 :
                   screenWidth <= 1024 ? 120 :
                   130
        } else {
            return screenWidth <= 320 ? 75 :
                   screenWidth <= 375 ? 85 :
                   screenWidth <= 393 ? 90 :
                   95
        }
    }
}

#Preview {
    // Create sample data for preview
    let metronome = MetronomeEngine()
    let songManager = SongManager()
    
    return MetronomeView(metronome: metronome, songManager: songManager)
}
