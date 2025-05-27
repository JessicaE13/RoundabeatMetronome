import SwiftUI

// MARK: - Main BPM Display Component
struct BPMView: View {
    @ObservedObject var metronome: MetronomeEngine
    @Binding var isShowingKeypad: Bool
    @Binding var showTimeSignaturePicker: Bool
    @State private var dragOffset: CGFloat = 0
    @State private var previousTempo: Double = 120
    @State private var showSettings = false
    @State private var containerScale: CGFloat = 1.0
    @State private var pulseAnimation: Bool = false
    
    var body: some View {
        VStack {
            // MARK: - Combined Tempo and BPM Controls
            VStack(spacing: 0) {
                // MARK: - Row 1: Time Signature and Settings
                TempoSelectorView(
                    metronome: metronome,
                    previousTempo: $previousTempo
                )
                .padding(.horizontal, 8)
                .padding(.top, 8)
                .padding(.bottom, -10)
                
                // MARK: - Row 2: BPM Controls
                BPMControlsView(
                    metronome: metronome,
                    isShowingKeypad: $isShowingKeypad,
                    previousTempo: $previousTempo
                )
                .padding(.horizontal, 8)
                .padding(.top, -10)
                .padding(.bottom, 8)
                .scaleEffect(pulseAnimation ? 1.02 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: pulseAnimation)
            }
            .background(
                // Shared background for both components
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(red: 10/255, green: 10/255, blue: 11/255))
            )
            .scaleEffect(containerScale)
                
            Spacer()
            
            // MARK: - Row 3: Time Signature View with Matching Style
            TimeSignatureView(
                metronome: metronome,
                showTimeSignaturePicker: $showTimeSignaturePicker,
                showSettings: $showSettings
            )
            .padding(.vertical, 8)
//            .background(
//                RoundedRectangle(cornerRadius: 24)
//                    .fill(Color(red: 10/255, green: 10/255, blue: 11/255))
//                    .frame(width: 355)
//            )
            //.padding(.top, 8)
            .padding(.bottom, 15)
            .padding(.horizontal, 16)
        }
        .frame(height: UIScreen.main.bounds.height / 3.5)
        .padding(.horizontal, 20)
        .padding(.top, 40)
        .gesture(
            DragGesture()
                .onChanged { value in
                    dragOffset = value.translation.height
                    let tempoChange = -dragOffset * 0.2
                    let newTempo = previousTempo + tempoChange
                    let oldTempoInt = Int(metronome.tempo)
                    
                    // Enhanced visual feedback during drag
                    withAnimation(.easeOut(duration: 0.1)) {
                        containerScale = 1.02
                    }
                    
                    metronome.updateTempo(to: newTempo)
                    
                    // If the integer value of the tempo changed, provide haptic feedback and visual pulse
                    if Int(metronome.tempo) != oldTempoInt {
                        let generator = UIImpactFeedbackGenerator(style: .soft)
                        generator.impactOccurred(intensity: 0.5)
                        
                        // Trigger pulse animation
                        withAnimation(.easeInOut(duration: 0.1)) {
                            pulseAnimation = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation(.easeInOut(duration: 0.1)) {
                                pulseAnimation = false
                            }
                        }
                    }
                }
                .onEnded { _ in
                    dragOffset = 0
                    previousTempo = metronome.tempo
                    
                    // Reset scale with smooth animation
                    withAnimation(.easeOut(duration: 0.2)) {
                        containerScale = 1.0
                    }
                    
                    let generator = UIImpactFeedbackGenerator(style: .soft)
                    generator.impactOccurred(intensity: 0.5)
                }
        )
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .onReceive(NotificationCenter.default.publisher(for: .init("MetronomeBeat"))) { _ in
            // Subtle beat indication with enhanced animation
            withAnimation(.easeInOut(duration: 0.05)) {
                pulseAnimation = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                withAnimation(.easeInOut(duration: 0.05)) {
                    pulseAnimation = false
                }
            }
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
