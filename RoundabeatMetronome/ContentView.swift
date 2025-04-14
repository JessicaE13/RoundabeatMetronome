

import SwiftUI
import AVFoundation


// MARK: - Time Signature Picker View
struct TimeSignaturePickerView: View {
    @ObservedObject var metronome: MetronomeEngine
    @Binding var isShowingPicker: Bool
    
    // For custom time signature input
    @State private var customNumerator = 4
    @State private var customDenominator = 4
    @State private var isShowingCustom = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 25) {
                // Header with title and close button
                HStack {
                    Spacer()
                    Text("Time Signature:   \(metronome.beatsPerMeasure)/\(metronome.beatUnit)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                        
                    Spacer()
                    Button(action: {
                        isShowingPicker = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                            .font(.title2)
                    }
                }
                Divider ()
                    .padding(-5.0)
     
                
                // Simple Time section
                
                VStack(alignment: .leading, spacing: 15) {
                    
                    // Section header
                    HStack {
                        Text("Simple Time")
                            .font(.headline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(8)
                        
                        Text("Each beat divides into 2 equal parts")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    HStack(spacing: 15) {
                        // Duple row
                        Text("Duple")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 5)
                        timeSignatureButton(numerator: 2, denominator: 2)
                        timeSignatureButton(numerator: 2, denominator: 4)
                        Spacer()
                    }
                    
                    HStack(spacing: 15) {
                        // Triple row
                        Text("Triple")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 5)
                        
                        timeSignatureButton(numerator: 3, denominator: 2)
                        timeSignatureButton(numerator: 3, denominator: 4)
                        timeSignatureButton(numerator: 3, denominator: 8)
                        Spacer()
                    }
                                      
                    HStack(spacing: 15) {
                        // Quadruple row
                        Text("Quadruple")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 5)
                        timeSignatureButton(numerator: 4, denominator: 2)
                        timeSignatureButton(numerator: 4, denominator: 4)
                        timeSignatureButton(numerator: 4, denominator: 8)
                        Spacer()
                    }
                }
                .padding(.bottom, 10)
                
                // Compound Time section
                VStack(alignment: .leading, spacing: 15) {
                    // Section header
                    
                    HStack {
                        Text("Compound Time")
                            .font(.headline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.green.opacity(0.2))
                            .cornerRadius(8)
                        
                        Text("Each beat divides into 3 equal parts")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    

                    
                    HStack(spacing: 15) {
                        // Duple row
                        Text("Duple")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 5)
                        timeSignatureButton(numerator: 6, denominator: 4)
                        timeSignatureButton(numerator: 6, denominator: 8)
                        timeSignatureButton(numerator: 6, denominator: 16)
                        Spacer()
                    }

                    
                    HStack(spacing: 15) {
                        
                        // Triple row
                        Text("Triple")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 5)
                        timeSignatureButton(numerator: 9, denominator: 4)
                        timeSignatureButton(numerator: 9, denominator: 8)
                        timeSignatureButton(numerator: 9, denominator: 16)
                        Spacer()
                    }
                    

                    
                    HStack(spacing: 15) {
                        // Quadruple row
                        Text("Quadruple")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 5)
                        timeSignatureButton(numerator: 12, denominator: 4)
                        timeSignatureButton(numerator: 12, denominator: 8)
                        timeSignatureButton(numerator: 12, denominator: 16)
                        Spacer()
                    }
                }
                .padding(.bottom, 10)
                
                // Irregular Time section
                VStack(alignment: .leading, spacing: 15) {
                    
                    HStack {
                        // Section header
                        Text("Irregular Time")
                            .font(.headline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.orange.opacity(0.2))
                            .cornerRadius(8)
                        
                        Text("Uneven groupings of beats")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
   
                    
                    HStack(spacing: 15) {
                        // Quintuple row
                        Text("Quintuple")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 5)
            
                        timeSignatureButton(numerator: 5, denominator: 4)
                        timeSignatureButton(numerator: 5, denominator: 8)
                        Spacer()
                    }
                    

                    
                    HStack(spacing: 15) {
                        // Septuple row
                        Text("Septuple")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 5)
                        timeSignatureButton(numerator: 7, denominator: 4)
                        timeSignatureButton(numerator: 7, denominator: 8)
                        Spacer()
                    }
                }
                
                Divider()
                    .padding(.vertical, 10)
                
                // Custom time signature
                HStack {
                    Spacer()
                    Button(action: {
                        isShowingCustom.toggle()
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Custom Time Signature")
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 15)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    }
                    Spacer()
                }
                
                if isShowingCustom {
                    HStack {
                        Spacer()
                        HStack(spacing: 20) {
                            // Numerator picker
                            VStack {
                                Text("Beats")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                Picker("Numerator", selection: $customNumerator) {
                                    ForEach(1...32, id: \.self) { num in
                                        Text("\(num)").tag(num)
                                    }
                                }
                                .pickerStyle(WheelPickerStyle())
                                .frame(width: 80, height: 100)
                                .clipped()
                            }
                            
                            Text("/")
                                .font(.title)
                                .fontWeight(.bold)
                            
                            // Denominator picker
                            VStack {
                                Text("Note Value")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                Picker("Denominator", selection: $customDenominator) {
                                    ForEach([1, 2, 4, 8, 16, 32], id: \.self) { denom in
                                        Text("\(denom)").tag(denom)
                                    }
                                }
                                .pickerStyle(WheelPickerStyle())
                                .frame(width: 80, height: 100)
                                .clipped()
                            }
                        }
                        Spacer()
                    }
                    
                    HStack {
                        Spacer()
                        Button(action: {
                            metronome.updateTimeSignature(numerator: customNumerator, denominator: customDenominator)
                            isShowingPicker = false
                        }) {
                            Text("Apply Custom")
                                .fontWeight(.medium)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 20)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .padding(.top, 10)
                        Spacer()
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 15)
        }
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
        .frame(maxHeight: UIScreen.main.bounds.height * 0.8)
    }
    
    // Helper function to create consistent time signature buttons
    private func timeSignatureButton(numerator: Int, denominator: Int) -> some View {
        Button(action: {
            metronome.updateTimeSignature(numerator: numerator, denominator: denominator)
            isShowingPicker = false
        }) {
            VStack(spacing: 3) {
                Text("\(numerator)/\(denominator)")
                    .font(.system(size: 16, weight: .semibold))
            }
            .frame(width: 75, height: 40)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        numerator == metronome.beatsPerMeasure &&
                        denominator == metronome.beatUnit ? Color.blue : Color.gray.opacity(0.1)
                    )
            )
            .foregroundColor(
                numerator == metronome.beatsPerMeasure &&
                denominator == metronome.beatUnit ? .white : .primary
            )
        }
    }
}

