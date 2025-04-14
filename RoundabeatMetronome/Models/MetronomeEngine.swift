//
//  MetronomeEngine.swift
//  RoundabeatMetronome
//
//  Created by Jessica Estes on 4/13/25.
//

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
            // Execute beat
            currentBeat = (currentBeat + 1) % beatsPerMeasure
            playClick()
            
            // Reset accumulator, accounting for potential overflow
            // This helps maintain accurate timing by carrying over extra time
            timeAccumulator -= beatInterval
            
            // If there's still a significant accumulation, adjust further
            // This helps prevent drift over time
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
