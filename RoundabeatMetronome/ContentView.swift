

import SwiftUI
import AVFoundation

// MARK: - MetronomeEngine

class MetronomeEngine: ObservableObject {
    @Published var isPlaying = false
    @Published var tempo: Double = 120
    @Published var beatsPerMeasure: Int = 4 // Numerator of time signature
    @Published var beatUnit: Int = 4        // Denominator of time signature (note value)
    @Published var currentBeat: Int = 0
    @Published var showTimeSignatureMenu: Bool = false
    
    // Constants for tempo range
    let minTempo: Double = 40
    let maxTempo: Double = 240
    
    // Audio player pool for more responsive sound
    private var audioPlayers: [AVAudioPlayer] = []
    private var currentPlayerIndex = 0
    private var numberOfPlayers = 3 // Use multiple players to avoid latency
    
    // Use a more precise timing mechanism
    private var displayLink: CADisplayLink?
    private var lastUpdateTime: TimeInterval = 0
    private var beatInterval: TimeInterval = 0.5 // 60.0 / 120 BPM
    private var timeAccumulator: TimeInterval = 0
    
    init() {
        setupAudioPlayers()
        calculateBeatInterval()
    }
    
    private func setupAudioPlayers() {
        // Find the sound file
        let possibleExtensions = ["wav", "mp3", "aiff", "m4a"]
        let possibleNames = ["Woodblock", "woodblock", "Wood Block", "wood_block", "wood-block"]
        
        var soundURL: URL? = nil
        
        // Try different combinations of names and extensions
        for name in possibleNames {
            for ext in possibleExtensions {
                if let url = Bundle.main.url(forResource: name, withExtension: ext) {
                    soundURL = url
                    break
                }
            }
            if soundURL != nil { break }
        }
        
        // If still nil, try locating the sound in the asset catalog
        if soundURL == nil {
            print("Could not find Woodblock sound file directly, trying alternative methods...")
            
            // Try one more approach - look for any sound files in the bundle
            if let resourcePath = Bundle.main.resourcePath {
                let fileManager = FileManager.default
                do {
                    let files = try fileManager.contentsOfDirectory(atPath: resourcePath)
                    for file in files {
                        if file.lowercased().contains("wood") &&
                           (file.hasSuffix(".wav") || file.hasSuffix(".mp3") || file.hasSuffix(".aiff") || file.hasSuffix(".m4a")) {
                            soundURL = URL(fileURLWithPath: resourcePath).appendingPathComponent(file)
                            print("Found potential sound file: \(file)")
                            break
                        }
                    }
                } catch {
                    print("Error scanning bundle directory: \(error)")
                }
            }
        }
        
        // Final fallback - use system sound if possible
        if soundURL == nil {
            print("Still could not find sound file, attempting to use system sound...")
            soundURL = Bundle.main.url(forResource: "click", withExtension: "wav")
        }
        
        // Create multiple audio players from the same sound for better performance
        if let finalURL = soundURL {
            print("Attempting to load sound from: \(finalURL.path)")
            
            // Create a pool of audio players to avoid latency
            for _ in 0..<numberOfPlayers {
                do {
                    let player = try AVAudioPlayer(contentsOf: finalURL)
                    player.prepareToPlay()
                    player.volume = 1.0
                    
                    // Enable rate adjustment for tempo changes without recreating players
                    player.enableRate = true
                    
                    audioPlayers.append(player)
                } catch {
                    print("Failed to initialize audio player: \(error)")
                }
            }
            
            if !audioPlayers.isEmpty {
                print("✅ Successfully created \(audioPlayers.count) audio players")
            } else {
                print("❌ No audio players were created successfully")
            }
        } else {
            print("❌ No suitable sound file found in the app bundle")
        }
    }
    
    private func calculateBeatInterval() {
        // Convert BPM to seconds per beat
        beatInterval = 60.0 / tempo
        print("⏱️ Beat interval set to \(beatInterval) seconds (at \(tempo) BPM)")
    }
    
    func togglePlayback() {
        isPlaying.toggle()
        
        if isPlaying {
            startMetronome()
        } else {
            stopMetronome()
        }
    }
    
