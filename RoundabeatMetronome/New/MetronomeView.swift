import SwiftUI
import AVFoundation

// MARK: - Metronome View
struct MetronomeView: View {
    @ObservedObject var metronome: MetronomeEngine
    @Environment(\.deviceEnvironment) private var device
    
    // State for showing time signature picker
    @State private var showingTimeSignaturePicker = false
    
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
            
            BPMView(metronome: metronome)
            
            Spacer()
            
            
            UniformButtonsView(
                metronome: metronome,
                showingTimeSignaturePicker: $showingTimeSignaturePicker
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
            // Time Signature Picker Modal - now covers entire MetronomeView
            Group {
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
            }
        )
    }
}

#Preview {
    MetronomeView(metronome: MetronomeEngine())
        .deviceEnvironment(DeviceEnvironment())
}