// MARK: - BPM Display Component with Gestures
struct BPMDisplayView: View {
    @ObservedObject var metronome: MetronomeEngine
    @Binding var isShowingKeypad: Bool
    @State private var dragOffset: CGFloat = 0
    @State private var previousTempo: Double = 120
    
    var body: some View {
        VStack(spacing: 5) {
            Text("\(Int(metronome.tempo))")
                .font(.system(size: 72, weight: .bold, design: .rounded))
                .contentTransition(.numericText())
                .animation(.spring(response: 0.3), value: Int(metronome.tempo))
                // Make the BPM text tappable to show keypad
                .onTapGesture {
                    // Add haptic feedback
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                    
                    isShowingKeypad = true
                }
                // Add vertical swipe gesture
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            dragOffset = value.translation.height
                            
                            // Calculate tempo change based on drag distance
                            // Negative offset (swipe up) increases tempo
                            let tempoChange = -dragOffset * 0.2
                            let newTempo = previousTempo + tempoChange
                            
                            // Update tempo with clamping
                            metronome.updateTempo(to: newTempo)
                        }
                        .onEnded { _ in
                            // Reset drag offset
                            dragOffset = 0
                            // Store the current tempo for next drag
                            previousTempo = metronome.tempo
                            
                            // Add haptic feedback
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()
                        }
                )
            
            Text("BPM")
                .font(.headline)
                .foregroundColor(.gray)
        }
    }
}

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
                // Title
                Text("Roundabeat Metronome")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                
                // BPM Display with gestures
                BPMDisplayView(
                    metronome: metronome,
                    isShowingKeypad: $showBPMKeypad
                )
                
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

// MARK: - App Delegate
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        setupAudioSession()
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Reinitialize audio session when app becomes active
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            
            // Use .playback category for best audio performance
            try audioSession.setCategory(.playback, mode: .default)
            
            // Request a specific buffer duration for lower latency
            try audioSession.setPreferredIOBufferDuration(0.005) // 5ms buffer
            
            // Set sample rate to standard high quality audio
            try audioSession.setPreferredSampleRate(44100)
            
            // Activate the session
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            
            print("✅ Audio session configured successfully")
            print("  - Buffer duration: \(audioSession.ioBufferDuration) seconds")
            print("  - Sample rate: \(audioSession.sampleRate) Hz")
        } catch {
            print("❌ Failed to set up audio session: \(error)")
        }
    }
}

#Preview {
    ContentView()
}
