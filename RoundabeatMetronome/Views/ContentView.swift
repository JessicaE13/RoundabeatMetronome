import SwiftUI
import AVFoundation

// MARK: - Content View

struct ContentView: View {
    
    // Use an ObservedObject instead of a StateObject to share it between tabs
    @ObservedObject var metronome: MetronomeEngine
    @State private var isEditingTempo = false
    @State private var showTimeSignaturePicker = false
    @State private var showBPMKeypad = false
    
    // State for tap tempo feature
    @State private var lastTapTime: Date?
    @State private var tapTempoBuffer: [TimeInterval] = []
    @State private var previousTempo: Double = 120
    
    init(metronome: MetronomeEngine) {
        self.metronome = metronome
        self._previousTempo = State(initialValue: metronome.tempo)
    }
    
    var body: some View {
        
        ZStack {
            
            DarkGrayBackgroundView()
            
            // Main metronome interface
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    
                    // Top spacing from safe area
                    Spacer()
                        .frame(height: geometry.safeAreaInsets.top + 32)
                    
                    // BPM display section
                    VStack(spacing: 16) {
                        BPMView(
                            metronome: metronome,
                            isShowingKeypad: $showBPMKeypad,
                            showTimeSignaturePicker: $showTimeSignaturePicker
                        )
                    }
             
                    
                    // Spacer between BPM and logo
                    Spacer()
                        .frame(height: 32)
                    
                    // Logo section
                    VStack {
                        LogoView()
                    }
                    .padding(.horizontal, 24)
                    
                    // Spacer between logo and dial
                    Spacer()
                        .frame(height: 40)
                    
                    // Dial control section
                    VStack {
                        DialControl(metronome: metronome)
                    }
                    .padding(.horizontal, 24)
                    
                    // Bottom spacer to push content up and provide breathing room
                    Spacer()
                        .frame(height: max(60, geometry.safeAreaInsets.bottom + 40))
                }
            }
            .onAppear {
                // Prepare audio system as soon as view appears
                prepareAudioSystem()
                // Initialize the previous tempo state with current tempo
                previousTempo = metronome.tempo
            }
            .blur(radius: showTimeSignaturePicker || showBPMKeypad ? 3 : 0)
            .disabled(showTimeSignaturePicker || showBPMKeypad)
            
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
    }
    
    // Function to prepare the audio system for low latency
    private func prepareAudioSystem() {
        // Pre-warm the audio system by playing a silent sound
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred(intensity: 0.1)
    }
    
    // Tap tempo calculation
    private func calculateTapTempo() {
        let now = Date()
        
        // Add haptic feedback for tap
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        if let lastTap = lastTapTime {
            // Calculate time difference
            let timeDiff = now.timeIntervalSince(lastTap)
            
            // Only use reasonable tap intervals (between 40 and 240 BPM)
            if timeDiff > 0.25 && timeDiff < 1.5 {
                // Add to buffer
                tapTempoBuffer.append(timeDiff)
                
                // Keep only the last 4 taps for accuracy
                if tapTempoBuffer.count > 4 {
                    tapTempoBuffer.removeFirst()
                }
                
                // Calculate average from buffer
                let averageInterval = tapTempoBuffer.reduce(0, +) / Double(tapTempoBuffer.count)
                let calculatedTempo = min(240, max(40, 60.0 / averageInterval))
                
                // Round to nearest integer
                let roundedTempo = round(calculatedTempo)
                
                // Update metronome tempo
                metronome.updateTempo(to: roundedTempo)
                
                // Also update the previous tempo state for gestures
                previousTempo = roundedTempo
            }
            
            // If tap is too fast or too slow, reset buffer
            if timeDiff < 0.25 || timeDiff > 2.0 {
                tapTempoBuffer.removeAll()
            }
        }
        
        // Reset if more than 2 seconds since last tap
        if let lastTap = lastTapTime, now.timeIntervalSince(lastTap) > 2.0 {
            tapTempoBuffer.removeAll()
        }
        
        // Update last tap time
        lastTapTime = now
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
