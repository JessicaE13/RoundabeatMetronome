import Foundation
import AVFoundation
import SwiftUI

// MARK: - MetronomeEngine with Persistence and Smooth Sound Switching

class MetronomeEngine: ObservableObject {
    @Published var isPlaying = false
    @Published var tempo: Double = 120 {
        didSet {
            // Save tempo whenever it changes
            UserDefaults.standard.set(tempo, forKey: "SavedTempo")
        }
    }
    @Published var beatsPerMeasure: Int = 4 { // Numerator of time signature
        didSet {
            // Save beats per measure whenever it changes
            UserDefaults.standard.set(beatsPerMeasure, forKey: "SavedBeatsPerMeasure")
        }
    }
    @Published var beatUnit: Int = 4 {        // Denominator of time signature (note value)
        didSet {
            // Save beat unit whenever it changes
            UserDefaults.standard.set(beatUnit, forKey: "SavedBeatUnit")
        }
    }
    @Published var currentBeat: Int = 0
    @Published var showTimeSignatureMenu: Bool = false
    
    // Sound selection with persistence
    @Published var selectedSoundName: String = "Snap" {
        didSet {
            // Save selected sound whenever it changes
            UserDefaults.standard.set(selectedSoundName, forKey: "SavedSoundName")
            // Schedule audio players reload without stopping metronome
            scheduleAudioPlayersReload()
            print("🔊 Sound changed to: \(selectedSoundName)")
        }
    }
    
    // Constants for tempo range
    let minTempo: Double = 20
    let maxTempo: Double = 400
    
    // Audio player pool for more responsive sound
    private var audioPlayers: [AVAudioPlayer] = []
    private var pendingAudioPlayers: [AVAudioPlayer] = [] // New players being prepared
    private var currentPlayerIndex = 0
    private var numberOfPlayers = 3 // Use multiple players to avoid latency
    private var isReloadingAudioPlayers = false
    
    // Use a more precise timing mechanism
    private var displayLink: CADisplayLink?
    private var lastUpdateTime: TimeInterval = 0
    private var beatInterval: TimeInterval = 0.5 // 60.0 / 120 BPM
    private var timeAccumulator: TimeInterval = 0
    private var nextBeatTime: TimeInterval = 0
    private var audioSession: AVAudioSession?
    
    init() {
        // Load saved settings before setting up audio
        loadSavedSettings()
        setupAudioSession()
        setupAudioPlayers()
        calculateBeatInterval()
    }
    
    // MARK: - Persistence Methods
    
    private func loadSavedSettings() {
        // Load tempo (default to 120 if not saved)
        let savedTempo = UserDefaults.standard.object(forKey: "SavedTempo") as? Double ?? 120.0
        tempo = max(minTempo, min(maxTempo, savedTempo))
        
        // Load beats per measure (default to 4 if not saved)
        let savedBeatsPerMeasure = UserDefaults.standard.object(forKey: "SavedBeatsPerMeasure") as? Int ?? 4
        beatsPerMeasure = max(1, min(32, savedBeatsPerMeasure))
        
        // Load beat unit (default to 4 if not saved)
        let savedBeatUnit = UserDefaults.standard.object(forKey: "SavedBeatUnit") as? Int ?? 4
        let validBeatUnits = [1, 2, 4, 8, 16, 32]
        beatUnit = validBeatUnits.contains(savedBeatUnit) ? savedBeatUnit : 4
        
        // Load selected sound (default to "Snap" if not saved)
        let savedSoundName = UserDefaults.standard.string(forKey: "SavedSoundName") ?? "Snap"
        selectedSoundName = savedSoundName
        
        print("📱 Loaded saved settings: \(Int(tempo)) BPM, \(beatsPerMeasure)/\(beatUnit) time signature, \(selectedSoundName) sound")
    }
    
