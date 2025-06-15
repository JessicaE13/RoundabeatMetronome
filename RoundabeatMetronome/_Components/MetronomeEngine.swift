import SwiftUI
import AVFoundation

// MARK: - Sound Type Enum
enum SoundType {
    case synthetic
    case audioFile(String, String) // fileName, fileExtension
}

// MARK: - Metronome Engine with Sample-Accurate Timing and Sound File Support

class MetronomeEngine: ObservableObject {
    @Published var bpm: Int = 120 {
        didSet { updateTiming() }
    }
    
    @Published var isPlaying: Bool = false {
        didSet {
            if isPlaying {
                startMetronome()
            } else {
                stopMetronome()
            }
        }
    }
    
    @Published var beatsPerBar: Int = 4 {
        didSet { resetBeatPosition() }
    }
    
    // ADD: Support for beat unit (denominator)
    @Published var beatUnit: Int = 4 {
        didSet { resetBeatPosition() }
    }
    
    // ADD: Computed property for beatsPerMeasure (alias for beatsPerBar for compatibility)
    var beatsPerMeasure: Int {
        get { beatsPerBar }
        set { beatsPerBar = newValue }
    }
    
    @Published var currentBeat: Int = 0
    @Published var beatIndicator: Bool = false
    
    // Settings
    @Published var clickVolume: Double = 0.5 {
        didSet {
            mixerNode.outputVolume = Float(clickVolume)
            // Also update file player volume if it exists
            filePlayerNode?.volume = Float(clickVolume)
        }
    }
    @Published var accentFirstBeat: Bool = true
    @Published var visualMetronome: Bool = true
    @Published var showSquareOutline: Bool = false
    
    // NEW: Sound selection
    @Published var selectedSoundName: String = "Synthetic Click" {
        didSet { updateSoundType() }
    }
    
    // Tap tempo functionality
    private var tapTimes: [Date] = []
    private let maxTapCount = 8
    private let tapTimeoutInterval: TimeInterval = 3.0
    
    // Subdivisions
    @Published var subdivision: Int = 1 {
        didSet { updateTiming() }
    }
    
    // ADD: Subdivision multiplier support
    var subdivisionMultiplier: Double {
        get { Double(subdivision) }
        set { subdivision = Int(newValue) }
    }
    
    // Audio components
    private let audioEngine = AVAudioEngine()
    private var sourceNode: AVAudioSourceNode?
    private let mixerNode = AVAudioMixerNode()
    
    // NEW: Audio file playback components
    private var filePlayerNode: AVAudioPlayerNode?
    private var audioFiles: [String: AVAudioFile] = [:]
    private var currentSoundType: SoundType = .synthetic
    
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
    
    // Debug flag
    private var debugMode = true
    
    init() {
        setupAudioSession()
        setupAudioEngine()
        loadAudioFiles()
        updateTiming()
        updateSoundType()
    }
    
    deinit {
        stopMetronome()
    }
    
    // NEW: Update sound selection
    func updateSoundSelection(to soundName: String) {
        selectedSoundName = soundName
        if debugMode {
            print("🔊 Sound selection updated to: \(soundName)")
        }
    }
    
    // NEW: Update sound type based on selection
    private func updateSoundType() {
        if selectedSoundName == "Synthetic Click" {
            currentSoundType = .synthetic
        } else {
            // Map sound names to file names - you may need to adjust these mappings
            // based on your actual audio file names
            let soundFileMap: [String: (String, String)] = [
                "Wood Block": ("woodblock", "wav"),
                "Bongo": ("bongo", "wav"),
                "Snap": ("snap", "wav"),
                "Clap": ("clap", "wav"),
                "Cowbell": ("cowbell", "wav"),
                "Digital Beep": ("digitalbeep", "wav"),
                "Synth Click": ("synthclick", "wav"),
                "Blip": ("blip", "wav"),
                "Piano Note": ("piano", "wav"),
                "Guitar Pick": ("guitar", "wav"),
                "Classic Tick": ("tick", "wav"),
                "Mechanical Click": ("mechanical", "wav")
            ]
            
            if let (fileName, fileExtension) = soundFileMap[selectedSoundName] {
                currentSoundType = .audioFile(fileName, fileExtension)
            } else {
                currentSoundType = .synthetic
                if debugMode {
                    print("⚠️ Sound file not found for '\(selectedSoundName)', falling back to synthetic")
                }
            }
        }
    }
    
    // NEW: Load audio files
    private func loadAudioFiles() {
        let soundFiles = [
            ("woodblock", "wav"),
            ("bongo", "wav"),
            ("snap", "wav"),
            ("clap", "wav"),
            ("cowbell", "wav"),
            ("digitalbeep", "wav"),
            ("synthclick", "wav"),
            ("blip", "wav"),
            ("piano", "wav"),
            ("guitar", "wav"),
            ("tick", "wav"),
            ("mechanical", "wav")
        ]
        
        for (fileName, fileExtension) in soundFiles {
            if let url = Bundle.main.url(forResource: fileName, withExtension: fileExtension) {
                do {
                    let audioFile = try AVAudioFile(forReading: url)
                    audioFiles[fileName] = audioFile
                    if debugMode {
                        print("✅ Loaded audio file: \(fileName).\(fileExtension)")
                    }
                } catch {
                    if debugMode {
                        print("❌ Failed to load audio file \(fileName).\(fileExtension): \(error)")
                    }
                }
            } else {
                if debugMode {
                    print("⚠️ Audio file not found: \(fileName).\(fileExtension)")
                }
            }
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
    
    private func setupAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(.playback, mode: .default, options: [])
            try audioSession.setPreferredIOBufferDuration(0.005)
            try audioSession.setPreferredSampleRate(48000.0)
            try audioSession.setActive(true)
            
            sampleRate = audioSession.sampleRate
            if debugMode {
                print("✅ Audio session sample rate: \(sampleRate)")
            }
            
        } catch {
            print("❌ Audio session setup failed: \(error)")
        }
    }
    
