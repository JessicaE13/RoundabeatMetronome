import SwiftUI
import AVFoundation

// MARK: - Device Type Detection
extension UIDevice {
    var isIPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var isIPhone: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }
}

// MARK: - Adaptive Layout Helper
struct AdaptiveLayout {
    let isIPad: Bool
    let screenWidth: CGFloat
    let screenHeight: CGFloat
    
    init(geometry: GeometryProxy) {
        self.isIPad = UIDevice.current.isIPad
        self.screenWidth = geometry.size.width
        self.screenHeight = geometry.size.height
    }
    
    // Default initializer for cases where GeometryProxy isn't available
    static var `default`: AdaptiveLayout {
        return AdaptiveLayout(
            isIPad: UIDevice.current.isIPad,
            screenWidth: UIScreen.main.bounds.width,
            screenHeight: UIScreen.main.bounds.height
        )
    }
    
    private init(isIPad: Bool, screenWidth: CGFloat, screenHeight: CGFloat) {
        self.isIPad = isIPad
        self.screenWidth = screenWidth
        self.screenHeight = screenHeight
    }
    
    // Adaptive spacing values
    var topSpacing: CGFloat {
        isIPad ? 80 : 40
    }
    
    var sectionSpacing: CGFloat {
        isIPad ? 32 : 16
    }
    
    var componentSpacing: CGFloat {
        isIPad ? 24 : 16
    }
    
    var bottomSpacing: CGFloat {
        isIPad ? 60 : 48
    }
    
    // Adaptive padding values
    var horizontalPadding: CGFloat {
        if isIPad {
            return max(60, screenWidth * 0.1) // 10% of screen width, minimum 60
        }
        return 24
    }
    
    var contentMaxWidth: CGFloat? {
        isIPad ? min(600, screenWidth * 0.7) : nil
    }
    
    // Font scaling
    var bpmFontSize: CGFloat {
        if isIPad {
            return min(120, screenWidth * 0.15) // Scale with screen width
        }
        return 90
    }
    
    var dialSize: CGFloat {
        if isIPad {
            return min(300, screenWidth * 0.35)
        }
        return 220
    }
    
    var ringLineWidth: CGFloat {
        isIPad ? 32 : 24
    }
}

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
                let layout = AdaptiveLayout(geometry: geometry)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        
                        Spacer()
                            .frame(height: geometry.safeAreaInsets.top + layout.topSpacing)
                
                        // Content container with max width for iPad
                        VStack(spacing: 0) {
                            
                            TempoSelectorView(
                                metronome: metronome,
                                previousTempo: $previousTempo
                            )
                            .padding(.top, layout.sectionSpacing)
                            .padding(.bottom, layout.componentSpacing)
                            .padding(.horizontal, layout.horizontalPadding)
                            
                            BPMControlsView(
                                metronome: metronome,
                                isShowingKeypad: $showBPMKeypad,
                                previousTempo: $previousTempo,
                                adaptiveLayout: layout
                            )
                            
                            Text("BEATS PER MINUTE (BPM)")
                                .font(.system(size: layout.isIPad ? 14 : 12, weight: .medium))
                                .foregroundColor(Color.white.opacity(0.4))
                                .padding(.top, layout.componentSpacing / 2)
                                .padding(.bottom, layout.componentSpacing)
                                .tracking(1)
                            
                            TimeSignatureView(
                                metronome: metronome,
                                showTimeSignaturePicker: $showTimeSignaturePicker,
                                showSettings: $showSettings,
                                showSubdivisionPicker: $showSubdivisionPicker,
                                adaptiveLayout: layout
                            )
                            .padding(.top, layout.componentSpacing)
                            .padding(.bottom, layout.bottomSpacing)
                            .padding(.horizontal, layout.horizontalPadding)
                            
                            LogoView()
                                .scaleEffect(layout.isIPad ? 1.5 : 1.0)
                            
                            Spacer()
                                .frame(height: layout.sectionSpacing)
                            
                            DialControl(
                                metronome: metronome,
                                adaptiveLayout: layout
                            )
                            
                            Spacer()
                                .frame(height: layout.bottomSpacing)
                        }
                        .frame(maxWidth: layout.contentMaxWidth)
                        .frame(maxWidth: .infinity) // Center the content
                    }
                    .frame(minHeight: geometry.size.height)
                }
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
