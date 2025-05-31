import SwiftUI
import AVFoundation

// MARK: - Content View

struct MetronomeView: View {
    
    // Use an ObservedObject instead of a StateObject to share it between tabs
    @ObservedObject var metronome: MetronomeEngine
    @State private var isEditingTempo = false
    @State private var showTimeSignaturePicker = false
    @State private var showBPMKeypad = false
    @State private var showSubdivisionPicker = false // Keep this for subdivision picker
    @State private var previousTempo: Double = 120
    @State private var showSettings = false
    
    init(metronome: MetronomeEngine) {
        self.metronome = metronome
        self._previousTempo = State(initialValue: metronome.tempo)
    }
    
    var body: some View {
        
        ZStack(alignment: .center) { // Explicitly set alignment
            
            BackgroundView()
            
            // Main metronome interface
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    
                    Spacer()
                        .frame(height: geometry.safeAreaInsets.top + 40)
            
                            TempoSelectorView(
                                metronome: metronome,
                                previousTempo: $previousTempo
                            )
                            .padding(.top, 40)
                            .padding(.bottom, 16)
                            .padding(.horizontal, 24)

                      
                        BPMControlsView(
                            metronome: metronome,
                            isShowingKeypad: $showBPMKeypad,
                            previousTempo: $previousTempo
                        )
                      
                    
                    Text("BEATS PER MINUTE (BPM)")
                                       .font(.system(size: 12, weight: .medium))
                                       .foregroundColor(Color.white.opacity(0.4))
                                       .padding(.top, 8)
                                       .padding(.bottom, 16)
                                       .tracking(1)
                    
                        TimeSignatureView(
                            metronome: metronome,
                            showTimeSignaturePicker: $showTimeSignaturePicker,
                            showSettings: $showSettings,
                            showSubdivisionPicker: $showSubdivisionPicker
                        )
                        .padding(.top, 16)
                        .padding(.bottom, 48)
                        .padding(.horizontal, 24)
                    
                    
                    
                    LogoView()
                
                    
                    Spacer()
                    
                    DialControl(metronome: metronome)
                    
                    Spacer()
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
        .ignoresSafeArea(.all, edges: .all)
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
