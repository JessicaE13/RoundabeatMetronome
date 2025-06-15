import SwiftUI
import AVFoundation

// MARK: - Metronome View
struct MetronomeView: View {
    @ObservedObject var metronome: MetronomeEngine
    
    // State for showing pickers
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
    
    var body: some View {
        VStack(spacing: 0) {
            
            TempoScrollView(
                currentBPM: metronome.bpm,
                onTempoChange: { newBPM in
                    metronome.bpm = newBPM
                }
            )
            
            Spacer()
            
            BPMView(
                metronome: metronome,
                showingNumberPad: $showingNumberPad
            )
            
            Spacer()
            
            UniformButtonsView(
                metronome: metronome,
                showingTimeSignaturePicker: $showingTimeSignaturePicker,
                showingSubdivisionPicker: $showingSubdivisionPicker
            )
            
            Spacer()
         
            LogoView()
  
            Spacer()
            
            DialView(metronome: metronome)
            
            Spacer()
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, horizontalPadding)
        .overlay(
            // Modal Overlays
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
                        }
                    )
                }
            }
        )
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

#Preview {
    MetronomeView(metronome: MetronomeEngine())
}
