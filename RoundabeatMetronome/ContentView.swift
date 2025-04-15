

import SwiftUI
import AVFoundation
 



// MARK: - Content View
struct ContentView: View {
    @StateObject private var metronome = MetronomeEngine()
    @State private var isEditingTempo = false
    @State private var showTimeSignaturePicker = false
    @State private var showBPMKeypad = false
    
    // State for tap tempo feature
    @State private var lastTapTime: Date?
    @State private var tapTempoBuffer: [TimeInterval] = []
    
    var body: some View {
        ZStack {
            // Main metronome interface
            VStack(spacing: 25) {

                
                // BPM Display with gestures
                BPMDisplayView(
                    metronome: metronome,
                    isShowingKeypad: $showBPMKeypad
                )
                
                // Title
                Text("Roundabeat Metronome")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                    .foregroundStyle(.gray)
                
                // Visual Beat Indicator with high-performance animation
                HStack(spacing: 15) {
                    ForEach(0..<metronome.beatsPerMeasure, id: \.self) { beat in
                        // Use ZStack for better animation performance
                        ZStack {
                            // Background circle
                            Circle()
                                .frame(width: 20, height: 20)
                                .foregroundColor(beat == metronome.currentBeat && metronome.isPlaying ?
                                               (beat == 0 ? .blue : .red) : .gray.opacity(0.5))
                            
                            // Animated pulse for the active beat
                            if beat == metronome.currentBeat && metronome.isPlaying {
                                Circle()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(beat == 0 ? .blue : .red)
                                    .scaleEffect(1.5)
                                    .opacity(0)
                                    .animation(.easeOut(duration: 0.2).repeatCount(1), value: metronome.currentBeat)
                            }
                        }
                    }
                }
                
                // Tap Tempo Button
                Button(action: {
                    calculateTapTempo()
                }) {
                    Text("Tap Tempo")
                        .font(.headline)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
                
                // Time Signature Button
                Button(action: {
                    showTimeSignaturePicker = true
                }) {
                    HStack {
                        Text("\(metronome.beatsPerMeasure)/\(metronome.beatUnit)")
                            .font(.title)
                            .fontWeight(.semibold)
                            .frame(width: 80)
                            .animation(.spring(), value: metronome.beatsPerMeasure)
                            .animation(.spring(), value: metronome.beatUnit)
                        
                        Image(systemName: "chevron.down")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
                
                // New Dial Control with Play/Pause Button
                DialControl(metronome: metronome)
                    .padding(.top, -10)
                    .padding(.bottom, -30)
                
    
            }
            .padding()
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
    
    // Storage for previous tempo to use with gestures
    @State private var previousTempo: Double = 120
    
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



#Preview {
    ContentView()
}
