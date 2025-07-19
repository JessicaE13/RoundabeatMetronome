import SwiftUI
import AVFoundation

// MARK: - Synthetic Sound Types
enum SyntheticSound: String, CaseIterable {
    case click = "Synthetic Click"
    case snap = "Snap"
    case beep = "Beep"
    case blip = "Blip"
    
    var description: String {
        switch self {
        case .click:
            return "Classic sine wave click"
        case .snap:
            return "Sharp finger snap sound"
        case .beep:
            return "Digital beep tone"
        case .blip:
            return "Short electronic blip"
        }
    }
}

// MARK: - UserDefaults Keys
private enum UserDefaultsKeys {
    static let bpm = "metronome_bpm"
    static let beatsPerBar = "metronome_beatsPerBar"
    static let beatUnit = "metronome_beatUnit"
    static let selectedSoundType = "metronome_selectedSoundType"
    static let subdivisionMultiplier = "metronome_subdivisionMultiplier"
    static let accentFirstBeat = "metronome_accentFirstBeat"
    static let emphasizeFirstBeatOnly = "metronome_emphasizeFirstBeatOnly"
    static let fullScreenFlashOnFirstBeat = "metronome_fullScreenFlashOnFirstBeat"
    static let clickVolume = "metronome_clickVolume"
    static let backgroundAudioEnabled = "metronome_backgroundAudioEnabled"
    static let pauseOnInterruption = "metronome_pauseOnInterruption"
    static let pauseOnRouteChange = "metronome_pauseOnRouteChange"
    static let keepScreenAwake = "metronome_keepScreenAwake"
}

// MARK: - Metronome Engine with Enhanced Audio Session Handling

class MetronomeEngine: ObservableObject {
    
    // MARK: - Persistent Settings using @AppStorage approach
    @AppStorage("metronome_accentFirstBeat") var accentFirstBeat: Bool = false {
        didSet { saveSettings() }
    }
    
    @AppStorage("metronome_emphasizeFirstBeatOnly") var emphasizeFirstBeatOnly: Bool = false {
        didSet { saveSettings() }
    }
    
    @AppStorage("metronome_fullScreenFlashOnFirstBeat") var fullScreenFlashOnFirstBeat: Bool = false {
        didSet { saveSettings() }
    }
    
    // MARK: - New Audio Session Settings
    @AppStorage("metronome_backgroundAudioEnabled") var backgroundAudioEnabled: Bool = true {
        didSet {
            saveSettings()
            updateAudioSessionConfiguration()
        }
    }
    
    @AppStorage("metronome_pauseOnInterruption") var pauseOnInterruption: Bool = true {
        didSet { saveSettings() }
    }
    
    @AppStorage("metronome_pauseOnRouteChange") var pauseOnRouteChange: Bool = true {
        didSet { saveSettings() }
    }
    
    @AppStorage("metronome_keepScreenAwake") var keepScreenAwake: Bool = true {
        didSet {
            saveSettings()
            updateScreenIdleTimer()
        }
    }
    
    @Published var isFlashing: Bool = false
    
    @Published var bpm: Int = 120 {
        didSet {
            updateTiming()
            saveSettings()
        }
    }
    
    @Published var isPlaying: Bool = false {
        didSet {
            if isPlaying {
                startMetronome()
            } else {
                stopMetronome()
            }
            updateScreenIdleTimer()
        }
    }
    
    @Published var beatsPerBar: Int = 4 {
        didSet {
            resetBeatPosition()
            saveSettings()
        }
    }
    
    // ADD: Support for beat unit (denominator)
    @Published var beatUnit: Int = 4 {
        didSet {
            resetBeatPosition()
            saveSettings()
        }
    }
    
    // ADD: Computed property for beatsPerMeasure (alias for beatsPerBar for compatibility)
    var beatsPerMeasure: Int {
        get { beatsPerBar }
        set { beatsPerBar = newValue }
    }
    
    @Published var currentBeat: Int = 0
    @Published var beatIndicator: Bool = false
    
    // ADD: Sound selection property
    @Published var selectedSoundType: SyntheticSound = .click {
        didSet { saveSettings() }
    }
    
    // Settings
    @Published var clickVolume: Double = 0.5 {
        didSet {
            mixerNode.outputVolume = Float(clickVolume)
            saveSettings()
        }
    }
    
    // MARK: - Audio Session State Tracking
    @Published var audioSessionInterrupted: Bool = false
    @Published var headphonesConnected: Bool = false
    private var wasPlayingBeforeInterruption: Bool = false
    private var wasPlayingBeforeBackground: Bool = false
    
    // Tap tempo functionality
    private var tapTimes: [Date] = []
    private let maxTapCount = 8
    private let tapTimeoutInterval: TimeInterval = 3.0
    
    // Subdivisions
    @Published var subdivision: Int = 1 {
        didSet {
            updateTiming()
            saveSettings()
        }
    }
    
    // ADD: Subdivision multiplier support
    var subdivisionMultiplier: Double {
        get { Double(subdivision) }
        set {
            subdivision = Int(newValue)
        }
    }
    
    // Audio components
    private let audioEngine = AVAudioEngine()
    private var sourceNode: AVAudioSourceNode?
    private let mixerNode = AVAudioMixerNode()
    
    // Preview audio components - separate from main metronome
    private var previewEngine: AVAudioEngine?
    private var previewPlayerNode: AVAudioPlayerNode?
    
