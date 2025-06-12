

import SwiftUI
import AVFoundation

// MARK: - Metronome Engine with Sample-Accurate Timing

@Observable
class MetronomeEngine {
    var bpm: Int = 120 {
        didSet { updateTiming() }
    }
    
    var isPlaying: Bool = false {
        didSet {
            if isPlaying {
                startMetronome()
            } else {
                stopMetronome()
            }
        }
    }
    
    var beatsPerBar: Int = 4 {
        didSet { resetBeatPosition() }
    }
    
    var currentBeat: Int = 0
    var beatIndicator: Bool = false
    
    // Settings
    var clickVolume: Double = 0.5 {
        didSet { mixerNode.outputVolume = Float(clickVolume) }
    }
    var accentFirstBeat: Bool = true
    var visualMetronome: Bool = true
    var showSquareOutline: Bool = false // New variable for square outline visibility
    
    // Tap tempo functionality
    private var tapTimes: [Date] = []
    private let maxTapCount = 8 // Use last 8 taps for averaging
    private let tapTimeoutInterval: TimeInterval = 3.0 // Reset if no tap for 3 seconds
    
    // Subdivisions
    var subdivision: Int = 1 {
        didSet { updateTiming() }
    }
    
    // Audio components
    private let audioEngine = AVAudioEngine()
    private var sourceNode: AVAudioSourceNode?
    private let mixerNode = AVAudioMixerNode()
    
    // Timing variables (accessed atomically from audio thread)
    private var sampleRate: Double = 44100.0
    private var samplesPerBeat: Double = 0
    private var currentSamplePosition: Int64 = 0
    private var nextBeatSample: Int64 = 0
    private var beatCounter: Int = 0
    private var lastBeatSample: Int64 = 0  // Track when last beat occurred
    
    // Click generation
    private var clickPhase: Float = 0.0
    private let clickFrequency: Float = 1000.0 // 1kHz click
    private let accentFrequency: Float = 1200.0 // Higher pitch for accent
    private let clickDuration: Double = 0.1 // 100ms clicks
    
    // Debug flag
    private var debugMode = true
    
    init() {
        setupAudioSession()
        setupAudioEngine()
        updateTiming()
    }
    
    deinit {
        stopMetronome()
    }
    
    private func setupAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            // Configure for lowest latency playback only
            try audioSession.setCategory(.playback, mode: .default, options: [])
            try audioSession.setPreferredIOBufferDuration(0.005) // Increased to 5ms for better stability
            try audioSession.setPreferredSampleRate(48000.0)
            try audioSession.setActive(true)
            
