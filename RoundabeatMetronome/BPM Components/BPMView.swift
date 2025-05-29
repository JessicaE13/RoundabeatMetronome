import SwiftUI

// MARK: - Updated BPM Display Component
struct BPMView: View {
    @ObservedObject var metronome: MetronomeEngine
    @Binding var isShowingKeypad: Bool
    @Binding var showTimeSignaturePicker: Bool
    @State private var previousTempo: Double = 120
    @State private var showSettings = false
    
    var body: some View {
        VStack(spacing: 20) {
            // MARK: - Main BPM Section (without TimeSignatureView)
            SimplifiedBPMSectionView(
                metronome: metronome,
                isShowingKeypad: $isShowingKeypad,
                previousTempo: $previousTempo
            )
            
            // MARK: - Time Signature Section (below the rounded rectangle)
            TimeSignatureView(
                metronome: metronome,
                showTimeSignaturePicker: $showTimeSignaturePicker,
                showSettings: $showSettings
            )
        }
        .frame(height: UIScreen.main.bounds.height / 3.5)
        .padding(.horizontal, 20)
        .padding(.top, 40)
        .sheet(isPresented: $showSettings) {
            SettingsView(metronome: metronome)
        }
        .onAppear {
            previousTempo = metronome.tempo
        }
    }
}

#Preview {
    ZStack {
        DarkGrayBackgroundView()
        BPMView(
            metronome: MetronomeEngine(),
            isShowingKeypad: .constant(false),
            showTimeSignaturePicker: .constant(false)
        )
    }
}