    // MARK: - Dial Tick Audio Components
    private var lastDialBPM: Int = 0
    private var dialTickEngine: AVAudioEngine?
    private var dialTickPlayerNode: AVAudioPlayerNode?
    
    private var lastPreviewTime: Date = .distantPast
    private let minimumPreviewInterval: TimeInterval = 0.3
    
    // Timing variables (accessed atomically from audio thread)
    private var sampleRate: Double = 44100.0
    private var samplesPerBeat: Double = 0
    private var currentSamplePosition: Int64 = 0
    private var nextBeatSample: Int64 = 0
    private var beatCounter: Int = 0
    private var lastBeatSample: Int64 = 0
    
    // Click generation
    private var clickPhase: Float = 0.0
    private let clickFrequency: Float = 1000.0
    private let accentFrequency: Float = 1200.0
    private let clickDuration: Double = 0.1
    
    // Snap waveform playback state
    private var snapPlaybackPosition: Double = 0.0
    private var isPlayingSnap: Bool = false
    private let snapOriginalSampleRate: Double = 24000.0
    
    // Debug flag
    private var debugMode = false
    
    init() {
        loadSettings()
        setupAudioSession()
        setupAudioSessionNotifications()
        setupAppLifecycleNotifications()
        setupAudioEngine()
        updateTiming()
        checkHeadphonesConnected()
        updateScreenIdleTimer()
        
        // Initialize dial tick tracking
        lastDialBPM = bpm
    }
    
