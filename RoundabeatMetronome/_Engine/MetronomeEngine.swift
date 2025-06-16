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

// MARK: - Metronome Engine with Sample-Accurate Timing

class MetronomeEngine: ObservableObject {
    
    @Published var emphasizeFirstBeatOnly: Bool = false
    
    @Published var fullScreenFlashOnFirstBeat: Bool = false
    @Published var isFlashing: Bool = false
    
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
    
    // ADD: Sound selection property
    @Published var selectedSoundType: SyntheticSound = .click
    
    // Settings
    @Published var clickVolume: Double = 0.5 {
        didSet { mixerNode.outputVolume = Float(clickVolume) }
    }
    @Published var accentFirstBeat: Bool = true
    @Published var visualMetronome: Bool = true
    @Published var showSquareOutline: Bool = false
    
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
    
    // Preview audio components - separate from main metronome
    private var previewEngine: AVAudioEngine?
    private var previewPlayerNode: AVAudioPlayerNode?
    
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
    private var snapPlaybackPosition: Double = 0.0  // Use Double for fractional indexing
    private var isPlayingSnap: Bool = false
    private let snapOriginalSampleRate: Double = 24000.0  // Original waveform sample rate
    
    // Debug flag
    private var debugMode = false // Turn off debug by default to reduce console spam
    
    init() {
        setupAudioSession()
        setupAudioEngine()
        updateTiming()
    }
    
    deinit {
        stopMetronome()
        cleanupPreviewEngine()
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
            currentSamplePosition = 0
            nextBeatSample = 0
            lastBeatSample = 0
            beatCounter = 0
            currentBeat = 1
            clickPhase = 0.0
            snapPlaybackPosition = 0.0
            isPlayingSnap = false
            
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
        
        // Flash duration - adjust as needed (0.1 seconds)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.isFlashing = false
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
    
    // MARK: - Alternative Preview Method (More Complex but Safer)
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
                
                // Generate preview buffer
                let estimatedDuration = previewSoundType == .snap ?
                    (Double(snapWaveform.count) / snapOriginalSampleRate) : 0.1
                let frameCount = UInt32(format.sampleRate * estimatedDuration)
                
                guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
                    DispatchQueue.main.async {
                        if #available(iOS 10.0, *) {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        }
                    }
                    return
                }
                
                buffer.frameLength = frameCount
                
                // Generate sound data
                if previewSoundType == .snap {
                    // Use snap waveform with proper sample rate handling
                    let channelData = buffer.floatChannelData![0]
                    let sampleRateRatio = snapOriginalSampleRate / format.sampleRate
                    
                    for i in 0..<Int(frameCount) {
                        let adjustedPosition = Double(i) * sampleRateRatio
                        let index = Int(adjustedPosition)
                        
                        if index < snapWaveform.count {
                            channelData[i] = snapWaveform[index] * 0.6 // Preview volume
                        } else {
                            channelData[i] = 0.0
                        }
                    }
                } else {
                    // Use synthetic generation for other sounds
                    var phase: Float = 0.0
                    let sampleRate = Float(format.sampleRate)
                    
                    for frame in 0..<Int(frameCount) {
                        let progress = Float(frame) / Float(frameCount)
                        let envelope = self.generateEnvelope(for: previewSoundType, progress: progress)
                        let frequency = self.generateFrequency(for: previewSoundType, isAccent: false, progress: progress)
                        
                        phase += 2.0 * Float.pi * frequency / sampleRate
                        if phase >= 2.0 * Float.pi {
                            phase -= 2.0 * Float.pi
                        }
                        
                        let sample = self.generateSample(for: previewSoundType, frequency: frequency, envelope: envelope, progress: progress)
                        buffer.floatChannelData?[0][frame] = sample * 0.5 // Reduce volume for preview
                    }
                }
                
                // Start engine and schedule buffer
                try engine.start()
                
                playerNode.scheduleBuffer(buffer) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
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
    
    private func cleanupPreviewEngine() {
        previewPlayerNode?.stop()
        previewEngine?.stop()
        previewPlayerNode = nil
        previewEngine = nil
    }
}
