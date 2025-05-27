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
            // MARK: - 3 Distinct Horizontal Rows
            VStack(spacing: 0) {
                // MARK: - Row 1: Time Signature and Settings
                TimeSignatureView(
                    metronome: metronome,
                    showTimeSignaturePicker: $showTimeSignaturePicker,
                    showSettings: $showSettings
                )
                .padding(.top, 20)
                .padding(.bottom, 15)
                .frame(width: 300)
                
                // Subtle divider with dark theme
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.clear,
                                Color(red: 0.4, green: 0.4, blue: 0.4).opacity(0.3),
                                Color.clear
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 1)
                    .padding(.horizontal, 30)
                
                Spacer()
                
                // MARK: - Row 2: BPM Controls
                BPMControlsView(
                    metronome: metronome,
                    isShowingKeypad: $isShowingKeypad,
                    previousTempo: $previousTempo
                )
                .clipped()
                .frame(height: 80) // Artificially constrain height
                .clipShape(Rectangle()) // Clip excess font padding
                .scaleEffect(pulseAnimation ? 1.02 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: pulseAnimation)
                
                Spacer()
                
                // Subtle divider with dark theme
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.clear,
                                Color(red: 0.4, green: 0.4, blue: 0.4).opacity(0.3),
                                Color.clear
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 1)
                    .padding(.horizontal, 30)
                
                // MARK: - Row 3: Horizontal Tempo Selector
                TempoSelectorView(
                    metronome: metronome,
                    previousTempo: $previousTempo
                )
                .padding(.top, 4)
                .padding(.bottom, 8)
            }
            .background(
                // Completely flat, matte black display - matching the reference image
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(red: 10/255, green: 10/255, blue: 11/255))
            )
            .scaleEffect(containerScale)
            // Minimal shadow to maintain some separation from background
//            .shadow(
//                color: Color.black.opacity(0.2),
//                radius: 8,
//                x: 0,
//                y: 4
//            )
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
        // Updated background to match the dark aesthetic
        Color(red: 18/255, green: 18/255, blue: 18/255)
            .ignoresSafeArea()
        
        BPMView(
            metronome: MetronomeEngine(),
            isShowingKeypad: .constant(false),
            showTimeSignaturePicker: .constant(false)
        )
    }
}
