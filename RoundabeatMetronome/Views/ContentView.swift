import SwiftUI
import AVFoundation

// MARK: - Content View

struct ContentView: View {
    
    // Use an ObservedObject instead of a StateObject to share it between tabs
    @ObservedObject var metronome: MetronomeEngine
    @State private var isEditingTempo = false
    @State private var showTimeSignaturePicker = false
    @State private var showBPMKeypad = false
    @State private var showSubdivisionPicker = false // Added for subdivision picker
    @State private var previousTempo: Double = 120
    
    init(metronome: MetronomeEngine) {
        self.metronome = metronome
        self._previousTempo = State(initialValue: metronome.tempo)
    }
    
    var body: some View {
        
        ZStack(alignment: .center) { // Explicitly set alignment
            
            DarkGrayBackgroundView()
            
            // Main metronome interface
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    
                    // Top spacing from safe area
                    Spacer()
                        .frame(height: geometry.safeAreaInsets.top + 40)
                    
                    // BPM display section
                    HStack { // Wrap in HStack to ensure proper centering
                        Spacer()
                        VStack(spacing: 16) {
                            BPMView(
                                metronome: metronome,
                                isShowingKeypad: $showBPMKeypad,
                                showTimeSignaturePicker: $showTimeSignaturePicker
                            )
                        }
                        Spacer()
                    }
                    
                    // Spacer between BPM and logo
                    Spacer()
                        .frame(height: 32)
                    
                    // Logo section
                    HStack { // Wrap in HStack to ensure proper centering
                        Spacer()
                        VStack {
                            LogoView()
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                    .padding(.top, 16)
                    .padding(.bottom, 8)
                    
                    // Spacer between logo and dial
                    Spacer()
                        .frame(height: 40)
                    
                    // Dial control section
                    HStack { // Wrap in HStack to ensure proper centering
                        Spacer()
                        VStack {
                            DialControl(metronome: metronome)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    
                    // Bottom spacer to push content up and provide breathing room
                    Spacer()
                        .frame(height: max(60, geometry.safeAreaInsets.bottom + 40))
                }
                .frame(
                    width: geometry.size.width,
                    height: geometry.size.height,
                    alignment: .center
                ) // Explicitly set frame and alignment
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center) // Additional centering
            .onAppear {
                // Prepare audio system as soon as view appears
                prepareAudioSystem()
                // Initialize the previous tempo state with current tempo
                previousTempo = metronome.tempo
            }
            .blur(radius: showTimeSignaturePicker || showBPMKeypad || showSubdivisionPicker ? 3 : 0)
            .disabled(showTimeSignaturePicker || showBPMKeypad || showSubdivisionPicker)
            
            // Time signature picker overlay
            if showTimeSignaturePicker {
                TimeSignaturePickerView(
                    metronome: metronome,
                    isShowingPicker: $showTimeSignaturePicker
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .zIndex(1)
            }
            
            // BPM Keypad overlay
            if showBPMKeypad {
                NumberPadView(
                    isShowingKeypad: $showBPMKeypad,
                    currentTempo: metronome.tempo
                ) { newTempo in
                    metronome.updateTempo(to: newTempo)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .zIndex(1)
            }
    
        }
        .ignoresSafeArea(.all, edges: .all)
        .animation(.spring(response: 0.3), value: showTimeSignaturePicker)
        .animation(.spring(response: 0.3), value: showBPMKeypad)
        .animation(.spring(response: 0.3), value: showSubdivisionPicker)
    }
    
    // Function to prepare the audio system for low latency
    private func prepareAudioSystem() {
        // Pre-warm the audio system by playing a silent sound
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred(intensity: 0.1)
    }
}

struct ShimmerCurveModifier: ViewModifier {
    let progress: CGFloat
    let amplitude: CGFloat
    let width: CGFloat

    func body(content: Content) -> some View {
        content
            .offset(
                x: progress * width,
                y: sin(progress * .pi * 2) * amplitude
            )
    }
}

#Preview {
    ContentView(
        metronome: MetronomeEngine()
    )
}
