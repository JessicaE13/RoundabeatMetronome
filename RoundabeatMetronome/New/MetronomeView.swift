import SwiftUI
import AVFoundation

// MARK: - Metronome View
struct MetronomeView: View {
    @ObservedObject var metronome: MetronomeEngine
    @Environment(\.deviceEnvironment) private var device
    
    // State for showing pickers
    @State private var showingTimeSignaturePicker = false
    @State private var showingSubdivisionPicker = false
    @State private var showingNumberPad = false
    
    var body: some View {
        VStack(spacing: 0) {
            
        //    Spacer()
            
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
        .padding(.horizontal, device.deviceType.horizontalPadding)
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
}

#Preview {
    MetronomeView(metronome: MetronomeEngine())
        .deviceEnvironment(DeviceEnvironment())
}