    func saveCurrentSettings() {
        // Explicitly save all current settings
        UserDefaults.standard.set(tempo, forKey: "SavedTempo")
        UserDefaults.standard.set(beatsPerMeasure, forKey: "SavedBeatsPerMeasure")
        UserDefaults.standard.set(beatUnit, forKey: "SavedBeatUnit")
        UserDefaults.standard.set(selectedSoundName, forKey: "SavedSoundName")
        
        print("💾 Settings saved: \(Int(tempo)) BPM, \(beatsPerMeasure)/\(beatUnit), \(selectedSoundName) sound")
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
    
    // MARK: - Improved Audio Players Management
    
    private func scheduleAudioPlayersReload() {
        // Don't reload if already in progress
        guard !isReloadingAudioPlayers else { return }
        
        // If metronome is not playing, reload immediately
        guard isPlaying else {
            setupAudioPlayers()
            return
        }
        
        // If metronome is playing, prepare new players in background
        isReloadingAudioPlayers = true
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            // Create new audio players on background thread
            let newPlayers = self.createAudioPlayers()
            
            DispatchQueue.main.async {
                // Swap the players quickly on the main thread
                self.pendingAudioPlayers = newPlayers
                
                // Wait for the next beat boundary to swap players for smoother transition
                self.swapAudioPlayersOnNextBeat()
            }
        }
    }
    
    private func swapAudioPlayersOnNextBeat() {
        // Use a timer to check for the next beat and swap players then
        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            // Check if we're close to a beat boundary (within 10ms)
            let currentTime = CACurrentMediaTime()
            let timeTillNextBeat = self.nextBeatTime - currentTime
            
            if timeTillNextBeat <= 0.01 || timeTillNextBeat > self.beatInterval {
                // We're at or very close to a beat, safe to swap
                if !self.pendingAudioPlayers.isEmpty {
                    self.audioPlayers = self.pendingAudioPlayers
                    self.pendingAudioPlayers.removeAll()
                    self.currentPlayerIndex = 0
                    self.isReloadingAudioPlayers = false
                    print("🔄 Audio players swapped smoothly during beat")
                }
                timer.invalidate()
            }
        }
        
        // Failsafe: if we can't swap within 2 seconds, force the swap
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            guard let self = self else { return }
            
