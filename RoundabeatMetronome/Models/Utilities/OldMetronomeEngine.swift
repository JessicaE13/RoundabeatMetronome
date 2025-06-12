//import Foundation
//import AVFoundation
//import SwiftUI
//
//// MARK: - MetronomeEngine with Persistence, Smooth Sound Switching, and Subdivision Support
//
//class MetronomeEngine: ObservableObject {
//    @Published var isPlaying = false
//    @Published var tempo: Double = 120 {
//        didSet {
//            // Save tempo whenever it changes
//            UserDefaults.standard.set(tempo, forKey: "SavedTempo")
//        }
//    }
//    @Published var beatsPerMeasure: Int = 4 { // Numerator of time signature
//        didSet {
//            // Save beats per measure whenever it changes
//            UserDefaults.standard.set(beatsPerMeasure, forKey: "SavedBeatsPerMeasure")
//        }
//    }
//    @Published var beatUnit: Int = 4 {        // Denominator of time signature (note value)
//        didSet {
//            // Save beat unit whenever it changes
//            UserDefaults.standard.set(beatUnit, forKey: "SavedBeatUnit")
//        }
//    }
//    @Published var currentBeat: Int = 0
//    @Published var showTimeSignatureMenu: Bool = false
//
//    // Sound selection with persistence
//    @Published var selectedSoundName: String = "Snap" {
//        didSet {
//            // Save selected sound whenever it changes
//            UserDefaults.standard.set(selectedSoundName, forKey: "SavedSoundName")
//            // Schedule audio players reload without stopping metronome
//            scheduleAudioPlayersReload()
//            print("🔊 Sound changed to: \(selectedSoundName)")
//        }
//    }
//
//    // Highlight first beat setting with persistence
//    @Published var highlightFirstBeat: Bool = true {
//        didSet {
//            // Save highlight first beat setting whenever it changes
//            UserDefaults.standard.set(highlightFirstBeat, forKey: "SavedHighlightFirstBeat")
//            print("🎨 Highlight first beat: \(highlightFirstBeat ? "enabled" : "disabled")")
//        }
//    }
//
//    // Subdivision support with persistence
//    @Published var subdivisionMultiplier: Double = 1.0 {
//        didSet {
//            // Save subdivision whenever it changes
//            UserDefaults.standard.set(subdivisionMultiplier, forKey: "SavedSubdivisionMultiplier")
//            print("🎵 Subdivision updated to \(subdivisionMultiplier)x")
//        }
//    }
//
//    // Constants for tempo range
//    let minTempo: Double = 20
//    let maxTempo: Double = 400
//
//    // Audio player pool for more responsive sound
//    private var audioPlayers: [AVAudioPlayer] = []
//    private var pendingAudioPlayers: [AVAudioPlayer] = [] // New players being prepared
//    private var currentPlayerIndex = 0
//    private var numberOfPlayers = 3 // Use multiple players to avoid latency
//    private var isReloadingAudioPlayers = false
//
//    // Use a more precise timing mechanism
//    private var displayLink: CADisplayLink?
//    private var lastUpdateTime: TimeInterval = 0
//    private var beatInterval: TimeInterval = 0.5 // 60.0 / 120 BPM
//    private var subdivisionInterval: TimeInterval = 0.5
//    private var timeAccumulator: TimeInterval = 0
//    private var nextBeatTime: TimeInterval = 0
//    private var audioSession: AVAudioSession?
//
//    // Subdivision tracking
//    private var subdivisionCounter: Int = 0
//
//    init() {
//        // Load saved settings before setting up audio
//        loadSavedSettings()
//        setupAudioSession()
//        setupAudioPlayers()
//        calculateBeatInterval()
//    }
//
//    // MARK: - Persistence Methods
//
//    private func loadSavedSettings() {
//        // Load tempo (default to 120 if not saved)
//        let savedTempo = UserDefaults.standard.object(forKey: "SavedTempo") as? Double ?? 120.0
//        tempo = max(minTempo, min(maxTempo, savedTempo))
//
//        // Load beats per measure (default to 4 if not saved)
//        let savedBeatsPerMeasure = UserDefaults.standard.object(forKey: "SavedBeatsPerMeasure") as? Int ?? 4
//        beatsPerMeasure = max(1, min(32, savedBeatsPerMeasure))
//
//        // Load beat unit (default to 4 if not saved)
//        let savedBeatUnit = UserDefaults.standard.object(forKey: "SavedBeatUnit") as? Int ?? 4
//        let validBeatUnits = [1, 2, 4, 8, 16, 32]
//        beatUnit = validBeatUnits.contains(savedBeatUnit) ? savedBeatUnit : 4
//
//        // Load selected sound (default to "Snap" if not saved)
//        let savedSoundName = UserDefaults.standard.string(forKey: "SavedSoundName") ?? "Snap"
//        selectedSoundName = savedSoundName
//
//        // Load highlight first beat setting (default to true if not saved)
//        let savedHighlightFirstBeat = UserDefaults.standard.object(forKey: "SavedHighlightFirstBeat") as? Bool ?? true
//        highlightFirstBeat = savedHighlightFirstBeat
//
//        // Load subdivision multiplier (default to 1.0 if not saved)
//        let savedSubdivisionMultiplier = UserDefaults.standard.object(forKey: "SavedSubdivisionMultiplier") as? Double ?? 1.0
//        subdivisionMultiplier = max(0.5, min(4.0, savedSubdivisionMultiplier))
//
//        print("📱 Loaded saved settings: \(Int(tempo)) BPM, \(beatsPerMeasure)/\(beatUnit) time signature, \(selectedSoundName) sound, highlight first beat: \(highlightFirstBeat), subdivision: \(subdivisionMultiplier)x")
//    }
//
//    func saveCurrentSettings() {
//        // Explicitly save all current settings
//        UserDefaults.standard.set(tempo, forKey: "SavedTempo")
//        UserDefaults.standard.set(beatsPerMeasure, forKey: "SavedBeatsPerMeasure")
//        UserDefaults.standard.set(beatUnit, forKey: "SavedBeatUnit")
//        UserDefaults.standard.set(selectedSoundName, forKey: "SavedSoundName")
//        UserDefaults.standard.set(highlightFirstBeat, forKey: "SavedHighlightFirstBeat")
//        UserDefaults.standard.set(subdivisionMultiplier, forKey: "SavedSubdivisionMultiplier")
//
//        print("💾 Settings saved: \(Int(tempo)) BPM, \(beatsPerMeasure)/\(beatUnit), \(selectedSoundName) sound, highlight first beat: \(highlightFirstBeat), subdivision: \(subdivisionMultiplier)x")
//    }
//
//    private func setupAudioSession() {
//        do {
//            audioSession = AVAudioSession.sharedInstance()
//            try audioSession?.setCategory(.playback, mode: .default)
//            try audioSession?.setActive(true)
//            print("✅ Audio session setup successful")
//        } catch {
//            print("❌ Failed to set up audio session: \(error)")
//        }
//    }
//
//    // MARK: - Improved Audio Players Management
//
//    private func scheduleAudioPlayersReload() {
//        // Don't reload if already in progress
//        guard !isReloadingAudioPlayers else { return }
//
//        // If metronome is not playing, reload immediately
//        guard isPlaying else {
//            setupAudioPlayers()
//            return
//        }
//
//        // If metronome is playing, prepare new players in background
//        isReloadingAudioPlayers = true
//
//        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
//            guard let self = self else { return }
//
//            // Create new audio players on background thread
//            let newPlayers = self.createAudioPlayers()
//
//            DispatchQueue.main.async {
//                // Swap the players quickly on the main thread
//                self.pendingAudioPlayers = newPlayers
//
//                // Wait for the next beat boundary to swap players for smoother transition
//                self.swapAudioPlayersOnNextBeat()
//            }
//        }
//    }
//
//    private func swapAudioPlayersOnNextBeat() {
//        // Use a timer to check for the optimal swap timing
//        Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true) { [weak self] timer in
//            guard let self = self else {
//                timer.invalidate()
//                return
//            }
//
//            let currentTime = CACurrentMediaTime()
//            let timeTillNextBeat = self.nextBeatTime - currentTime
//
//            // Swap right after a beat has been triggered but before the next one
//            // This gives us a full beat interval to settle the new players
//            if timeTillNextBeat <= -0.002 && timeTillNextBeat >= -0.020 {
//                if !self.pendingAudioPlayers.isEmpty {
//                    // Ensure all new players are fully prepared and synchronized
//                    for (_, player) in self.pendingAudioPlayers.enumerated() {
//                        player.prepareToPlay()
//                        player.currentTime = 0
//
//                        // Set the correct rate for current tempo
//                        let minTempoForRateAdjustment: Double = 80
//                        let maxTempoForRateAdjustment: Double = 200
//
//                        if self.tempo >= minTempoForRateAdjustment && self.tempo <= maxTempoForRateAdjustment {
//                            player.rate = Float(self.tempo / 120.0)
//                        } else {
//                            player.rate = 1.0
//                        }
//                    }
//
//                    // Stop any currently playing sounds from old players
//                    for player in self.audioPlayers {
//                        if player.isPlaying {
//                            player.stop()
//                        }
//                    }
//
//                    // Swap to new players
//                    self.audioPlayers = self.pendingAudioPlayers
//                    self.pendingAudioPlayers.removeAll()
//
//                    // Reset player index to start fresh with new players
//                    self.currentPlayerIndex = 0
//                    self.isReloadingAudioPlayers = false
//
//                    print("🔄 Audio players swapped and synchronized at beat boundary")
//                }
//                timer.invalidate()
//                return
//            }
//
//            // Safety fallback if we miss the optimal timing window
//            if timeTillNextBeat < -self.beatInterval * 0.5 {
//                if !self.pendingAudioPlayers.isEmpty {
//                    // Prepare new players
//                    for player in self.pendingAudioPlayers {
//                        player.prepareToPlay()
//                        player.currentTime = 0
//
//                        let minTempoForRateAdjustment: Double = 80
//                        let maxTempoForRateAdjustment: Double = 200
//
//                        if self.tempo >= minTempoForRateAdjustment && self.tempo <= maxTempoForRateAdjustment {
//                            player.rate = Float(self.tempo / 120.0)
//                        } else {
//                            player.rate = 1.0
//                        }
//                    }
//
//                    // Stop old players
//                    for player in self.audioPlayers {
//                        if player.isPlaying {
//                            player.stop()
//                        }
//                    }
//
//                    self.audioPlayers = self.pendingAudioPlayers
//                    self.pendingAudioPlayers.removeAll()
//                    self.currentPlayerIndex = 0
//                    self.isReloadingAudioPlayers = false
//
//                    print("🔄 Audio players swapped (safety fallback with sync)")
//                }
//                timer.invalidate()
//            }
//        }
//
//        // Ultimate failsafe
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
//            guard let self = self else { return }
//
//            if self.isReloadingAudioPlayers && !self.pendingAudioPlayers.isEmpty {
//                // Final preparation
//                for player in self.pendingAudioPlayers {
//                    player.prepareToPlay()
//                    player.currentTime = 0
//
//                    if self.tempo >= 80 && self.tempo <= 200 {
//                        player.rate = Float(self.tempo / 120.0)
//                    } else {
//                        player.rate = 1.0
//                    }
//                }
//
//                for player in self.audioPlayers {
//                    if player.isPlaying {
//                        player.stop()
//                    }
//                }
//
//                self.audioPlayers = self.pendingAudioPlayers
//                self.pendingAudioPlayers.removeAll()
//                self.currentPlayerIndex = 0
//                self.isReloadingAudioPlayers = false
//
//                print("🔄 Audio players swapped (emergency failsafe with full sync)")
//            }
//        }
//    }
//
//    private func createAudioPlayers() -> [AVAudioPlayer] {
//        var newPlayers: [AVAudioPlayer] = []
//
//        // Find the sound file based on selected sound
//        let possibleExtensions = ["wav", "mp3", "aiff", "m4a"]
//
//        // Create variations of the selected sound name to try
//        let possibleNames = [
//            selectedSoundName,
//            selectedSoundName.lowercased(),
//            selectedSoundName.uppercased(),
//            selectedSoundName.replacingOccurrences(of: " ", with: "_"),
//            selectedSoundName.replacingOccurrences(of: " ", with: "_").lowercased(),
//            selectedSoundName.replacingOccurrences(of: " ", with: "-"),
//            selectedSoundName.replacingOccurrences(of: " ", with: "-").lowercased(),
//            selectedSoundName.replacingOccurrences(of: " ", with: ""),
//            selectedSoundName.replacingOccurrences(of: " ", with: "").lowercased()
//        ]
//
//        var soundURL: URL? = nil
//
//        // Try different combinations of names and extensions
//        for name in possibleNames {
//            for ext in possibleExtensions {
//                if let url = Bundle.main.url(forResource: name, withExtension: ext) {
//                    soundURL = url
//                    break
//                }
//            }
//            if soundURL != nil { break }
//        }
//
//        // If still nil, try to find sound files that contain the selected sound name
//        if soundURL == nil {
//            if let resourcePath = Bundle.main.resourcePath {
//                let fileManager = FileManager.default
//                do {
//                    let files = try fileManager.contentsOfDirectory(atPath: resourcePath)
//                    let searchTerm = selectedSoundName.lowercased().replacingOccurrences(of: " ", with: "")
//
//                    for file in files {
//                        let fileName = file.lowercased().replacingOccurrences(of: " ", with: "")
//                        if fileName.contains(searchTerm) &&
//                           (file.hasSuffix(".wav") || file.hasSuffix(".mp3") || file.hasSuffix(".aiff") || file.hasSuffix(".m4a")) {
//                            soundURL = URL(fileURLWithPath: resourcePath).appendingPathComponent(file)
//                            break
//                        }
//                    }
//                } catch {
//                    print("Error scanning bundle directory: \(error)")
//                }
//            }
//        }
//
//        // If still nil, try common fallback sounds
//        if soundURL == nil {
//            let fallbackSounds = ["Snap", "snap", "bongo", "click", "tick", "beep"]
//            for fallback in fallbackSounds {
//                for ext in possibleExtensions {
//                    if let url = Bundle.main.url(forResource: fallback, withExtension: ext) {
//                        soundURL = url
//                        break
//                    }
//                }
//                if soundURL != nil { break }
//            }
//        }
//
//        // Create multiple audio players from the same sound for better performance
//        if let finalURL = soundURL {
//            // Create a pool of audio players to avoid latency
//            for i in 0..<numberOfPlayers {
//                do {
//                    let player = try AVAudioPlayer(contentsOf: finalURL)
//
//                    // Crucial: configure for low latency playback
//                    player.volume = 1.0
//                    player.enableRate = true  // Allow tempo adjustment
//                    player.numberOfLoops = 0  // Single shot playback
//
//                    // CRITICAL: Properly prepare and prime the player for immediate playback
//                    player.prepareToPlay()    // Pre-buffer the audio
//
//                    // Set the correct playback rate to match current tempo
//                    let minTempoForRateAdjustment: Double = 80
//                    let maxTempoForRateAdjustment: Double = 200
//
//                    if tempo >= minTempoForRateAdjustment && tempo <= maxTempoForRateAdjustment {
//                        player.rate = Float(tempo / 120.0)
//                    } else {
//                        player.rate = 1.0
//                    }
//
//                    // IMPORTANT: Prime the audio engine by playing a silent/zero-length sound
//                    // This ensures the audio subsystem is ready for precise timing
//                    let originalVolume = player.volume
//                    player.volume = 0.0  // Make it silent
//                    player.play()        // Start and immediately stop to prime the engine
//                    player.stop()
//                    player.currentTime = 0
//                    player.volume = originalVolume  // Restore volume
//
//                    // Prepare again after priming
//                    player.prepareToPlay()
//
//                    newPlayers.append(player)
//
//                } catch {
//                    print("❌ Failed to initialize audio player \(i + 1): \(error)")
//                }
//            }
//
//            // Additional warming: If metronome is currently playing, synchronize with beat timing
//            if isPlaying && !newPlayers.isEmpty {
//                // Calculate when the next beat should occur
//                let currentTime = CACurrentMediaTime()
//                let timeToNextBeat = nextBeatTime - currentTime
//
//                // Pre-warm the first player to be ready at exactly the right time
//                if timeToNextBeat > 0.01 { // If we have enough time
//                    DispatchQueue.main.asyncAfter(deadline: .now() + max(0, timeToNextBeat - 0.005)) {
//                        // Pre-position the first player to be ready
//                        if let firstPlayer = newPlayers.first {
//                            firstPlayer.prepareToPlay()
//                            firstPlayer.currentTime = 0
//                        }
//                    }
//                }
//            }
//        }
//
//        return newPlayers
//    }
//
//    private func setupAudioPlayers() {
//        audioPlayers = createAudioPlayers()
//        currentPlayerIndex = 0
//
//        if !audioPlayers.isEmpty {
//            print("✅ Successfully created \(audioPlayers.count) audio players for '\(selectedSoundName)'")
//        } else {
//            print("❌ No audio players were created successfully")
//        }
//    }
//
//    private func calculateBeatInterval() {
//        // Convert BPM to seconds per beat, then apply subdivision
//        let baseBeatInterval = 60.0 / tempo
//        subdivisionInterval = baseBeatInterval / subdivisionMultiplier
//        beatInterval = subdivisionInterval
//        print("⏱️ Beat interval set to \(beatInterval) seconds (at \(tempo) BPM with \(subdivisionMultiplier)x subdivision)")
//    }
//
//    func togglePlayback() {
//        isPlaying.toggle()
//
//        if isPlaying {
//            startMetronome()
//        } else {
//            stopMetronome()
//        }
//    }
//
//    private func startMetronome() {
//        // Reset tracking variables
//        currentBeat = 0
//        subdivisionCounter = 0
//
//        // Configure audio session for optimal performance
//        do {
//            // Set audio session category and mode
//            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
//            try AVAudioSession.sharedInstance().setActive(true)
//
//            // Important: Set the hardware buffer duration to minimum possible value
//            let hardwareSampleRate = AVAudioSession.sharedInstance().sampleRate
//            let preferredBufferSize = 256.0 // Minimum buffer size (samples)
//            let bufferDuration = preferredBufferSize / hardwareSampleRate
//            try AVAudioSession.sharedInstance().setPreferredIOBufferDuration(bufferDuration)
//
//            print("✅ Audio session optimized: \(String(format: "%.2f", bufferDuration * 1000))ms buffer at \(Int(hardwareSampleRate))Hz")
//        } catch {
//            print("⚠️ Could not fully optimize audio session: \(error)")
//        }
//
//        // Preload all audio players
//        for player in audioPlayers {
//            player.prepareToPlay()
//            player.volume = 1.0
//        }
//
//        // Calculate the beat interval with subdivision
//        calculateBeatInterval()
//
//        // Get precise current time
//        let now = CACurrentMediaTime()
//
//        // Play the first click immediately
//        playClick()
//
//        // Schedule the next subdivision to occur one interval from now
//        nextBeatTime = now + beatInterval
//
//        // Create a high-precision display link
//        displayLink = CADisplayLink(target: self, selector: #selector(updateMetronome))
//
//        // Request maximum precision available on the device
//        if #available(iOS 15.0, *) {
//            displayLink?.preferredFrameRateRange = CAFrameRateRange(minimum: 60, maximum: 120, preferred: 120)
//        } else {
//            displayLink?.preferredFramesPerSecond = 120
//        }
//
//        // Use the highest priority runloop mode for critical timing
//        displayLink?.add(to: .main, forMode: .common)
//    }
//
//    @objc private func updateMetronome(displayLink: CADisplayLink) {
//        let currentTime = CACurrentMediaTime()
//
//        // If we've reached the time for the next subdivision
//        if currentTime >= nextBeatTime {
//            // Calculate precise timing for this approach
//            let elapsedIntervals = floor((currentTime - nextBeatTime) / beatInterval)
//
//            // Handle case where multiple beats should have occurred (e.g., after app suspension)
//            if elapsedIntervals > 0 {
//                // Skip missed beats and get back on schedule
//                nextBeatTime += beatInterval * (elapsedIntervals + 1)
//                subdivisionCounter = Int((subdivisionCounter + Int(elapsedIntervals) + 1) % Int(subdivisionMultiplier * Double(beatsPerMeasure)))
//                print("⚠️ Metronome skipped \(Int(elapsedIntervals)) subdivision clicks to stay on tempo")
//            } else {
//                // Normal case - just increment to next subdivision
//                nextBeatTime += beatInterval
//                subdivisionCounter = (subdivisionCounter + 1) % Int(subdivisionMultiplier * Double(beatsPerMeasure))
//            }
//
//            // Calculate which beat we're on based on subdivision counter
//            let currentBeatFromSubdivision = Int(floor(Double(subdivisionCounter) / subdivisionMultiplier))
//            currentBeat = currentBeatFromSubdivision % beatsPerMeasure
//
//            // Play the click - this needs to be as close to the nextBeatTime as possible
//            playClick()
//        }
//    }
//
//    private func stopMetronome() {
//        // Stop the display link
//        displayLink?.invalidate()
//        displayLink = nil
//
//        // Reset tracking variables
//        timeAccumulator = 0
//        lastUpdateTime = 0
//        currentBeat = 0
//        subdivisionCounter = 0
//
//        // Reset any pending audio player reload
//        isReloadingAudioPlayers = false
//        pendingAudioPlayers.removeAll()
//
//        // Save settings when stopping (good time to persist state)
//        saveCurrentSettings()
//
//        // Deactivate audio session to save resources, but handle the error gracefully
//        do {
//            // Use a less strict deactivation option to avoid the error
//            try AVAudioSession.sharedInstance().setActive(false, options: [.notifyOthersOnDeactivation])
//        } catch {
//            // Don't log the error to console, as it's a known iOS limitation in some scenarios
//            // and doesn't affect functionality
//        }
//
//        print("⏹️ Metronome stopped")
//    }
//
//    private func playClick() {
//        // Always use current players, never pending players during playback
//        let playersToUse = audioPlayers
//
//        guard !playersToUse.isEmpty else {
//            print("❌ No audio players available")
//            return
//        }
//
//        // Ensure we don't exceed the player pool bounds
//        guard currentPlayerIndex < playersToUse.count else {
//            currentPlayerIndex = 0
//            print("⚠️ Player index reset due to pool size mismatch")
//            return
//        }
//
//        // Get the current player
//        let player = playersToUse[currentPlayerIndex]
//
//        // Determine if this is a main beat or subdivision
//        let isMainBeat = subdivisionCounter % Int(subdivisionMultiplier) == 0
//        let currentMainBeat = Int(floor(Double(subdivisionCounter) / subdivisionMultiplier)) % beatsPerMeasure
//
//        // Adjust volume based on whether it's a main beat or subdivision
//        if isMainBeat {
//            player.volume = 1.0 // Full volume for main beats
//        } else {
//            player.volume = 0.6 // Quieter for subdivisions
//        }
//
//        // Reset the current player's timing position
//        player.currentTime = 0
//
//        // Play the current subdivision immediately
//        player.play()
//
//        // Calculate the previous player index
//        let previousPlayerIndex = (currentPlayerIndex - 1 + playersToUse.count) % playersToUse.count
//
//        // Stop the previous player now that the current one is playing
//        if previousPlayerIndex != currentPlayerIndex { // Safety check for single player scenarios
//            let previousPlayer = playersToUse[previousPlayerIndex]
//            if previousPlayer.isPlaying {
//                previousPlayer.stop()
//                previousPlayer.currentTime = 0
//            }
//        }
//
//        // Move to the next player in the pool for the next click
//        currentPlayerIndex = (currentPlayerIndex + 1) % playersToUse.count
//
//        // Calculate deviation from perfect timing
//        let currentTime = CACurrentMediaTime()
//        let expectedTime = nextBeatTime - beatInterval
//        let deviationMs = (currentTime - expectedTime) * 1000
//
//        // Debug output
//        let beatSymbol = isMainBeat ? (currentMainBeat == 0 ? "🔵" : "🔴") : "⚪"
//        let subdivisionInfo = isMainBeat ? "Beat \(currentMainBeat + 1)" : "Sub \(subdivisionCounter % Int(subdivisionMultiplier) + 1)"
//        print("\(beatSymbol) \(subdivisionInfo)/\(beatsPerMeasure) [\(selectedSoundName)] at \(String(format: "%.3f", currentTime)) (deviation: \(String(format: "%.1f", deviationMs))ms)")
//    }
//
//    func updateTempo(to newTempo: Double) {
//        // Ensure tempo is within valid range
//        let clampedTempo = max(minTempo, min(maxTempo, newTempo))
//
//        if tempo != clampedTempo {
//            // Only log when there's a significant change to avoid console spam during dragging
//            let tempoChange = abs(tempo - clampedTempo)
//            if tempoChange >= 1.0 {
//                print("🎯 Tempo updated to \(Int(clampedTempo)) BPM (from \(Int(tempo)))")
//            }
//
//            tempo = clampedTempo
//            calculateBeatInterval()
//
//            // Update playback rate of all players for more accurate timing of loaded sounds
//            let allPlayers = audioPlayers + pendingAudioPlayers
//            for player in allPlayers {
//                // Adjust playback rate while maintaining pitch
//                // This helps with subtle tempo changes without restarting
//                let minTempoForRateAdjustment: Double = 80
//                let maxTempoForRateAdjustment: Double = 200
//
//                if tempo >= minTempoForRateAdjustment && tempo <= maxTempoForRateAdjustment {
//                    // Base rate around 120 BPM as the "normal" rate
//                    player.rate = Float(tempo / 120.0)
//                } else {
//                    // For extreme tempos, reset to normal rate
//                    player.rate = 1.0
//                }
//            }
//
//            // Only restart metronome for significant tempo changes to avoid stuttering
//            // during continuous adjustment like rotary dial gesture
//            if isPlaying && tempoChange > 20.0 {
//                stopMetronome()
//                startMetronome()
//            }
//        }
//    }
//
//    // Function to update time signature
//    func updateTimeSignature(numerator: Int, denominator: Int) {
//        // Ensure values are valid
//        let validNumerator = max(1, min(numerator, 32))
//        let validDenominator = [1, 2, 4, 8, 16, 32].contains(denominator) ? denominator : 4
//
//        beatsPerMeasure = validNumerator
//        beatUnit = validDenominator
//
//        // Reset current beat if it's now invalid
//        if currentBeat >= beatsPerMeasure {
//            currentBeat = 0
//        }
//
//        // If playing, restart to apply the new time signature
//        if isPlaying {
//            stopMetronome()
//            startMetronome()
//        }
//
//        print("🎼 Time signature updated to \(beatsPerMeasure)/\(beatUnit)")
//    }
//
//    // Function to update subdivision
//    func updateSubdivision(to newMultiplier: Double) {
//        // Ensure subdivision is within valid range
//        let clampedMultiplier = max(0.5, min(4.0, newMultiplier))
//
//        if subdivisionMultiplier != clampedMultiplier {
//            print("🎵 Subdivision updated to \(clampedMultiplier)x (from \(subdivisionMultiplier)x)")
//
//            subdivisionMultiplier = clampedMultiplier
//            calculateBeatInterval()
//
//            // If playing, restart to apply the new subdivision
//            if isPlaying {
//                stopMetronome()
//                startMetronome()
//            }
//        }
//    }
//
//    // MARK: - Improved Sound Selection Method
//
//    func updateSoundSelection(to soundName: String) {
//        selectedSoundName = soundName
//        print("🔊 Sound selection updated to: \(soundName)")
//        // The scheduleAudioPlayersReload() will be called automatically via the didSet observer
//    }
//
//    // MARK: - App Lifecycle Methods
//
//    func handleAppWillTerminate() {
//        // Save settings when app is about to terminate
//        saveCurrentSettings()
//        print("📱 App terminating - settings saved")
//    }
//
//    func handleAppDidEnterBackground() {
//        // Save settings when app goes to background
//        saveCurrentSettings()
//        print("📱 App backgrounded - settings saved")
//    }
//}