    private func startMetronome() {
        // Reset tracking variables
        currentBeat = 0
        lastUpdateTime = CACurrentMediaTime()
        timeAccumulator = 0
        
        // Calculate the beat interval based on current tempo
        calculateBeatInterval()
        
        // Play the first click immediately
        playClick()
        
        // Use CADisplayLink for more precise timing
        displayLink = CADisplayLink(target: self, selector: #selector(updateMetronome))
        displayLink?.preferredFramesPerSecond = 60 // Set to 60fps for smooth timing
        displayLink?.add(to: .main, forMode: .common)
        
        print("🔄 Metronome started at \(tempo) BPM")
    }

    @objc private func updateMetronome(displayLink: CADisplayLink) {
        let currentTime = CACurrentMediaTime()
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        // Accumulate time until we reach the next beat interval
        timeAccumulator += deltaTime
        
        // Check if it's time for the next beat
        if timeAccumulator >= beatInterval {
            // Execute beat - first increment the beat counter
            currentBeat = (currentBeat + 1) % beatsPerMeasure
            
            // Then play the click
            playClick()
            
            // Reset accumulator, accounting for potential overflow
            timeAccumulator -= beatInterval
            
            // If there's still a significant accumulation, adjust further
            if timeAccumulator > beatInterval * 0.1 {
                timeAccumulator = 0
            }
        }
    }
    
    private func stopMetronome() {
        // Stop the display link
        displayLink?.invalidate()
        displayLink = nil
        
        // Reset tracking variables
        timeAccumulator = 0
        currentBeat = 0
        
        print("⏹️ Metronome stopped")
    }
    
    private func playClick() {
        guard !audioPlayers.isEmpty else {
            print("❌ No audio players available")
            return
        }
        
        // Use a player from the pool to prevent audio latency
        let player = audioPlayers[currentPlayerIndex]
        
        // Reset and play
        player.currentTime = 0
        player.play()
        
        // Move to the next player in the pool for the next click
        currentPlayerIndex = (currentPlayerIndex + 1) % audioPlayers.count
        
        // Add visual feedback in the console for debugging
        let beatSymbol = currentBeat == 0 ? "🔵" : "🔴"
        print("\(beatSymbol) Beat \(currentBeat + 1)/\(beatsPerMeasure) at \(String(format: "%.1f", CACurrentMediaTime()))")
    }
    
    func updateTempo(to newTempo: Double) {
        // Ensure tempo is within valid range
        let clampedTempo = max(minTempo, min(maxTempo, newTempo))
        
        if tempo != clampedTempo {
            // Only log when there's a significant change to avoid console spam during dragging
            let tempoChange = abs(tempo - clampedTempo)
            if tempoChange >= 1.0 {
                print("🎯 Tempo updated to \(Int(clampedTempo)) BPM (from \(Int(tempo)))")
            }
            
            tempo = clampedTempo
            calculateBeatInterval()
            
            // Update playback rate of all players for more accurate timing of loaded sounds
            for player in audioPlayers {
                // Adjust playback rate while maintaining pitch
                // This helps with subtle tempo changes without restarting
                let minTempoForRateAdjustment: Double = 80
                let maxTempoForRateAdjustment: Double = 200
                
                if tempo >= minTempoForRateAdjustment && tempo <= maxTempoForRateAdjustment {
                    // Base rate around 120 BPM as the "normal" rate
                    player.rate = Float(tempo / 120.0)
                } else {
                    // For extreme tempos, reset to normal rate
                    player.rate = 1.0
                }
            }
            
            // Only restart metronome for significant tempo changes to avoid stuttering
            // during continuous adjustment like rotary dial gesture
            if isPlaying && tempoChange > 20.0 {
                stopMetronome()
                startMetronome()
            }
        }
    }
    
    // Function to update time signature
    func updateTimeSignature(numerator: Int, denominator: Int) {
        // Ensure values are valid
        let validNumerator = max(1, min(numerator, 32))
        let validDenominator = [1, 2, 4, 8, 16, 32].contains(denominator) ? denominator : 4
        
        beatsPerMeasure = validNumerator
        beatUnit = validDenominator
        
        // Reset current beat if it's now invalid
        if currentBeat >= beatsPerMeasure {
            currentBeat = 0
        }
        
        // If playing, restart to apply the new time signature
        if isPlaying {
            stopMetronome()
            startMetronome()
        }
        
        print("🎼 Time signature updated to \(beatsPerMeasure)/\(beatUnit)")
    }
}

// MARK: - BPM Display Component with Gestures
struct BPMDisplayView: View {
    @ObservedObject var metronome: MetronomeEngine
    @Binding var isShowingKeypad: Bool
    @Binding var showTimeSignaturePicker: Bool
    @State private var dragOffset: CGFloat = 0
    @State private var previousTempo: Double = 120
    
