

import SwiftUI
import AVFoundation


// MARK: - Settings View
struct SettingsView: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Sound Options")) {
                    Toggle("Enable Sound", isOn: .constant(true))
                    
                    NavigationLink(destination: Text("Sound Selection")) {
                        HStack {
                            Text("Click Sound")
                            Spacer()
                            Text("Woodblock")
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Section(header: Text("Visual Options")) {
                    Toggle("Flash Screen on First Beat", isOn: .constant(true))
                    Toggle("Dark Mode", isOn: .constant(true))
                }
                
                Section(header: Text("About")) {
                    NavigationLink(destination: Text("RoundaBeat Metronome\nVersion 1.0")) {
                        Text("App Information")
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

// MARK: - Main Tab View
struct MainTabView: View {
    @StateObject private var metronome = MetronomeEngine()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Metronome Tab
            ContentView(metronome: metronome)
                .tabItem {
                    Image(systemName: "metronome")
                    Text("Metronome")
                }
                .tag(0)
            
            // Settings Tab
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("Settings")
                }
                .tag(1)
        }
        .accentColor(Color("colorGlow"))
    }
}

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
            
            //Background color
            ZStack {
                // Base color
                
                //Background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.gray.opacity(0.2),
                        Color.gray.opacity(0.1)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Subtle gradient overlay
                LinearGradient(
                    gradient: Gradient(colors: [
                        .white.opacity(0.15),
                        .clear
                    ]),
                    startPoint: .top,
                    endPoint: .center
                )
                .ignoresSafeArea()
                
                // Very subtle noise texture (optional)
                Color.black.opacity(0.03)
                    .ignoresSafeArea()
                    .blendMode(.overlay)
            }
            
            // Main metronome interface
            VStack(spacing: 25) {
                
      
                
                BPMView(
                    metronome: metronome,
                    isShowingKeypad: $showBPMKeypad,
                    showTimeSignaturePicker: $showTimeSignaturePicker
                )
                

                
                // Title
                
                TitleView()
                
 
                
                HStack(spacing: 15) {
                    // Left chevron (decrease BPM)
                    Button(action: {
                        // Decrease tempo by 1
                        metronome.updateTempo(to: metronome.tempo - 1)
                        // Add haptic feedback
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                        // Update previous tempo
                        previousTempo = metronome.tempo
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(Color.white)
                            .shadow(color: .black.opacity(0.1), radius: 1, x: 1, y: 1)
                            .shadow(color: .white.opacity(0.1), radius: 1, x: -1, y: -1)
                            .frame(width: 44, height: 44)
                            .contentShape(Circle())
                    }
                    
                    // Main Dial Control with Play/Pause Button
                    DialControl(metronome: metronome)
                    
                    // Right chevron (increase BPM)
                    Button(action: {
                        // Increase tempo by 1
                        metronome.updateTempo(to: metronome.tempo + 1)
                        // Add haptic feedback
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                        // Update previous tempo
                        previousTempo = metronome.tempo
                    }) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(Color.white)
                            .shadow(color: .black.opacity(0.1), radius: 1, x: 1, y: 1)
                            .shadow(color: .white.opacity(0.1), radius: 1, x: -1, y: -1)
                            .frame(width: 44, height: 44)
                            .contentShape(Circle())
                    }
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

// Update the main entry point of the app
#Preview {
    MainTabView()
}

//
//#Preview {
//    ContentView()
//}