            if self.isReloadingAudioPlayers && !self.pendingAudioPlayers.isEmpty {
                self.audioPlayers = self.pendingAudioPlayers
                self.pendingAudioPlayers.removeAll()
                self.currentPlayerIndex = 0
                self.isReloadingAudioPlayers = false
                print("🔄 Audio players swapped (failsafe)")
            }
        }
    }
    
    private func createAudioPlayers() -> [AVAudioPlayer] {
        var newPlayers: [AVAudioPlayer] = []
        
        // Find the sound file based on selected sound
        let possibleExtensions = ["wav", "mp3", "aiff", "m4a"]
        
        // Create variations of the selected sound name to try
        let possibleNames = [
            selectedSoundName,
            selectedSoundName.lowercased(),
            selectedSoundName.uppercased(),
            selectedSoundName.replacingOccurrences(of: " ", with: "_"),
            selectedSoundName.replacingOccurrences(of: " ", with: "_").lowercased(),
            selectedSoundName.replacingOccurrences(of: " ", with: "-"),
            selectedSoundName.replacingOccurrences(of: " ", with: "-").lowercased(),
            selectedSoundName.replacingOccurrences(of: " ", with: ""),
            selectedSoundName.replacingOccurrences(of: " ", with: "").lowercased()
        ]
        
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
        
        // If still nil, try to find sound files that contain the selected sound name
        if soundURL == nil {
            if let resourcePath = Bundle.main.resourcePath {
                let fileManager = FileManager.default
                do {
                    let files = try fileManager.contentsOfDirectory(atPath: resourcePath)
                    let searchTerm = selectedSoundName.lowercased().replacingOccurrences(of: " ", with: "")
                    
                    for file in files {
                        let fileName = file.lowercased().replacingOccurrences(of: " ", with: "")
                        if fileName.contains(searchTerm) &&
                           (file.hasSuffix(".wav") || file.hasSuffix(".mp3") || file.hasSuffix(".aiff") || file.hasSuffix(".m4a")) {
                            soundURL = URL(fileURLWithPath: resourcePath).appendingPathComponent(file)
                            break
                        }
                    }
                } catch {
                    print("Error scanning bundle directory: \(error)")
                }
            }
        }
        
        // If still nil, try common fallback sounds
        if soundURL == nil {
            let fallbackSounds = ["Snap", "snap", "bongo", "click", "tick", "beep"]
            for fallback in fallbackSounds {
                for ext in possibleExtensions {
                    if let url = Bundle.main.url(forResource: fallback, withExtension: ext) {
                        soundURL = url
                        break
                    }
                }
                if soundURL != nil { break }
            }
        }
        
        // Create multiple audio players from the same sound for better performance
        if let finalURL = soundURL {
            // Create a pool of audio players to avoid latency
            for i in 0..<numberOfPlayers {
                do {
                    let player = try AVAudioPlayer(contentsOf: finalURL)
                    
                    // Crucial: configure for low latency playback
                    player.volume = 1.0
                    player.enableRate = true  // Allow tempo adjustment
                    player.prepareToPlay()    // Pre-buffer the audio
                    player.numberOfLoops = 0  // Single shot playback
                    
                    newPlayers.append(player)
                } catch {
                    print("❌ Failed to initialize audio player \(i + 1): \(error)")
                }
            }
        }
        
        return newPlayers
    }
    
    private func setupAudioPlayers() {
        audioPlayers = createAudioPlayers()
        currentPlayerIndex = 0
        
        if !audioPlayers.isEmpty {
            print("✅ Successfully created \(audioPlayers.count) audio players for '\(selectedSoundName)'")
        } else {
            print("❌ No audio players were created successfully")
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
        
        // Reset any pending audio player reload
        isReloadingAudioPlayers = false
        pendingAudioPlayers.removeAll()
        
        // Save settings when stopping (good time to persist state)
        saveCurrentSettings()
        
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
        // Use pending players if they're ready, otherwise use current players
        let playersToUse = pendingAudioPlayers.isEmpty ? audioPlayers : pendingAudioPlayers
        
        guard !playersToUse.isEmpty else {
            print("❌ No audio players available")
            return
        }
        
        // Use a player from the pool to prevent audio latency
        let player = playersToUse[currentPlayerIndex % playersToUse.count]
        
        // Reset the player's timing position
        player.currentTime = 0
        
        // Play immediately
        player.play()
        
        // Move to the next player in the pool for the next click
        currentPlayerIndex = (currentPlayerIndex + 1) % playersToUse.count
        
        // Calculate deviation from perfect timing - measure actual time vs scheduled time
        let currentTime = CACurrentMediaTime()
        let expectedTime = nextBeatTime - beatInterval  // For the current beat that just played
        let deviationMs = (currentTime - expectedTime) * 1000  // Convert to milliseconds
        
        // Add visual feedback in the console for debugging
        let beatSymbol = currentBeat == 0 ? "🔵" : "🔴"
        print("\(beatSymbol) Beat \(currentBeat + 1)/\(beatsPerMeasure) [\(selectedSoundName)] at \(String(format: "%.3f", currentTime)) (deviation: \(String(format: "%.1f", deviationMs))ms)")
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
            let allPlayers = audioPlayers + pendingAudioPlayers
            for player in allPlayers {
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
    
    // MARK: - Improved Sound Selection Method
    
    func updateSoundSelection(to soundName: String) {
        selectedSoundName = soundName
        print("🔊 Sound selection updated to: \(soundName)")
        // The scheduleAudioPlayersReload() will be called automatically via the didSet observer
    }
    
    // MARK: - App Lifecycle Methods
    
    func handleAppWillTerminate() {
        // Save settings when app is about to terminate
        saveCurrentSettings()
        print("📱 App terminating - settings saved")
    }
    
    func handleAppDidEnterBackground() {
        // Save settings when app goes to background
        saveCurrentSettings()
        print("📱 App backgrounded - settings saved")
    }
}
