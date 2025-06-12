import SwiftUI
import AVFoundation

// MARK: - Metronome View
struct MetronomeView: View {
    @Bindable var metronome: MetronomeEngine
    @Environment(\.deviceEnvironment) private var device
    
    var body: some View {
        VStack(spacing: 0) {
            
            Spacer()
            
            TempoScrollView(
                currentBPM: metronome.bpm,
                onTempoChange: { newBPM in
                    metronome.bpm = newBPM
                }
            )
            
            Spacer()
            
            BPMView(metronome: metronome)
            
            Spacer()
            
            
            UniformButtonsView(metronome: metronome)
            
            Spacer()
         
            LogoView()
            
  
            Spacer()
            
            DialView(metronome: metronome)
            
            Spacer()
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, device.deviceType.horizontalPadding)
    }
}

#Preview {
    MetronomeView(metronome: MetronomeEngine())
        .deviceEnvironment(DeviceEnvironment())
}