    deinit {
        stopMetronome()
        cleanupPreviewEngine()
        cleanupDialTickEngine() // NEW: Clean up dial tick engine
        removeAudioSessionNotifications()
        removeAppLifecycleNotifications()
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    // MARK: - Enhanced Audio Session Setup
    
    private func setupAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            // Configure category based on background audio setting
            if backgroundAudioEnabled {
                try audioSession.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            } else {
                try audioSession.setCategory(.playback, mode: .default, options: [])
            }
            
            try audioSession.setPreferredIOBufferDuration(0.005)
            try audioSession.setPreferredSampleRate(48000.0)
            try audioSession.setActive(true)
            
            sampleRate = audioSession.sampleRate
            if debugMode {
                print("✅ Audio session sample rate: \(sampleRate)")
                print("✅ Background audio enabled: \(backgroundAudioEnabled)")
            }
            
        } catch {
            print("❌ Audio session setup failed: \(error)")
        }
    }
    
    private func updateAudioSessionConfiguration() {
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            if backgroundAudioEnabled {
                try audioSession.setCategory(.playback, mode: .default, options: [.mixWithOthers])
                try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            } else {
                // When background audio is disabled, ensure audio stops in background
                try audioSession.setCategory(.playback, mode: .default, options: [])
                if UIApplication.shared.applicationState != .active {
                    try audioSession.setActive(false, options: .notifyOthersOnDeactivation)
                    stopMetronome()
                } else {
                    try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
                }
            }
            
            if debugMode {
                print("✅ Audio session configuration updated - Background: \(backgroundAudioEnabled)")
            }
        } catch {
            print("❌ Failed to update audio session configuration: \(error)")
        }
    }
    
    // MARK: - App Lifecycle Notifications
    
    private func setupAppLifecycleNotifications() {
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(
            self,
            selector: #selector(handleAppDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        
        notificationCenter.addObserver(
            self,
            selector: #selector(handleAppWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
        
        if debugMode {
            print("✅ App lifecycle notifications setup complete")
        }
    }
    
    private func removeAppLifecycleNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc private func handleAppDidEnterBackground() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if !self.backgroundAudioEnabled {
                self.wasPlayingBeforeBackground = self.isPlaying
                self.isPlaying = false
                do {
                    try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
                    if self.debugMode {
                        print("🛑 Audio session deactivated due to backgrounding with background audio disabled")
                    }
                } catch {
                    print("❌ Failed to deactivate audio session on background: \(error)")
                }
            }
            
            UIApplication.shared.isIdleTimerDisabled = false
            
            if self.debugMode {
                print("📴 App entered background, backgroundAudioEnabled: \(self.backgroundAudioEnabled)")
            }
        }
    }
    
    @objc private func handleAppWillEnterForeground() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if self.wasPlayingBeforeBackground && !self.backgroundAudioEnabled {
                do {
                    try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
                    self.isPlaying = true
                    if self.debugMode {
                        print("▶️ Audio session reactivated and playback resumed on foreground")
                    }
                } catch {
                    print("❌ Failed to reactivate audio session on foreground: \(error)")
                }
            }
            
            self.updateScreenIdleTimer()
            
            if self.debugMode {
                print("📱 App entering foreground, backgroundAudioEnabled: \(self.backgroundAudioEnabled)")
            }
        }
    }
    
    // MARK: - Audio Session Notifications
    
    private func setupAudioSessionNotifications() {
        let notificationCenter = NotificationCenter.default
        
        // Interruption handling
        notificationCenter.addObserver(
            self,
            selector: #selector(handleAudioSessionInterruption(_:)),
            name: AVAudioSession.interruptionNotification,
            object: AVAudioSession.sharedInstance()
        )
        
        // Route change handling
        notificationCenter.addObserver(
            self,
            selector: #selector(handleAudioSessionRouteChange(_:)),
            name: AVAudioSession.routeChangeNotification,
            object: AVAudioSession.sharedInstance()
        )
        
        // Media services reset handling
        notificationCenter.addObserver(
            self,
            selector: #selector(handleMediaServicesReset),
            name: AVAudioSession.mediaServicesWereResetNotification,
            object: AVAudioSession.sharedInstance()
        )
        
        if debugMode {
            print("✅ Audio session notifications setup complete")
        }
    }
    
    private func removeAudioSessionNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func handleAudioSessionInterruption(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            switch type {
            case .began:
                if debugMode {
                    print("🔇 Audio interruption began")
                }
                
                self.audioSessionInterrupted = true
                
                if self.isPlaying {
                    self.wasPlayingBeforeInterruption = true
                    if self.pauseOnInterruption {
                        self.isPlaying = false
                    }
                }
                
            case .ended:
                if debugMode {
                    print("🔊 Audio interruption ended")
                }
                
                self.audioSessionInterrupted = false
                
                // Check if we should resume
                if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                    let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                    if options.contains(.shouldResume) && self.wasPlayingBeforeInterruption && !self.pauseOnInterruption {
                        // Reactivate audio session and resume
                        do {
                            try AVAudioSession.sharedInstance().setActive(true)
                            self.isPlaying = true
                        } catch {
                            print("❌ Failed to reactivate audio session: \(error)")
                        }
                    }
                }
                
                self.wasPlayingBeforeInterruption = false
                
            @unknown default:
                if debugMode {
                    print("⚠️ Unknown interruption type")
                }
            }
        }
    }
    
    @objc private func handleAudioSessionRouteChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else {
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            switch reason {
            case .newDeviceAvailable:
                if debugMode {
                    print("🎧 New audio device connected")
                }
                self.checkHeadphonesConnected()
                
            case .oldDeviceUnavailable:
                if debugMode {
                    print("🎧 Audio device disconnected")
                }
                self.checkHeadphonesConnected()
                
                // Pause if configured to do so and headphones were disconnected
                if let previousRoute = userInfo[AVAudioSessionRouteChangePreviousRouteKey] as? AVAudioSessionRouteDescription {
                    let wasUsingHeadphones = previousRoute.outputs.contains { output in
                        [.headphones, .bluetoothA2DP, .bluetoothHFP, .bluetoothLE].contains(output.portType)
                    }
                    
                    if wasUsingHeadphones && self.pauseOnRouteChange && self.isPlaying {
                        self.isPlaying = false
                        if debugMode {
                            print("⏸️ Paused due to headphone disconnection")
                        }
                    }
                }
                
            case .categoryChange, .override, .wakeFromSleep, .noSuitableRouteForCategory, .routeConfigurationChange:
                if debugMode {
                    print("🔄 Audio route changed: \(reason)")
                }
                self.checkHeadphonesConnected()
                
            case .unknown:
                if debugMode {
                    print("⚠️ Route change reason: .unknown")
                }
                
            @unknown default:
                if debugMode {
                    print("⚠️ Unknown route change reason: \(reason)")
                }
            }
        }
    }
    
    @objc private func handleMediaServicesReset() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if debugMode {
                print("🔄 Media services reset - reinitializing audio")
            }
            
            // Stop current playback
            let wasPlaying = self.isPlaying
            self.isPlaying = false
            
            // Reinitialize audio session and engine
            self.setupAudioSession()
            self.setupAudioEngine()
            
            // Resume if was playing
            if wasPlaying && !self.pauseOnInterruption {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.isPlaying = true
                }
            }
        }
    }
    
    private func checkHeadphonesConnected() {
        let currentRoute = AVAudioSession.sharedInstance().currentRoute
        let wasConnected = headphonesConnected
        
        headphonesConnected = currentRoute.outputs.contains { output in
            [.headphones, .bluetoothA2DP, .bluetoothHFP, .bluetoothLE].contains(output.portType)
        }
        
        if debugMode && wasConnected != headphonesConnected {
            print("🎧 Headphones connected status changed: \(headphonesConnected)")
        }
    }
    
    // MARK: - Persistent Storage Methods
    
    private func loadSettings() {
        let defaults = UserDefaults.standard
        
        // Load BPM (with bounds checking)
        let savedBPM = defaults.integer(forKey: UserDefaultsKeys.bpm)
        if savedBPM > 0 {
            bpm = max(40, min(400, savedBPM))
        }
        
        // Load beats per bar
        let savedBeatsPerBar = defaults.integer(forKey: UserDefaultsKeys.beatsPerBar)
        if savedBeatsPerBar > 0 {
            beatsPerBar = savedBeatsPerBar
        }
        
        // Load beat unit
        let savedBeatUnit = defaults.integer(forKey: UserDefaultsKeys.beatUnit)
        if savedBeatUnit > 0 {
            beatUnit = savedBeatUnit
        }
        
        // Load sound type
        if let savedSoundTypeRawValue = defaults.string(forKey: UserDefaultsKeys.selectedSoundType),
           let savedSoundType = SyntheticSound(rawValue: savedSoundTypeRawValue) {
            selectedSoundType = savedSoundType
        }
        
        // Load subdivision multiplier
        let savedSubdivision = defaults.double(forKey: UserDefaultsKeys.subdivisionMultiplier)
        if savedSubdivision > 0 {
            subdivision = Int(savedSubdivision)
        }
        
        // Load volume
        if defaults.object(forKey: UserDefaultsKeys.clickVolume) != nil {
            clickVolume = defaults.double(forKey: UserDefaultsKeys.clickVolume)
        }
        
        if debugMode {
            print("✅ Settings loaded from UserDefaults")
            print("   BPM: \(bpm)")
            print("   Time Signature: \(beatsPerBar)/\(beatUnit)")
            print("   Sound: \(selectedSoundType.rawValue)")
            print("   Subdivision: \(subdivision)")
            print("   Accent First Beat: \(accentFirstBeat)")
            print("   Emphasize First Beat Only: \(emphasizeFirstBeatOnly)")
            print("   Full Screen Flash: \(fullScreenFlashOnFirstBeat)")
            print("   Volume: \(clickVolume)")
            print("   Background Audio: \(backgroundAudioEnabled)")
            print("   Pause on Interruption: \(pauseOnInterruption)")
            print("   Pause on Route Change: \(pauseOnRouteChange)")
            print("   Keep Screen Awake: \(keepScreenAwake)")
        }
    }
    
    private func saveSettings() {
        let defaults = UserDefaults.standard
        
        defaults.set(bpm, forKey: UserDefaultsKeys.bpm)
        defaults.set(beatsPerBar, forKey: UserDefaultsKeys.beatsPerBar)
        defaults.set(beatUnit, forKey: UserDefaultsKeys.beatUnit)
        defaults.set(selectedSoundType.rawValue, forKey: UserDefaultsKeys.selectedSoundType)
        defaults.set(Double(subdivision), forKey: UserDefaultsKeys.subdivisionMultiplier)
        defaults.set(clickVolume, forKey: UserDefaultsKeys.clickVolume)
        
        if debugMode {
            print("💾 Settings saved to UserDefaults")
        }
    }
    
    // ADD: Method to update time signature
    func updateTimeSignature(numerator: Int, denominator: Int) {
        beatsPerMeasure = numerator
        beatUnit = denominator
        if debugMode {
            print("🎵 Time signature updated to \(numerator)/\(denominator)")
        }
    }
    
    // ADD: Method to update subdivision
    func updateSubdivision(to multiplier: Double) {
        subdivisionMultiplier = multiplier
        if debugMode {
            print("🎵 Subdivision updated to \(multiplier)")
        }
    }
    
    // ADD: Method to update sound type
    func updateSoundType(to soundType: SyntheticSound) {
        selectedSoundType = soundType
        if debugMode {
            print("🔊 Sound updated to: \(soundType.rawValue)")
        }
    }


    // MARK: - NEW: Fixed Dial Tick Sound Methods with Overlap Support

    // Add these properties to store multiple dial tick engines
    private var dialTickEngines: [AVAudioEngine] = []
    private var dialTickPlayers: [AVAudioPlayerNode] = []
    private let maxConcurrentDialTicks = 3 // Limit concurrent sounds to avoid audio overload

    func handleBPMChangeForDialTick(newBPM: Int) {
        // Only play tick if BPM actually changed (not on initial load)
        if lastDialBPM != 0 && lastDialBPM != newBPM {
            playDialTick()
        }
        lastDialBPM = newBPM
    }

    private func playDialTick() {
        cleanupOldDialTickEngines()

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }

            // Create a new engine for this tick (don't reuse)
            let engine = AVAudioEngine()
            let playerNode = AVAudioPlayerNode()
            self.dialTickEngines.append(engine)
            self.dialTickPlayers.append(playerNode)

            do {
                engine.attach(playerNode)

                let outputFormat = engine.outputNode.outputFormat(forBus: 0)
                let format = AVAudioFormat(
                    commonFormat: .pcmFormatFloat32,
                    sampleRate: outputFormat.sampleRate,
                    channels: 1,
                    interleaved: false
                )!

                engine.connect(playerNode, to: engine.outputNode, format: format)

                let tickDuration: Double = 0.012 // ~12ms
                let frameCount = UInt32(format.sampleRate * tickDuration)

                guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
                    self.removeEngineAndPlayer(engine: engine, player: playerNode)
                    return
                }

                buffer.frameLength = frameCount
                let channelData = buffer.floatChannelData![0]

                let attackTime: Float = 0.001
                let decayTime = Float(tickDuration) - attackTime
                let sampleRate = Float(format.sampleRate)

                for frame in 0..<Int(frameCount) {
                    let time = Float(frame) / sampleRate
                    let envelope: Float

                    if time < attackTime {
                        envelope = time / attackTime
                    } else {
                        let decayProgress = (time - attackTime) / decayTime
                        envelope = exp(-decayProgress * 30.0)
                    }

                    // Create a short triangle wave (gives a sharper, slightly woody character)
                    let triangleFreq: Float = 1300.0
                    let phase = triangleFreq * time
                    let triangle = 2.0 * abs(2.0 * (phase - floor(phase + 0.5))) - 1.0

                    // Add gently filtered noise — less random, more natural
                    let noiseSeed = sin(2 * .pi * 7500.0 * time) // smoother than random
                    let softNoise = noiseSeed * (Float.random(in: 0.8...1.0)) * 0.7

                    let sample = (triangle * 0.6 + softNoise * 0.4) * envelope * 0.5
                    channelData[frame] = sample
                }


                try engine.start()

                weak var weakEngine = engine
                weak var weakPlayer = playerNode

                playerNode.scheduleBuffer(buffer) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        self.cleanupSpecificDialTickEngine(engine: weakEngine, player: weakPlayer)
                    }
                }

                playerNode.play()

            } catch {
                print("❌ Failed to play dial tick: \(error)")
                self.removeEngineAndPlayer(engine: engine, player: playerNode)
            }
        }
    }

    private func cleanupOldDialTickEngines() {
        while dialTickEngines.count >= maxConcurrentDialTicks {
            if let oldestEngine = dialTickEngines.first,
               let oldestPlayer = dialTickPlayers.first {
                oldestPlayer.stop()
                oldestEngine.stop()
                dialTickEngines.removeFirst()
                dialTickPlayers.removeFirst()
            }
        }
    }

    private func cleanupSpecificDialTickEngine(engine: AVAudioEngine?, player: AVAudioPlayerNode?) {
        guard let engine = engine, let player = player else { return }

        player.stop()
        engine.stop()

        if let engineIndex = dialTickEngines.firstIndex(of: engine) {
            dialTickEngines.remove(at: engineIndex)
        }
        if let playerIndex = dialTickPlayers.firstIndex(of: player) {
            dialTickPlayers.remove(at: playerIndex)
        }
    }

    private func cleanupDialTickEngine() {
        for player in dialTickPlayers {
            player.stop()
        }
        for engine in dialTickEngines {
            engine.stop()
        }

        dialTickEngines.removeAll()
        dialTickPlayers.removeAll()

        dialTickPlayerNode = nil
        dialTickEngine = nil
    }

    // Helper to avoid duplication on cleanup
    private func removeEngineAndPlayer(engine: AVAudioEngine, player: AVAudioPlayerNode) {
        if let engineIndex = dialTickEngines.firstIndex(of: engine) {
            dialTickEngines.remove(at: engineIndex)
        }
        if let playerIndex = dialTickPlayers.firstIndex(of: player) {
            dialTickPlayers.remove(at: playerIndex)
        }
    }

    
    
    // MARK: - Alternative Haptic Feedback Method
    func playDialTickHaptic() {
        DispatchQueue.main.async {
            // To this (since your deployment target is iOS 13.0 or higher):
            let impact = UIImpactFeedbackGenerator(style: .rigid)
            impact.prepare()
            impact.impactOccurred(intensity: 0.7)
        }
    }
    
    private func setupAudioEngine() {
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        
        sourceNode = AVAudioSourceNode(format: format) { [weak self] _, _, frameCount, audioBufferList -> OSStatus in
            return self?.renderAudio(frameCount: frameCount, audioBufferList: audioBufferList) ?? noErr
        }
        
        guard let sourceNode = sourceNode else {
            print("❌ Failed to create source node")
            return
        }
        
        audioEngine.attach(sourceNode)
        audioEngine.attach(mixerNode)
        
        audioEngine.connect(sourceNode, to: mixerNode, format: format)
        audioEngine.connect(mixerNode, to: audioEngine.outputNode, format: format)
        
        mixerNode.outputVolume = Float(clickVolume)
        
        if debugMode {
            print("✅ Audio engine setup complete")
        }
    }
    
    private func updateTiming() {
        samplesPerBeat = sampleRate * 60.0 / Double(bpm) / Double(subdivision)
        if debugMode {
            print("⏱️ Updated timing: \(bpm) BPM, subdivision: \(subdivision) = \(samplesPerBeat) samples per beat")
        }
    }
    
    private func resetBeatPosition() {
        currentBeat = 0
        beatCounter = 0
        if debugMode {
            print("🔄 Beat position reset")
        }
    }
    
    private func startMetronome() {
        guard !audioEngine.isRunning else {
            if debugMode {
                print("⚠️ Audio engine already running")
            }
            return
        }

        do {
            // Ensure audio session is active
            try AVAudioSession.sharedInstance().setActive(true)

            // Reset timing and audio state for immediate first beat
            currentSamplePosition = 0
            lastBeatSample = 0 // First beat starts at sample 0
            nextBeatSample = Int64(samplesPerBeat) // Second beat scheduled normally
            beatCounter = 1 // Starting on beat 1
            currentBeat = 1 // Display beat 1
            clickPhase = 0.0
            snapPlaybackPosition = 0.0
            isPlayingSnap = false

            // Initialize snap playback for first beat if needed
            if selectedSoundType == .snap {
                snapPlaybackPosition = 0.0
                isPlayingSnap = true
            }

            // Update UI for first beat
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.currentBeat = 1
                self.beatIndicator.toggle()
                
                if self.fullScreenFlashOnFirstBeat {
                    self.triggerFlash()
                }
            }

            try audioEngine.start()

            if debugMode {
                print("🎵 Metronome started at \(bpm) BPM on beat 1")
                print("🎵 Engine running: \(audioEngine.isRunning)")
                print("🎵 Output node: \(audioEngine.outputNode)")
            }

        } catch {
            print("❌ Failed to start audio engine: \(error)")
            DispatchQueue.main.async { [weak self] in
                self?.isPlaying = false
            }
        }
    }
    
    private func stopMetronome() {
        guard audioEngine.isRunning else {
            if debugMode {
                print("⚠️ Audio engine not running")
            }
            return
        }
        
        audioEngine.stop()
        
        DispatchQueue.main.async { [weak self] in
            self?.beatIndicator = false
            self?.currentBeat = 0
        }
        
        if debugMode {
            print("🛑 Metronome stopped")
        }
    }
    
    // MARK: - Updated Real-Time Audio Render Callback with Flash Trigger
    private func renderAudio(frameCount: UInt32, audioBufferList: UnsafeMutablePointer<AudioBufferList>) -> OSStatus {
        
        let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)
        guard let buffer = ablPointer[0].mData?.assumingMemoryBound(to: Float.self) else {
            return kAudioUnitErr_InvalidParameter
        }
        
        let frames = Int(frameCount)
        let clickDurationSamples = Int(clickDuration * sampleRate)
        
        var beatTriggeredInThisCycle = false
        var newBeatNumber = currentBeat
        
        for frameIndex in 0..<frames {
            let currentSample = currentSamplePosition + Int64(frameIndex)
            var sample: Float = 0.0
            
            // Check if we need to trigger a new beat
            if currentSample >= nextBeatSample && !beatTriggeredInThisCycle {
                lastBeatSample = nextBeatSample
                nextBeatSample += Int64(samplesPerBeat)
                beatCounter += 1
                
                newBeatNumber = ((beatCounter - 1) % beatsPerBar) + 1
                
                beatTriggeredInThisCycle = true
                clickPhase = 0.0
                
                // Start snap playback if snap sound is selected
                if selectedSoundType == .snap {
                    snapPlaybackPosition = 0.0
                    isPlayingSnap = true
                }
            }
            
            let samplesSinceLastBeat = currentSample - lastBeatSample
            
            // Generate audio based on selected sound type
            if selectedSoundType == .snap {
                // Use pre-generated snap waveform with sample rate conversion
                if isPlayingSnap && snapPlaybackPosition < Double(snapWaveform.count) {
                    // Calculate the correct index with sample rate conversion and optional pitch shift
                    let baseSampleRateRatio = snapOriginalSampleRate / sampleRate
                    
                    // Apply pitch shift for accent (higher pitch = faster playback)
                    let pitchShiftRatio: Double = (accentFirstBeat && newBeatNumber == 1) ? 1.15 : 1.0
                    let adjustedRatio = baseSampleRateRatio * pitchShiftRatio
                    
                    let adjustedPosition = snapPlaybackPosition * adjustedRatio
                    let index = Int(adjustedPosition)
                    
                    if index < snapWaveform.count {
                        let baseAmplitude: Float = 0.8
                        // Slight volume boost for accented beats too
                        let accentMultiplier: Float = (accentFirstBeat && newBeatNumber == 1) ? 1.1 : 1.0
                        sample = snapWaveform[index] * baseAmplitude * accentMultiplier
                    }
                    
                    // Advance playback position at the engine's sample rate
                    snapPlaybackPosition += 1.0
                    
                    // Check if we've reached the end (accounting for sample rate conversion and pitch shift)
                    if adjustedPosition >= Double(snapWaveform.count - 1) {
                        isPlayingSnap = false
                    }
                }
            } else {
                // Use synthetic sound generation for other sounds
                if samplesSinceLastBeat >= 0 && samplesSinceLastBeat < clickDurationSamples {
                    let clickProgress = Float(samplesSinceLastBeat) / Float(clickDurationSamples)
                    
                    // Generate envelope based on sound type
                    let envelope = generateEnvelope(for: selectedSoundType, progress: clickProgress)
                    
                    // Generate frequency based on sound type and accent
                    let frequency = generateFrequency(for: selectedSoundType,
                                                      isAccent: accentFirstBeat && newBeatNumber == 1,
                                                      progress: clickProgress)
                    
                    // Generate the sample
                    sample = generateSample(for: selectedSoundType,
                                            frequency: frequency,
                                            envelope: envelope,
                                            progress: clickProgress)
                    
                    clickPhase += 2.0 * Float.pi * frequency / Float(sampleRate)
                    
                    if clickPhase >= 2.0 * Float.pi {
                        clickPhase -= 2.0 * Float.pi
                    }
                }
            }
            
            buffer[frameIndex] = sample
        }
        
        currentSamplePosition += Int64(frames)
        
        // Handle beat triggering and visual effects
        if beatTriggeredInThisCycle {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.currentBeat = newBeatNumber
                self.beatIndicator.toggle()
                
                // Trigger flash on first beat if enabled
                if newBeatNumber == 1 && self.fullScreenFlashOnFirstBeat {
                    self.triggerFlash()
                }
            }
        }
        
        return noErr
    }

    // MARK: - Flash Trigger Method
    func triggerFlash() {
        guard fullScreenFlashOnFirstBeat else { return }
        isFlashing = true
        
        // Calculate the duration of one beat in seconds
        let beatDurationInSeconds = 60.0 / Double(bpm)
        
        // Flash duration should last the entire beat
        DispatchQueue.main.asyncAfter(deadline: .now() + beatDurationInSeconds) { [weak self] in
            self?.isFlashing = false
        }
    }
    
    private func updateScreenIdleTimer() {
        DispatchQueue.main.async {
            // Keep screen awake when playing AND the setting is enabled
            UIApplication.shared.isIdleTimerDisabled = self.isPlaying && self.keepScreenAwake
            
            if self.debugMode {
                let status = UIApplication.shared.isIdleTimerDisabled ? "DISABLED" : "ENABLED"
                print("📱 Screen idle timer: \(status) (playing: \(self.isPlaying), keepAwake: \(self.keepScreenAwake))")
            }
        }
    }

    
    // MARK: - Sound Generation Helpers
    
    private func generateEnvelope(for soundType: SyntheticSound, progress: Float) -> Float {
        let baseAmplitude: Float = 0.3
        
        switch soundType {
        case .click, .beep:
            return (1.0 - progress) * baseAmplitude
            
        case .snap:
            // This won't be used since snap uses the waveform, but kept for completeness
            if progress < 0.02 {
                return baseAmplitude * 1.8
            } else {
                return exp(-progress * 15.0) * baseAmplitude * 1.8
            }
               
        case .blip:
            // Sharp attack, quick decay
            return exp(-progress * 25.0) * (1.0 - progress) * baseAmplitude * 1.3
        }
    }
    
    private func generateFrequency(for soundType: SyntheticSound, isAccent: Bool, progress: Float) -> Float {
        let accentMultiplier: Float = isAccent ? 1.2 : 1.0
        
        switch soundType {
        case .click:
            return (isAccent ? accentFrequency : clickFrequency) * accentMultiplier
            
        case .snap:
            // This won't be used since snap uses the waveform, but kept for completeness
            let primaryFreq: Float = 800.0
            let sweep = primaryFreq * (1.0 + (1.0 - progress) * 0.2)
            return sweep * accentMultiplier
            
        case .beep:
            return 800.0 * accentMultiplier
            
        case .blip:
            return 2400.0 * accentMultiplier
        }
    }
    
    private func generateSample(for soundType: SyntheticSound, frequency: Float, envelope: Float, progress: Float) -> Float {
        let fundamental = sin(clickPhase) * envelope
        
        switch soundType {
        case .click, .beep, .blip:
            return fundamental
            
        case .snap:
            // This won't be used since snap uses the waveform, but kept for completeness
            let primary = sin(clickPhase) * envelope
            let harmonic = sin(clickPhase * 2.5) * 0.4 * envelope
            let highHarmonic = sin(clickPhase * 6.0 + 0.01) * 0.2 * envelope
            let fingerRes = sin(clickPhase * 0.3 - 0.02) * 0.5 * envelope
            let crackIntensity = progress < 0.03 ? (1.0 - progress * 33.0) : 0.0
            let crack = Float.random(in: -0.2...0.2) * envelope * crackIntensity * 0.3
            let crackle = progress < 0.05 ? Float.random(in: -1...1) * envelope * 0.6 : 0.0
            return primary + harmonic + highHarmonic + fingerRes + crack + crackle
        }
    }
    
    // MARK: - Tap Tempo
    func tapTempo() {
        let now = Date()
        
        tapTimes.removeAll { now.timeIntervalSince($0) > tapTimeoutInterval }
        tapTimes.append(now)
        
        guard tapTimes.count >= 2 else { return }
        
        if tapTimes.count > maxTapCount {
            tapTimes.removeFirst()
        }
        
        var totalInterval: TimeInterval = 0
        for i in 1..<tapTimes.count {
            totalInterval += tapTimes[i].timeIntervalSince(tapTimes[i-1])
        }
        
        let averageInterval = totalInterval / Double(tapTimes.count - 1)
        let calculatedBPM = 60.0 / averageInterval
        
        let clampedBPM = max(40, min(400, Int(calculatedBPM.rounded())))
        
        bpm = clampedBPM
        
        if debugMode {
            print("👆 Tap tempo: \(tapTimes.count) taps, avg interval: \(averageInterval)s, BPM: \(clampedBPM)")
        }
    }
    
    // MARK: - Subdivision Helper
    func subdivisionLabel() -> String {
        switch subdivision {
        case 1:
            return "♩"
        case 2:
            return "♫"
        case 4:
            return "♬"
        case 3:
            return "♩."
        default:
            return "♩"
        }
    }
    
    // MARK: - Debug Helper
    func toggleDebugMode() {
        debugMode.toggle()
        print("🐛 Debug mode: \(debugMode ? "ON" : "OFF")")
    }
    
    // MARK: - Safe Sound Preview Method
    func playSoundPreview(_ soundType: SyntheticSound? = nil) {
        let previewSoundType = soundType ?? selectedSoundType
        
        // Clean up any existing preview engine
        cleanupPreviewEngine()
        
        // Use a simple haptic feedback instead of audio preview to avoid crashes
        DispatchQueue.main.async {
            if #available(iOS 10.0, *) {
                let impact = UIImpactFeedbackGenerator(style: .light)
                impact.prepare()
                impact.impactOccurred()
            }
        }
        
        if debugMode {
            print("🔊 Sound preview: \(previewSoundType.rawValue)")
        }
    }
    
    func playSoundPreviewAdvanced(_ soundType: SyntheticSound? = nil) {
        let previewSoundType = soundType ?? selectedSoundType
        
        // Clean up any existing preview engine first
        cleanupPreviewEngine()
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            do {
                // Create a fresh engine for preview
                let engine = AVAudioEngine()
                let playerNode = AVAudioPlayerNode()
                
                // Store references
                self.previewEngine = engine
                self.previewPlayerNode = playerNode
                
                // Setup engine
                engine.attach(playerNode)
                
                let outputFormat = engine.outputNode.outputFormat(forBus: 0)
                let format = AVAudioFormat(
                    commonFormat: .pcmFormatFloat32,
                    sampleRate: outputFormat.sampleRate,
                    channels: 1,
                    interleaved: false
                )!
                
                engine.connect(playerNode, to: engine.outputNode, format: format)
                
                // Generate preview buffer with improved parameters
                let previewDuration: Double = 0.25 // Longer duration for better audibility
                let frameCount = UInt32(format.sampleRate * previewDuration)
                
                guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
                    DispatchQueue.main.async {
                        if #available(iOS 10.0, *) {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        }
                    }
                    return
                }
                
                buffer.frameLength = frameCount
                let channelData = buffer.floatChannelData![0]
                
                // Generate sound data based on type
                if previewSoundType == .snap {
                    // Use snap waveform with proper sample rate handling
                    let sampleRateRatio = snapOriginalSampleRate / format.sampleRate
                    
                    for i in 0..<Int(frameCount) {
                        let adjustedPosition = Double(i) * sampleRateRatio
                        let index = Int(adjustedPosition)
                        
                        if index < snapWaveform.count {
                            channelData[i] = snapWaveform[index] * 0.8 // Higher volume for preview
                        } else {
                            channelData[i] = 0.0
                        }
                    }
                } else {
                    // Generate synthetic sounds with improved parameters
                    var phase: Float = 0.0
                    let sampleRate = Float(format.sampleRate)
                    let clickDuration = 0.15 // Longer click duration
                    let clickDurationSamples = Int(clickDuration * Double(sampleRate))
                    
                    for frame in 0..<Int(frameCount) {
                        var sample: Float = 0.0
                        
                        // Generate sound for the initial portion
                        if frame < clickDurationSamples {
                            let progress = Float(frame) / Float(clickDurationSamples)
                            
                            // Generate envelope and frequency based on sound type
                            let envelope = self.generatePreviewEnvelope(for: previewSoundType, progress: progress)
                            let frequency = self.generatePreviewFrequency(for: previewSoundType, progress: progress)
                            
                            // Generate the sample
                            sample = self.generatePreviewSample(for: previewSoundType, frequency: frequency, envelope: envelope, progress: progress, phase: &phase, sampleRate: sampleRate)
                        }
                        
                        channelData[frame] = sample * 0.7 // Adjust volume for preview
                    }
                }
                
                // Start engine and schedule buffer
                try engine.start()
                
                playerNode.scheduleBuffer(buffer) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self.cleanupPreviewEngine()
                    }
                }
                
                playerNode.play()
                
                // Add haptic feedback
                DispatchQueue.main.async {
                    if #available(iOS 10.0, *) {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }
                }
                
            } catch {
                print("❌ Failed to play sound preview: \(error)")
                DispatchQueue.main.async {
                    if #available(iOS 10.0, *) {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }
                }
                self.cleanupPreviewEngine()
            }
        }
    }

    // MARK: - Preview-specific sound generation methods

    private func generatePreviewEnvelope(for soundType: SyntheticSound, progress: Float) -> Float {
        let baseAmplitude: Float = 0.6 // Higher base amplitude for preview
        
        switch soundType {
        case .click, .beep:
            // Exponential decay with longer sustain
            return exp(-progress * 8.0) * baseAmplitude
            
        case .snap:
            // This won't be used since snap uses the waveform
            if progress < 0.02 {
                return baseAmplitude * 2.0
            } else {
                return exp(-progress * 12.0) * baseAmplitude * 1.5
            }
               
        case .blip:
            // Sharp attack, quick decay but more sustained
            return exp(-progress * 15.0) * (1.0 - progress * 0.5) * baseAmplitude * 1.2
        }
    }

    private func generatePreviewFrequency(for soundType: SyntheticSound, progress: Float) -> Float {
        switch soundType {
        case .click:
            return 1200.0 // Slightly higher for better audibility
            
        case .snap:
            // This won't be used since snap uses the waveform
            let primaryFreq: Float = 900.0
            let sweep = primaryFreq * (1.0 + (1.0 - progress) * 0.3)
            return sweep
            
        case .beep:
            return 900.0 // Higher frequency for better audibility
            
        case .blip:
            return 2600.0 // Higher frequency
        }
    }

    private func generatePreviewSample(for soundType: SyntheticSound, frequency: Float, envelope: Float, progress: Float, phase: inout Float, sampleRate: Float) -> Float {
        // Update phase
        phase += 2.0 * Float.pi * frequency / sampleRate
        if phase >= 2.0 * Float.pi {
            phase -= 2.0 * Float.pi
        }
        
        let fundamental = sin(phase) * envelope
        
        switch soundType {
        case .click:
            // Add some harmonics for richer sound
            let harmonic2 = sin(phase * 2.0) * envelope * 0.3
            let harmonic3 = sin(phase * 3.0) * envelope * 0.1
            return fundamental + harmonic2 + harmonic3
            
        case .beep:
            // Clean sine wave with slight harmonic
            let harmonic = sin(phase * 2.0) * envelope * 0.2
            return fundamental + harmonic
            
        case .blip:
            // Multiple harmonics for digital sound
            let harmonic2 = sin(phase * 2.0) * envelope * 0.4
            let harmonic3 = sin(phase * 4.0) * envelope * 0.2
            let harmonic4 = sin(phase * 8.0) * envelope * 0.1
            return fundamental + harmonic2 + harmonic3 + harmonic4
            
        case .snap:
            // This won't be used since snap uses the waveform
            return fundamental
        }
    }
    
    private func cleanupPreviewEngine() {
        previewPlayerNode?.stop()
        previewEngine?.stop()
        previewPlayerNode = nil
        previewEngine = nil
    }
    
    // MARK: - Public Audio Session Status Methods
    
    /// Returns true if headphones or bluetooth audio devices are connected
    var isUsingExternalAudio: Bool {
        return headphonesConnected
    }
    
    /// Returns true if audio session is currently interrupted
    var isAudioInterrupted: Bool {
        return audioSessionInterrupted
    }
    
    /// Manually resume playback after interruption (useful for UI controls)
    func resumeAfterInterruption() {
        guard audioSessionInterrupted == false else {
            if debugMode {
                print("⚠️ Cannot resume - audio session still interrupted")
            }
            return
        }
        
        do {
            try AVAudioSession.sharedInstance().setActive(true)
            isPlaying = true
            if debugMode {
                print("▶️ Manually resumed after interruption")
            }
        } catch {
            print("❌ Failed to resume after interruption: \(error)")
        }
    }
}