    var body: some View {
        HStack(spacing: 30) {
            // BPM Display with gestures
            VStack(spacing: 5) {
                Text("B P M")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(.gray)
                    .lineLimit(nil)
                  
                
                Text("\(Int(metronome.tempo))")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .contentTransition(.numericText())
                    .fontWeight(.regular)
                    .foregroundColor(Color.white)
                    .animation(.spring(response: 0.3), value: Int(metronome.tempo))
                    .frame(minWidth: 90)
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
            }
            
            // Divider for visual separation
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 1, height: 70)
            
            // Time Signature Button
            VStack(spacing: 5) {
                Text("T I M E")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(.gray)
                    .lineLimit(nil)
                
                Button(action: {
                    showTimeSignaturePicker = true
                }) {
                    Text("\(metronome.beatsPerMeasure)/\(metronome.beatUnit)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .animation(.spring(), value: metronome.beatsPerMeasure)
                        .fontWeight(.regular)
                        .foregroundColor(Color.white)
                        .animation(.spring(), value: metronome.beatUnit)
                        .frame(minWidth: 90)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(20) // Increased padding inside the rounded rectangle
        .frame(width: 280, height: 95)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color("colorDial"))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.black), lineWidth: 2)
        )
        .padding(.top, -100)
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
            
            //Background color
            ZStack {
             //    Base color
                Color("Background")
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
                
                
                
                
                BPMDisplayView(
                    metronome: metronome,
                    isShowingKeypad: $showBPMKeypad,
                    showTimeSignaturePicker: $showTimeSignaturePicker
                )
                
                
                
                
                // Title
                Text("r o u n d a b e a t")
                
                    .font(.body)
                    .fontWeight(.bold)
                    .padding(50)
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.2), radius: 1, x: 1, y: 1) // Dark shadow for depth
                    .shadow(color: .white.opacity(0.1), radius: 1, x: -1, y: -1) // Light highlight for emboss effect
          
                
                
                // Visual Beat Indicator with high-performance animation
                //                HStack(spacing: 15) {
                //                    ForEach(0..<metronome.beatsPerMeasure, id: \.self) { beat in
                //                        // Use ZStack for better animation performance
                //                        ZStack {
                //                            // Background circle
                //                            Circle()
                //                                .frame(width: 20, height: 20)
                //                                .foregroundColor(beat == metronome.currentBeat && metronome.isPlaying ?
                //                                               (beat == 0 ? .blue : .red) : .gray.opacity(0.5))
                //
                //                            // Animated pulse for the active beat
                //                            if beat == metronome.currentBeat && metronome.isPlaying {
                //                                Circle()
                //                                    .frame(width: 20, height: 20)
                //                                    .foregroundColor(beat == 0 ? .blue : .red)
                //                                    .scaleEffect(1.5)
                //                                    .opacity(0)
                //                                    .animation(.easeOut(duration: 0.2).repeatCount(1), value: metronome.currentBeat)
                //                            }
                //                        }
                //                    }
                //                }
                //
                // Tap Tempo Button
                //                Button(action: {
                //                    calculateTapTempo()
                //                }) {
                //                    Text("Tap Tempo")
                //                        .font(.headline)
                //                        .padding(.vertical, 8)
                //                        .padding(.horizontal, 16)
                //                        .background(Color.blue.opacity(0.1))
                //                        .cornerRadius(8)
                //                }
                //                .buttonStyle(PlainButtonStyle())
                
                
                HStack (spacing: 15) {
                    
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
                                    .shadow(color: .black.opacity(0.1), radius: 1, x: 1, y: 1) // Dark shadow for depth
                                    .shadow(color: .white.opacity(0.1), radius: 1, x: -1, y: -1) // Light highlight for emboss effect
                                    .frame(width: 44, height: 44)
                                    .contentShape(Circle())
                            }
                    
                    
                // New Dial Control with Play/Pause Button
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
                        .shadow(color: .black.opacity(0.1), radius: 1, x: 1, y: 1) // Dark shadow for depth
                        .shadow(color: .white.opacity(0.1), radius: 1, x: -1, y: -1) // Light highlight for emboss effect
                        .frame(width: 44, height: 44)
                        .contentShape(Circle())
                }
            }
               
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
