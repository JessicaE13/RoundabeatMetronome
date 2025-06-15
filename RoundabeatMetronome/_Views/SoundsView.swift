//import SwiftUI
//import AVFoundation
//
//// MARK: - Sound Option Model
//struct SoundOption: Identifiable, Equatable {
//    let id = UUID()
//    let name: String
//    let fileName: String?  // nil for synthetic sounds
//    let fileExtension: String?
//    let category: SoundCategory
//    let description: String
//    let isSynthetic: Bool
//    
//    var displayName: String {
//        return name
//    }
//    
//    static func == (lhs: SoundOption, rhs: SoundOption) -> Bool {
//        return lhs.name == rhs.name
//    }
//}
//
//// MARK: - Sound Categories
//enum SoundCategory: String, CaseIterable {
//    case synthetic = "Synthetic"
//    case percussion = "Percussion"
//    case electronic = "Electronic"
//    case acoustic = "Acoustic"
//    case classic = "Classic"
//    
//    var icon: String {
//        switch self {
//        case .synthetic: return "waveform.path"
//        case .percussion: return "drum"
//        case .electronic: return "waveform"
//        case .acoustic: return "music.note"
//        case .classic: return "metronome"
//        }
//    }
//}
//
//// MARK: - Adaptive Sounds View
//struct SoundsView: View {
//    @ObservedObject var metronome: MetronomeEngine
//    @State private var selectedSound: SoundOption = SoundsView.defaultSounds[0]
//    @State private var audioPlayer: AVAudioPlayer?
//    @State private var isPlaying = false
//    @State private var selectedCategory: SoundCategory? = nil
//    @State private var playerDelegate: SoundPlayerDelegate?
//    
//    // Available sound options - synthetic sound first as default
//    static let defaultSounds: [SoundOption] = [
//        // Synthetic (Default)
//        SoundOption(name: "Synthetic Click", fileName: nil, fileExtension: nil, category: .synthetic, description: "Built-in synthetic metronome sound", isSynthetic: true),
//        
//        // Percussion
//        SoundOption(name: "Wood Block", fileName: "woodblock", fileExtension: "wav", category: .percussion, description: "Classic wooden metronome sound", isSynthetic: false),
//        SoundOption(name: "Bongo", fileName: "bongo", fileExtension: "wav", category: .percussion, description: "Warm bongo drum hit", isSynthetic: false),
//        SoundOption(name: "Snap", fileName: "snap", fileExtension: "wav", category: .percussion, description: "Crisp finger snap", isSynthetic: false),
//        SoundOption(name: "Clap", fileName: "clap", fileExtension: "wav", category: .percussion, description: "Hand clap sound", isSynthetic: false),
//        SoundOption(name: "Cowbell", fileName: "cowbell", fileExtension: "wav", category: .percussion, description: "Classic cowbell ring", isSynthetic: false),
//        
//        // Electronic
//        SoundOption(name: "Digital Beep", fileName: "digitalbeep", fileExtension: "wav", category: .electronic, description: "Clean digital beep", isSynthetic: false),
//        SoundOption(name: "Synth Click", fileName: "synthclick", fileExtension: "wav", category: .electronic, description: "Electronic click sound", isSynthetic: false),
//        SoundOption(name: "Blip", fileName: "blip", fileExtension: "wav", category: .electronic, description: "Short electronic blip", isSynthetic: false),
//        
//        // Acoustic
//        SoundOption(name: "Piano Note", fileName: "piano", fileExtension: "wav", category: .acoustic, description: "Single piano note", isSynthetic: false),
//        SoundOption(name: "Guitar Pick", fileName: "guitar", fileExtension: "wav", category: .acoustic, description: "Guitar string pick", isSynthetic: false),
//        
//        // Classic
//        SoundOption(name: "Classic Tick", fileName: "tick", fileExtension: "wav", category: .classic, description: "Traditional metronome tick", isSynthetic: false),
//        SoundOption(name: "Mechanical Click", fileName: "mechanical", fileExtension: "wav", category: .classic, description: "Mechanical metronome click", isSynthetic: false)
//    ]
//    
//    var filteredSounds: [SoundOption] {
//        if let category = selectedCategory {
//            return SoundsView.defaultSounds.filter { $0.category == category }
//        }
//        return SoundsView.defaultSounds
//    }
//    
//    var body: some View {
//        GeometryReader { geometry in
//            let contentMaxWidth: CGFloat? = nil
//            let horizontalPadding: CGFloat = 20
//            
//            ZStack {
//                BackgroundView()
//                
//                ScrollView {
//                    VStack(spacing: 0) {
//                        // Header
//                        headerView()
//                            .padding(.top, geometry.safeAreaInsets.top + 24)
//                        
//                        // Category Filter
//                        categoryFilterView(horizontalPadding: horizontalPadding)
//                        
//                        // Sound List
//                        soundListView(horizontalPadding: horizontalPadding)
//                        
//                        // Current Selection Info
//                        currentSelectionView(horizontalPadding: horizontalPadding)
//                        
//                        // Reduced bottom spacing since MainTabView handles tab bar spacing
//                        Spacer()
//                            .frame(height: 20)
//                    }
//                    .frame(maxWidth: contentMaxWidth)
//                    .frame(maxWidth: .infinity) // Center the content
//                    .frame(minHeight: geometry.size.height)
//                }
//            }
//        }
//        .ignoresSafeArea(.all, edges: [.top, .leading, .trailing]) // Don't ignore bottom for tab bar
//        .onAppear {
//            setupAudioSession()
//            // Initialize selectedSound based on metronome's current sound
//            if let currentSound = SoundsView.defaultSounds.first(where: { $0.name == metronome.selectedSoundName }) {
//                selectedSound = currentSound
//            }
//        }
//    }
//    
//    private func headerView() -> some View {
//        VStack(spacing: 8) {
//            Text("METRONOME SOUNDS")
//                .font(.system(size: 12, weight: .medium))
//                .kerning(1.5)
//                .foregroundColor(Color.white.opacity(0.4))
//                .padding(.top, 12)
//            
//            Text("Choose Your Beat")
//                .font(.system(size: 12, weight: .medium))
//                .kerning(1)
//                .foregroundColor(Color.white.opacity(0.9))
//                .padding(.bottom, 12)
//        }
//    }
//    
//    private func categoryFilterView(horizontalPadding: CGFloat) -> some View {
//        ScrollView(.horizontal, showsIndicators: false) {
//            HStack(spacing: 12) {
//                // All category button
//                categoryButton(category: nil, title: "All")
//                
//                ForEach(SoundCategory.allCases, id: \.self) { category in
//                    categoryButton(category: category, title: category.rawValue)
//                }
//            }
//            .padding(.horizontal, horizontalPadding)
//        }
//        .padding(.bottom, 16)
//    }
//    
//    private func categoryButton(category: SoundCategory?, title: String) -> some View {
//        let isSelected = selectedCategory == category
//        
//        return Button(action: {
//            selectedCategory = category
//            
//            if #available(iOS 10.0, *) {
//                UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: 0.5)
//            }
//        }) {
//            HStack(spacing: 6) {
//                if let category = category {
//                    Image(systemName: category.icon)
//                        .font(.system(size: 12, weight: .medium))
//                } else {
//                    Image(systemName: "music.note.list")
//                        .font(.system(size: 12, weight: .medium))
//                }
//                
//                Text(title)
//                    .font(.system(size: 12))
//                    .kerning(0.5)
//            }
//            .foregroundColor(isSelected ? Color.white.opacity(0.9) : Color.white.opacity(0.6))
//            .padding(.horizontal, 16)
//            .padding(.vertical, 8)
//            .background(
//                RoundedRectangle(cornerRadius: 20)
//                    .fill(isSelected ? Color.white.opacity(0.15) : Color.white.opacity(0.05))
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 20)
//                            .stroke(
//                                isSelected ? Color.white.opacity(0.25) : Color.white.opacity(0.1),
//                                lineWidth: 1
//                            )
//                    )
//            )
//        }
//    }
//    
//    private func soundListView(horizontalPadding: CGFloat) -> some View {
//        LazyVStack(spacing: 12) {
//            ForEach(filteredSounds) { sound in
//                soundRowView(sound: sound)
//            }
//        }
//        .padding(.horizontal, horizontalPadding)
//        .padding(.bottom, 16)
//    }
//    
//    private func soundRowView(sound: SoundOption) -> some View {
//        // Check if this sound is the currently selected metronome sound
//        let isSelected = sound.name == metronome.selectedSoundName
//        let isCurrentlyPlaying = isPlaying && selectedSound == sound
//        
//        return Button(action: {
//            // Update the metronome's sound selection
//            metronome.updateSoundSelection(to: sound.name)
//            selectedSound = sound
//            
//            // Only play preview if metronome is NOT currently playing
//            if !metronome.isPlaying {
//                if sound.isSynthetic {
//                    // For synthetic sound, just play a brief synthetic preview
//                    playSyntheticPreview()
//                } else {
//                    // For audio files, play the actual file
//                    playSound(sound)
//                }
//            } else {
//                // If metronome is playing, just provide haptic feedback
//                if #available(iOS 10.0, *) {
//                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
//                }
//                print("🔊 Sound updated to '\(sound.name)' - preview skipped (metronome playing)")
//            }
//        }) {
//            HStack(spacing: 16) {
//                // Sound category icon
//                Image(systemName: sound.category.icon)
//                    .font(.system(size: 18, weight: .medium))
//                    .foregroundColor(isSelected ? Color.white.opacity(0.9) : Color.white.opacity(0.5))
//                    .frame(width: 24, height: 24)
//                
//                // Sound info
//                VStack(alignment: .leading, spacing: 4) {
//                    HStack {
//                        Text(sound.displayName)
//                            .font(.system(size: 16))
//                            .kerning(0.5)
//                            .foregroundColor(isSelected ? Color.white.opacity(0.9) : Color.white.opacity(0.7))
//                        
//                        if sound.isSynthetic {
//                            Text("DEFAULT")
//                                .font(.system(size: 10, weight: .bold))
//                                .kerning(0.5)
//                                .foregroundColor(Color.blue.opacity(0.8))
//                                .padding(.horizontal, 6)
//                                .padding(.vertical, 2)
//                                .background(
//                                    RoundedRectangle(cornerRadius: 4)
//                                        .fill(Color.blue.opacity(0.2))
//                                )
//                        }
//                        
//                        Spacer()
//                    }
//                    
//                    Text(sound.description)
//                        .font(.system(size: 12))
//                        .foregroundColor(isSelected ? Color.white.opacity(0.6) : Color.white.opacity(0.4))
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                }
//                
//                // Play/Playing indicator - show different states based on metronome
//                HStack(spacing: 8) {
//                    if metronome.isPlaying && isSelected {
//                        // Show that this sound is actively being used by the metronome
//                        HStack(spacing: 2) {
//                            ForEach(0..<3) { index in
//                                Rectangle()
//                                    .fill(Color.green.opacity(0.8))
//                                    .frame(width: 3, height: 12)
//                                    .scaleEffect(y: 1.0)
//                                    .animation(
//                                        Animation.easeInOut(duration: 0.5)
//                                            .repeatForever()
//                                            .delay(Double(index) * 0.1),
//                                        value: true
//                                    )
//                            }
//                        }
//                        .frame(width: 20, height: 20)
//                    } else if isCurrentlyPlaying && !metronome.isPlaying {
//                        // Show preview playing indicator (only when metronome is not playing)
//                        HStack(spacing: 2) {
//                            ForEach(0..<3) { index in
//                                Rectangle()
//                                    .fill(Color.white.opacity(0.8))
//                                    .frame(width: 3, height: 12)
//                                    .scaleEffect(y: isCurrentlyPlaying ? 1.0 : 0.3)
//                                    .animation(
//                                        Animation.easeInOut(duration: 0.5)
//                                            .repeatForever()
//                                            .delay(Double(index) * 0.1),
//                                        value: isCurrentlyPlaying
//                                    )
//                            }
//                        }
//                        .frame(width: 20, height: 20)
//                    } else {
//                        // Show play button
//                        Image(systemName: metronome.isPlaying ? "waveform" : "play.circle")
//                            .font(.system(size: 20, weight: .medium))
//                            .foregroundColor(metronome.isPlaying && isSelected ? Color.green.opacity(0.8) : Color.white.opacity(0.6))
//                    }
//                    
//                    if isSelected {
//                        Image(systemName: "checkmark.circle.fill")
//                            .font(.system(size: 20, weight: .medium))
//                            .foregroundColor(metronome.isPlaying ? Color.green.opacity(0.8) : Color.white.opacity(0.8))
//                    }
//                }
//            }
//            .padding(.horizontal, 20)
//            .padding(.vertical, 16)
//            .background(
//                RoundedRectangle(cornerRadius: 16)
//                    .fill(isSelected ? Color.white.opacity(0.1) : Color.black.opacity(0.2))
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 16)
//                            .stroke(
//                                isSelected ? Color.white.opacity(0.2) : Color.white.opacity(0.05),
//                                lineWidth: 1
//                            )
//                    )
//            )
//        }
//        .scaleEffect(isCurrentlyPlaying ? 1.02 : 1.0)
//        .animation(.easeInOut(duration: 0.1), value: isCurrentlyPlaying)
//    }
//    
//    private func currentSelectionView(horizontalPadding: CGFloat) -> some View {
//        VStack(spacing: 12) {
//            Rectangle()
//                .fill(Color.white.opacity(0.1))
//                .frame(height: 1)
//                .padding(.horizontal, horizontalPadding)
//            
//            HStack(spacing: 16) {
//                VStack(alignment: .leading, spacing: 4) {
//                    Text("CURRENT SOUND")
//                        .font(.system(size: 10, weight: .medium))
//                        .kerning(1)
//                        .foregroundColor(Color.white.opacity(0.4))
//                    
//                    HStack {
//                        Text(metronome.selectedSoundName)
//                            .font(.system(size: 16))
//                            .kerning(0.5)
//                            .foregroundColor(Color.white.opacity(0.9))
//                        
//                        if metronome.selectedSoundName == "Synthetic Click" {
//                            Text("DEFAULT")
//                                .font(.system(size: 8, weight: .bold))
//                                .kerning(0.5)
//                                .foregroundColor(Color.blue.opacity(0.8))
//                                .padding(.horizontal, 4)
//                                .padding(.vertical, 1)
//                                .background(
//                                    RoundedRectangle(cornerRadius: 3)
//                                        .fill(Color.blue.opacity(0.2))
//                                )
//                        }
//                    }
//                }
//                
//                Spacer()
//                
//                Button(action: {
//                    // Only preview if metronome is not playing
//                    if !metronome.isPlaying {
//                        if metronome.selectedSoundName == "Synthetic Click" {
//                            playSyntheticPreview()
//                        } else if let currentSound = SoundsView.defaultSounds.first(where: { $0.name == metronome.selectedSoundName }) {
//                            playSound(currentSound)
//                        }
//                    } else {
//                        // Provide feedback that preview is disabled during playback
//                        if #available(iOS 10.0, *) {
//                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
//                        }
//                    }
//                }) {
//                    HStack(spacing: 8) {
//                        Image(systemName: metronome.isPlaying ? "waveform" : "play.fill")
//                            .font(.system(size: 14, weight: .medium))
//                        
//                        Text(metronome.isPlaying ? "PLAYING" : "PREVIEW")
//                            .font(.system(size: 12))
//                            .kerning(0.5)
//                    }
//                    .foregroundColor(metronome.isPlaying ? Color.green.opacity(0.9) : Color.white.opacity(0.9))
//                    .padding(.horizontal, 16)
//                    .padding(.vertical, 10)
//                    .background(
//                        RoundedRectangle(cornerRadius: 20)
//                            .fill(metronome.isPlaying ? Color.green.opacity(0.15) : Color.white.opacity(0.15))
//                            .overlay(
//                                RoundedRectangle(cornerRadius: 20)
//                                    .stroke(metronome.isPlaying ? Color.green.opacity(0.25) : Color.white.opacity(0.25), lineWidth: 1)
//                            )
//                    )
//                }
//                .disabled(metronome.isPlaying) // Disable the button when metronome is playing
//            }
//            .padding(.horizontal, horizontalPadding)
//            .padding(.bottom, 12)
//        }
//    }
//    
//    // MARK: - Audio Functions
//    
//    private func setupAudioSession() {
//        do {
//            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
//            try AVAudioSession.sharedInstance().setActive(true)
//        } catch {
//            print("Failed to set up audio session: \(error)")
//        }
//    }
//    
//    // NEW: Play synthetic preview
//    private func playSyntheticPreview() {
//        // Create a simple synthetic click sound using AVAudioEngine
//        let audioEngine = AVAudioEngine()
//        let playerNode = AVAudioPlayerNode()
//        
//        audioEngine.attach(playerNode)
//        audioEngine.connect(playerNode, to: audioEngine.outputNode, format: audioEngine.outputNode.outputFormat(forBus: 0))
//        
//        do {
//            try audioEngine.start()
//            
//            // Generate a brief synthetic click
//            let sampleRate = 44100.0
//            let duration = 0.1
//            let frameCount = UInt32(sampleRate * duration)
//            
//            guard let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1) else { return }
//            guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return }
//            
//            buffer.frameLength = frameCount
//            
//            let frequency: Float = 1000.0
//            let amplitude: Float = 0.3
//            
//            for frame in 0..<Int(frameCount) {
//                let sampleTime = Float(frame) / Float(sampleRate)
//                let envelope = (1.0 - sampleTime / Float(duration)) * amplitude
//                let sample = sin(2.0 * Float.pi * frequency * sampleTime) * envelope
//                buffer.floatChannelData?[0][frame] = sample
//            }
//            
//            playerNode.scheduleBuffer(buffer) {
//                DispatchQueue.main.async {
//                    self.isPlaying = false
//                    audioEngine.stop()
//                }
//            }
//            
//            isPlaying = true
//            playerNode.play()
//            
//            // Add haptic feedback
//            if #available(iOS 10.0, *) {
//                UIImpactFeedbackGenerator(style: .light).impactOccurred()
//            }
//            
//            // Auto-stop playing indicator after duration
//            DispatchQueue.main.asyncAfter(deadline: .now() + duration + 0.1) {
//                if self.isPlaying {
//                    self.isPlaying = false
//                }
//            }
//            
//        } catch {
//            print("Failed to play synthetic preview: \(error)")
//            isPlaying = false
//        }
//    }
//    
//    private func playSound(_ sound: SoundOption) {
//        // Don't play if it's synthetic (handled separately)
//        guard !sound.isSynthetic,
//              let fileName = sound.fileName,
//              let fileExtension = sound.fileExtension else {
//            return
//        }
//        
//        // Stop any currently playing sound
//        audioPlayer?.stop()
//        
//        // Try to find the sound file
//        guard let url = findSoundFile(fileName: fileName, fileExtension: fileExtension) else {
//            print("Could not find sound file: \(fileName).\(fileExtension)")
//            return
//        }
//        
//        do {
//            audioPlayer = try AVAudioPlayer(contentsOf: url)
//            audioPlayer?.volume = 1.0
//            audioPlayer?.prepareToPlay()
//            
//            // Create and store the delegate
//            playerDelegate = SoundPlayerDelegate {
//                DispatchQueue.main.async {
//                    self.isPlaying = false
//                }
//            }
//            
//            // Set the delegate
//            audioPlayer?.delegate = playerDelegate
//            
//            isPlaying = true
//            audioPlayer?.play()
//            
//            // Add haptic feedback
//            if #available(iOS 10.0, *) {
//                UIImpactFeedbackGenerator(style: .light).impactOccurred()
//            }
//            
//            // Auto-stop playing indicator after a reasonable time if no delegate callback
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//                if self.isPlaying {
//                    self.isPlaying = false
//                }
//            }
//            
//        } catch {
//            print("Failed to play sound: \(error)")
//            isPlaying = false
//        }
//    }
//    
//    private func findSoundFile(fileName: String, fileExtension: String) -> URL? {
//        // Try the exact filename first
//        if let url = Bundle.main.url(forResource: fileName, withExtension: fileExtension) {
//            return url
//        }
//        
//        // Try common variations
//        let variations = [
//            fileName.lowercased(),
//            fileName.uppercased(),
//            fileName.capitalized,
//            fileName.replacingOccurrences(of: " ", with: ""),
//            fileName.replacingOccurrences(of: " ", with: "_"),
//            fileName.replacingOccurrences(of: " ", with: "-")
//        ]
//        
//        let extensions = [fileExtension, "wav", "mp3", "aiff", "m4a"]
//        
//        for name in variations {
//            for ext in extensions {
//                if let url = Bundle.main.url(forResource: name, withExtension: ext) {
//                    print("✅ Found sound file: \(name).\(ext)")
//                    return url
//                }
//            }
//        }
//        
//        print("❌ Could not find sound file with any variation of: \(fileName).\(fileExtension)")
//        return nil
//    }
//}
//
//// MARK: - Audio Player Delegate
//class SoundPlayerDelegate: NSObject, AVAudioPlayerDelegate {
//    private let onFinish: () -> Void
//    
//    init(onFinish: @escaping () -> Void) {
//        self.onFinish = onFinish
//    }
//    
//    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
//        onFinish()
//    }
//}
//
//// MARK: - Preview
//#Preview {
//    SoundsView(metronome: MetronomeEngine())
//}