            // Get actual sample rate after activation
            sampleRate = audioSession.sampleRate
            if debugMode {
                print("✅ Audio session sample rate: \(sampleRate)")
            }
            
        } catch {
            print("❌ Audio session setup failed: \(error)")
        }
    }
    
    private func setupAudioEngine() {
        // Create audio format matching system
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        
        // Create source node for precise sample generation
        sourceNode = AVAudioSourceNode(format: format) { [weak self] _, _, frameCount, audioBufferList -> OSStatus in
            return self?.renderAudio(frameCount: frameCount, audioBufferList: audioBufferList) ?? noErr
        }
        
        guard let sourceNode = sourceNode else {
            print("❌ Failed to create source node")
            return
        }
        
        // Connect nodes: SourceNode -> Mixer -> Output
        audioEngine.attach(sourceNode)
        audioEngine.attach(mixerNode)
        
        audioEngine.connect(sourceNode, to: mixerNode, format: format)
        audioEngine.connect(mixerNode, to: audioEngine.outputNode, format: format)
        
        // Set mixer volume
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
            // Reset timing - schedule first beat immediately as beat 1
            currentSamplePosition = 0
            nextBeatSample = 0  // First beat happens at sample 0
            lastBeatSample = 0  // Initialize last beat position
            beatCounter = 0
            currentBeat = 1  // Start on beat 1
            clickPhase = 0.0
            
            try audioEngine.start()
            
            if debugMode {
                print("🎵 Metronome started at \(bpm) BPM on beat 1")
                print("🎵 Engine running: \(audioEngine.isRunning)")
                print("🎵 Output node: \(audioEngine.outputNode)")
            }
            
        } catch {
            print("❌ Failed to start audio engine: \(error)")
            // Reset isPlaying state if start failed
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
        
        // Update UI on main thread
        DispatchQueue.main.async { [weak self] in
            self?.beatIndicator = false
            self?.currentBeat = 0
        }
        
        if debugMode {
            print("🛑 Metronome stopped")
        }
    }
    
    // MARK: - Real-Time Audio Render Callback
    private func renderAudio(frameCount: UInt32, audioBufferList: UnsafeMutablePointer<AudioBufferList>) -> OSStatus {
        
        // Get audio buffer
        let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)
        guard let buffer = ablPointer[0].mData?.assumingMemoryBound(to: Float.self) else {
            if debugMode {
                print("❌ Failed to get audio buffer")
            }
            return kAudioUnitErr_InvalidParameter
        }
        
        let frames = Int(frameCount)
        let clickDurationSamples = Int(clickDuration * sampleRate)
        
        // Track if we triggered a beat in this render cycle
        var beatTriggeredInThisCycle = false
        var newBeatNumber = currentBeat
        
        // Process each frame
        for frameIndex in 0..<frames {
            let currentSample = currentSamplePosition + Int64(frameIndex)
            var sample: Float = 0.0
            
            // Check if we should trigger a beat (only once per beat)
            if currentSample >= nextBeatSample && !beatTriggeredInThisCycle {
                // Update last beat position before scheduling next
                lastBeatSample = nextBeatSample
                
                // Schedule next beat
                nextBeatSample += Int64(samplesPerBeat)
                beatCounter += 1
                
                // Calculate new beat number (1-based indexing)
                newBeatNumber = ((beatCounter - 1) % beatsPerBar) + 1
                
                beatTriggeredInThisCycle = true
                
                // Reset click phase for new click
                clickPhase = 0.0
                
                if debugMode && beatCounter <= 20 { // Only log first 20 beats to avoid spam
                    print("🥁 Beat triggered: \(newBeatNumber) at sample \(currentSample), next at \(nextBeatSample)")
                }
            }
            
            // Generate click sound if within click duration
            let samplesSinceLastBeat = currentSample - lastBeatSample
            if samplesSinceLastBeat >= 0 && samplesSinceLastBeat < clickDurationSamples {
                // Generate sine wave click with envelope
                let clickProgress = Float(samplesSinceLastBeat) / Float(clickDurationSamples)
                let envelope = (1.0 - clickProgress) * 0.3 // Decay envelope
                
                // Use accent frequency for first beat if enabled
                let frequency = (accentFirstBeat && newBeatNumber == 1) ? accentFrequency : clickFrequency
                
                sample = sin(clickPhase) * envelope
                clickPhase += 2.0 * Float.pi * frequency / Float(sampleRate)
                
                // Keep phase in range
                if clickPhase >= 2.0 * Float.pi {
                    clickPhase -= 2.0 * Float.pi
                }
            }
            
            // Write sample to buffer
            buffer[frameIndex] = sample
        }
        
        // Update position counter
        currentSamplePosition += Int64(frames)
        
        // Update UI on main thread only if we triggered a beat
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
        
        // Remove old taps (older than timeout interval)
        tapTimes.removeAll { now.timeIntervalSince($0) > tapTimeoutInterval }
        
        // Add current tap
        tapTimes.append(now)
        
        // Need at least 2 taps to calculate tempo
        guard tapTimes.count >= 2 else { return }
        
        // Keep only the most recent taps
        if tapTimes.count > maxTapCount {
            tapTimes.removeFirst()
        }
        
        // Calculate average interval between taps
        var totalInterval: TimeInterval = 0
        for i in 1..<tapTimes.count {
            totalInterval += tapTimes[i].timeIntervalSince(tapTimes[i-1])
        }
        
        let averageInterval = totalInterval / Double(tapTimes.count - 1)
        let calculatedBPM = 60.0 / averageInterval
        
        // Clamp to reasonable BPM range
        let clampedBPM = max(40, min(400, Int(calculatedBPM.rounded())))
        
        // Update BPM
        bpm = clampedBPM
        
        if debugMode {
            print("👆 Tap tempo: \(tapTimes.count) taps, avg interval: \(averageInterval)s, BPM: \(clampedBPM)")
        }
    }
    
    // MARK: - Subdivision Helper
    func subdivisionLabel() -> String {
        switch subdivision {
        case 1:
            return "♩" // Quarter note
        case 2:
            return "♫" // Eighth note
        case 4:
            return "♬" // Sixteenth note
        case 3:
            return "♩." // Dotted quarter (triplet)
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