    private func setupAudioEngine() {
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        
        // Setup synthetic sound source node
        sourceNode = AVAudioSourceNode(format: format) { [weak self] _, _, frameCount, audioBufferList -> OSStatus in
            return self?.renderAudio(frameCount: frameCount, audioBufferList: audioBufferList) ?? noErr
        }
        
        // Setup audio file player node
        filePlayerNode = AVAudioPlayerNode()
        
        guard let sourceNode = sourceNode, let filePlayerNode = filePlayerNode else {
            print("❌ Failed to create audio nodes")
            return
        }
        
        audioEngine.attach(sourceNode)
        audioEngine.attach(filePlayerNode)
        audioEngine.attach(mixerNode)
        
        // Connect both nodes to mixer
        audioEngine.connect(sourceNode, to: mixerNode, format: format)
        audioEngine.connect(filePlayerNode, to: mixerNode, format: format)
        audioEngine.connect(mixerNode, to: audioEngine.outputNode, format: format)
        
        mixerNode.outputVolume = Float(clickVolume)
        filePlayerNode.volume = Float(clickVolume)
        
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
            currentSamplePosition = 0
            nextBeatSample = 0
            lastBeatSample = 0
            beatCounter = 0
            currentBeat = 1
            clickPhase = 0.0
            
            try audioEngine.start()
            
            if debugMode {
                print("🎵 Metronome started at \(bpm) BPM on beat 1")
                print("🎵 Engine running: \(audioEngine.isRunning)")
                print("🎵 Current sound type: \(currentSoundType)")
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
        filePlayerNode?.stop()
        
        DispatchQueue.main.async { [weak self] in
            self?.beatIndicator = false
            self?.currentBeat = 0
        }
        
        if debugMode {
            print("🛑 Metronome stopped")
        }
    }
    
    // NEW: Play audio file click
    private func playAudioFileClick(fileName: String, isAccent: Bool) {
        guard let audioFile = audioFiles[fileName],
              let filePlayerNode = filePlayerNode else {
            if debugMode {
                print("❌ Audio file or player node not available for: \(fileName)")
            }
            return
        }
        
        // For audio files, we can use volume to simulate accent
        let volume = isAccent ? Float(clickVolume * 1.2) : Float(clickVolume)
        filePlayerNode.volume = min(1.0, volume)
        
        // Schedule the audio file to play
        filePlayerNode.scheduleFile(audioFile, at: nil) {
            // Reset volume after playing
            DispatchQueue.main.async {
                filePlayerNode.volume = Float(self.clickVolume)
            }
        }
        
        if !filePlayerNode.isPlaying {
            filePlayerNode.play()
        }
    }
    
    // MARK: - Real-Time Audio Render Callback
    private func renderAudio(frameCount: UInt32, audioBufferList: UnsafeMutablePointer<AudioBufferList>) -> OSStatus {
        
        let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)
        guard let buffer = ablPointer[0].mData?.assumingMemoryBound(to: Float.self) else {
            if debugMode {
                print("❌ Failed to get audio buffer")
            }
            return kAudioUnitErr_InvalidParameter
        }
        
        let frames = Int(frameCount)
        let clickDurationSamples = Int(clickDuration * sampleRate)
        
        var beatTriggeredInThisCycle = false
        var newBeatNumber = currentBeat
        
        for frameIndex in 0..<frames {
            let currentSample = currentSamplePosition + Int64(frameIndex)
            var sample: Float = 0.0
            
            if currentSample >= nextBeatSample && !beatTriggeredInThisCycle {
                lastBeatSample = nextBeatSample
                nextBeatSample += Int64(samplesPerBeat)
                beatCounter += 1
                
                newBeatNumber = ((beatCounter - 1) % beatsPerBar) + 1
                beatTriggeredInThisCycle = true
                
                let isAccent = accentFirstBeat && newBeatNumber == 1
                
                // Handle different sound types
                switch currentSoundType {
                case .synthetic:
                    clickPhase = 0.0 // Reset synthetic click phase
                case .audioFile(let fileName, _):
                    // Trigger audio file playback on main thread
                    DispatchQueue.main.async { [weak self] in
                        self?.playAudioFileClick(fileName: fileName, isAccent: isAccent)
                    }
                }
                
                if debugMode && beatCounter <= 20 {
                    print("🥁 Beat triggered: \(newBeatNumber) at sample \(currentSample), next at \(nextBeatSample)")
                }
            }
            
            // Only generate synthetic sound if using synthetic sound type
            if case .synthetic = currentSoundType {
                let samplesSinceLastBeat = currentSample - lastBeatSample
                if samplesSinceLastBeat >= 0 && samplesSinceLastBeat < clickDurationSamples {
                    let clickProgress = Float(samplesSinceLastBeat) / Float(clickDurationSamples)
                    let envelope = (1.0 - clickProgress) * 0.3
                    
                    let frequency = (accentFirstBeat && newBeatNumber == 1) ? accentFrequency : clickFrequency
                    
                    sample = sin(clickPhase) * envelope
                    clickPhase += 2.0 * Float.pi * frequency / Float(sampleRate)
                    
                    if clickPhase >= 2.0 * Float.pi {
                        clickPhase -= 2.0 * Float.pi
                    }
                }
            }
            
            buffer[frameIndex] = sample
        }
        
        currentSamplePosition += Int64(frames)
        
        if beatTriggeredInThisCycle {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.currentBeat = newBeatNumber
                self.beatIndicator.toggle()
            }
        }
        
        return noErr
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
}
