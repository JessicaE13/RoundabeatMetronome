import SwiftUI

// MARK: - Main BPM Display Component
struct BPMView: View {
    @ObservedObject var metronome: MetronomeEngine
    @Binding var isShowingKeypad: Bool
    @Binding var showTimeSignaturePicker: Bool
    @State private var dragOffset: CGFloat = 0
    @State private var previousTempo: Double = 120
    @State private var showSettings = false
    @State private var showDebugOutlines = false // Toggle this to show/hide red debug outlines
    
    let glowAnimation = Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)
    
    var body: some View {
        ZStack {
            VStack {
                
                // MARK: - Main Rounded Rectangle Container
                ZStack {
                    
                    RoundedRectangle(cornerRadius: 50)
                        .fill(Color.black.opacity(0.9))
                    
                    RoundedRectangle(cornerRadius: 50)
                        .offset(y: 0.5)
                        .stroke(LinearGradient(
                            gradient: Gradient(colors: [Color.clear, Color.white.opacity(0.7)]),
                            startPoint: .top,
                            endPoint: .bottom)
                        )
                    
                    
                    // MARK: - 3 Distinct Horizontal Rows
                    VStack {
                        
                        // MARK: - Row 1: Time Signature and Settings
                        TimeSignatureView(
                            metronome: metronome,
                            showTimeSignaturePicker: $showTimeSignaturePicker,
                            showSettings: $showSettings
                        )
                        .padding(.top,15)
                        .frame(width: 300)
                        .border(showDebugOutlines ? Color.red : Color.clear, width: 2)
                        
                        Spacer()
                        
                        // MARK: - Row 2: BPM Controls
                        BPMControlsView(
                            metronome: metronome,
                            isShowingKeypad: $isShowingKeypad,
                            previousTempo: $previousTempo
                        )
                        .border(showDebugOutlines ? Color.red : Color.clear, width: 2)
                        
                        Spacer()
                        
                        // MARK: - Row 3: Horizontal Tempo Selector
                        TempoSelectorView(
                            metronome: metronome,
                            previousTempo: $previousTempo
                        )
                        .border(showDebugOutlines ? Color.red : Color.clear, width: 2)
                    }
                 
                    .clipShape(RoundedRectangle(cornerRadius: 50))
                    
                    // Black inner outline - 3px wide (drawn on top of clipped content)
                    RoundedRectangle(cornerRadius: 50)
                        .stroke(Color.black, lineWidth: 3)
                        .padding(1.5)
                        .allowsHitTesting(false)
                }
                
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            dragOffset = value.translation.height
                            let tempoChange = -dragOffset * 0.2
                            let newTempo = previousTempo + tempoChange
                            let oldTempoInt = Int(metronome.tempo)
                            
                            metronome.updateTempo(to: newTempo)
                            
                            // If the integer value of the tempo changed, provide haptic feedback
                            if Int(metronome.tempo) != oldTempoInt {
                                let generator = UIImpactFeedbackGenerator(style: .soft)
                                generator.impactOccurred(intensity: 0.5)
                            }
                        }
                        .onEnded { _ in
                            dragOffset = 0
                            previousTempo = metronome.tempo
                            let generator = UIImpactFeedbackGenerator(style: .soft)
                            generator.impactOccurred(intensity: 0.5)
                        }
                )
            }
            .frame(height: UIScreen.main.bounds.height / 3.5)
            .padding(.horizontal, 20)
            .padding(.top, 40)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }
}

#Preview {
    ZStack {
        BackgroundView()
        
        BPMView(
            metronome: MetronomeEngine(),
            isShowingKeypad: .constant(false),
            showTimeSignaturePicker: .constant(false)
        )
    }
}
