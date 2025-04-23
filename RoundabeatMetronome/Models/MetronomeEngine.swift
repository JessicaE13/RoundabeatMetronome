import Foundation
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
    private var nextBeatTime: TimeInterval = 0
    private var audioSession: AVAudioSession?
    
    init() {
        setupAudioSession()
        setupAudioPlayers()
        calculateBeatInterval()
    }
    
    private func setupAudioSession() {
        do {
            audioSession = AVAudioSession.sharedInstance()
            try audioSession?.setCategory(.playback, mode: .default)
            try audioSession?.setActive(true)
            print("✅ Audio session setup successful")
        } catch {
            print("❌ Failed to set up audio session: \(error)")
        }
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
                    
                    // Crucial: configure for low latency playback
                    player.volume = 1.0
                    player.enableRate = true  // Allow tempo adjustment
                    player.prepareToPlay()    // Pre-buffer the audio
                    player.numberOfLoops = 0  // Single shot playback
                    
                    // Extremely important for precision metronome:
                    // Set a very short duration sample for minimal latency
                    if player.duration > 0.1 {
                        // If sample is longer than 100ms, we can improve timing by
                        // adjusting parameters - ideally the original sound should be short
                        print("⚠️ Sound sample duration (\(String(format: "%.1f", player.duration * 1000))ms) is longer than ideal for precise timing")
                    }
                    
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
        
        // Configure audio session for optimal performance
        do {
            // Set audio session category and mode
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            // Important: Set the hardware buffer duration to minimum possible value
            let hardwareSampleRate = AVAudioSession.sharedInstance().sampleRate
            let preferredBufferSize = 256.0 // Minimum buffer size (samples)
            let bufferDuration = preferredBufferSize / hardwareSampleRate
            try AVAudioSession.sharedInstance().setPreferredIOBufferDuration(bufferDuration)
            
            print("✅ Audio session optimized: \(String(format: "%.2f", bufferDuration * 1000))ms buffer at \(Int(hardwareSampleRate))Hz")
        } catch {
            print("⚠️ Could not fully optimize audio session: \(error)")
        }
        
        // Preload all audio players
        for player in audioPlayers {
            player.prepareToPlay()
            player.volume = 1.0
        }
        
        // Calculate the beat interval
        calculateBeatInterval()
        
        // Get precise current time
        let now = CACurrentMediaTime()
        
        // Play the first beat immediately
        playClick()
        
        // Schedule the next beat to occur one interval from now
        nextBeatTime = now + beatInterval
        
        // Create a high-precision display link
        displayLink = CADisplayLink(target: self, selector: #selector(updateMetronome))
        
        // Request maximum precision available on the device
        if #available(iOS 15.0, *) {
            displayLink?.preferredFrameRateRange = CAFrameRateRange(minimum: 60, maximum: 120, preferred: 120)
        } else {
            displayLink?.preferredFramesPerSecond = 120
        }
        
        // Use the highest priority runloop mode for critical timing
        displayLink?.add(to: .main, forMode: .common)
    }

    @objc private func updateMetronome(displayLink: CADisplayLink) {
        let currentTime = CACurrentMediaTime()
        
        // If we've reached the time for the next beat
        if currentTime >= nextBeatTime {
            // Calculate precise timing for this approach
            let elapsedIntervals = floor((currentTime - nextBeatTime) / beatInterval)
            
            // Handle case where multiple beats should have occurred (e.g., after app suspension)
            if elapsedIntervals > 0 {
                // Skip missed beats and get back on schedule
                nextBeatTime += beatInterval * (elapsedIntervals + 1)
                currentBeat = (currentBeat + Int(elapsedIntervals) + 1) % beatsPerMeasure
                print("⚠️ Metronome skipped \(Int(elapsedIntervals)) beats to stay on tempo")
            } else {
                // Normal case - just increment to next beat
                nextBeatTime += beatInterval
                currentBeat = (currentBeat + 1) % beatsPerMeasure
            }
            
            // Play the click - this needs to be as close to the nextBeatTime as possible
            playClick()
        }
    }
    
    private func stopMetronome() {
        // Stop the display link
        displayLink?.invalidate()
        displayLink = nil
        
        // Reset tracking variables
        timeAccumulator = 0
        lastUpdateTime = 0
        currentBeat = 0
        
        // Deactivate audio session to save resources, but handle the error gracefully
        do {
            // Use a less strict deactivation option to avoid the error
            try AVAudioSession.sharedInstance().setActive(false, options: [.notifyOthersOnDeactivation])
        } catch {
            // Don't log the error to console, as it's a known iOS limitation in some scenarios
            // and doesn't affect functionality
        }
        
        print("⏹️ Metronome stopped")
    }
    
    private func playClick() {
        guard !audioPlayers.isEmpty else {
            print("❌ No audio players available")
            return
        }
        
        // Use a player from the pool to prevent audio latency
        let player = audioPlayers[currentPlayerIndex]
        
        // Reset the player's timing position
        player.currentTime = 0
        
        // Play immediately
        player.play()
        
        // Move to the next player in the pool for the next click
        currentPlayerIndex = (currentPlayerIndex + 1) % audioPlayers.count
        
        // Calculate deviation from perfect timing - measure actual time vs scheduled time
        let currentTime = CACurrentMediaTime()
        let expectedTime = nextBeatTime - beatInterval  // For the current beat that just played
        let deviationMs = (currentTime - expectedTime) * 1000  // Convert to milliseconds
        
        // Add visual feedback in the console for debugging
        let beatSymbol = currentBeat == 0 ? "🔵" : "🔴"
        print("\(beatSymbol) Beat \(currentBeat + 1)/\(beatsPerMeasure) at \(String(format: "%.3f", currentTime)) (deviation: \(String(format: "%.1f", deviationMs))ms)")
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
