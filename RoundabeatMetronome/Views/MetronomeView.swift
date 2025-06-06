import SwiftUI
import AVFoundation

// MARK: - Content View with Adaptive Layout
struct MetronomeView: View {
    
    // Use an ObservedObject instead of a StateObject to share it between tabs
    @ObservedObject var metronome: MetronomeEngine
    @State private var isEditingTempo = false
    @State private var showTimeSignaturePicker = false
    @State private var showBPMKeypad = false
    @State private var showSubdivisionPicker = false
    @State private var previousTempo: Double = 120
    @State private var showSettings = false
    
    init(metronome: MetronomeEngine) {
        self.metronome = metronome
        self._previousTempo = State(initialValue: metronome.tempo)
    }
    
    var body: some View {
        
        ZStack(alignment: .center) {
            
            BackgroundView()
            
            // Main metronome interface
            GeometryReader { geometry in
                
                
                VStack(spacing: 0) {
                    
                    Spacer()
                        .frame(height: 16)
                    
                    // Content container with max width for iPad
                    VStack(spacing: 0) {
                        
                        TempoSelectorView(
                            metronome: metronome,
                            previousTempo: $previousTempo
                        )
                        .padding(.leading)
                        .padding(.trailing)
                        .padding(.bottom)
                        
                        BPMControlsView(
                            metronome: metronome,
                            isShowingKeypad: $showBPMKeypad,
                            previousTempo: $previousTempo
                        )
                        
                        Text("BEATS PER MINUTE (BPM)")
                            .font(.system(.subheadline, weight: .medium))
                            .foregroundColor(Color.white.opacity(0.4))
                            .kerning(1.5)
                            .padding(.bottom)
                        
                        TimeSignatureView(
                            metronome: metronome,
                            showTimeSignaturePicker: $showTimeSignaturePicker,
                            showSettings: $showSettings,
                            showSubdivisionPicker: $showSubdivisionPicker
                        )
                        .padding()
                        
                        Spacer()
                        
                        LogoView()
                        
                        
                        Spacer()
                        
                        DialControl(
                            metronome: metronome
                        )
                        
                    }
                    .frame(maxWidth: .infinity) // Center the content
                }
                .frame(minHeight: geometry.size.height)
                
            }
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
            
            // Subdivision picker overlay
            if showSubdivisionPicker {
                SubdivisionPickerView(
                    metronome: metronome,
                    isShowingPicker: $showSubdivisionPicker
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .zIndex(1)
            }
        }
        .animation(.spring(response: 0.3), value: showTimeSignaturePicker)
        .animation(.spring(response: 0.3), value: showBPMKeypad)
        .animation(.spring(response: 0.3), value: showSubdivisionPicker)
        .sheet(isPresented: $showSettings) {
            SettingsView(metronome: metronome)
        }
        .onAppear {
            previousTempo = metronome.tempo
        }
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
    MetronomeView(
        metronome: MetronomeEngine()
    )
}
