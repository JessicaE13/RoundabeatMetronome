import SwiftUI
import AVFoundation

// MARK: - Sound Option Model (unchanged)
struct SoundOption: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let fileName: String
    let fileExtension: String
    let category: SoundCategory
    let description: String
    
    var displayName: String {
        return name
    }
    
    static func == (lhs: SoundOption, rhs: SoundOption) -> Bool {
        return lhs.fileName == rhs.fileName && lhs.fileExtension == rhs.fileExtension
    }
}

// MARK: - Sound Categories (unchanged)
enum SoundCategory: String, CaseIterable {
    case percussion = "Percussion"
    case electronic = "Electronic"
    case acoustic = "Acoustic"
    case classic = "Classic"
    
    var icon: String {
        switch self {
        case .percussion: return "drum"
        case .electronic: return "waveform"
        case .acoustic: return "music.note"
        case .classic: return "metronome"
        }
    }
}

// MARK: - Adaptive Sounds View
struct SoundsView: View {
    @ObservedObject var metronome: MetronomeEngine
    @State private var selectedSound: SoundOption = SoundsView.defaultSounds[0]
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isPlaying = false
    @State private var selectedCategory: SoundCategory? = nil
    @State private var playerDelegate: SoundPlayerDelegate?
    
    // Available sound options (same as before)
    static let defaultSounds: [SoundOption] = [
        // Percussion
        SoundOption(name: "Wood Block", fileName: "Wood Block", fileExtension: "wav", category: .percussion, description: "Classic wooden metronome sound"),
        SoundOption(name: "Bongo", fileName: "bongo", fileExtension: "wav", category: .percussion, description: "Warm bongo drum hit"),
        SoundOption(name: "Snap", fileName: "Snap", fileExtension: "wav", category: .percussion, description: "Crisp finger snap"),
        SoundOption(name: "Clap", fileName: "clap", fileExtension: "wav", category: .percussion, description: "Hand clap sound"),
        SoundOption(name: "Cowbell", fileName: "cowbell", fileExtension: "wav", category: .percussion, description: "Classic cowbell ring"),
        
        // Electronic
        SoundOption(name: "Digital Beep", fileName: "Digital Beep", fileExtension: "wav", category: .electronic, description: "Clean digital beep"),
        SoundOption(name: "Synth Click", fileName: "Synth Click", fileExtension: "wav", category: .electronic, description: "Electronic click sound"),
        SoundOption(name: "Blip", fileName: "Blip", fileExtension: "wav", category: .electronic, description: "Short electronic blip"),
        
        // Acoustic
        SoundOption(name: "Piano Note", fileName: "Piano Note", fileExtension: "wav", category: .acoustic, description: "Single piano note"),
        SoundOption(name: "Guitar Pick", fileName: "Guitar Pick", fileExtension: "wav", category: .acoustic, description: "Guitar string pick"),
        
        // Classic
        SoundOption(name: "Classic Tick", fileName: "Classic Tick", fileExtension: "wav", category: .classic, description: "Traditional metronome tick"),
        SoundOption(name: "Mechanical Click", fileName: "Mechanical Click", fileExtension: "wav", category: .classic, description: "Mechanical metronome click")
    ]
    
    var filteredSounds: [SoundOption] {
        if let category = selectedCategory {
            return SoundsView.defaultSounds.filter { $0.category == category }
        }
        return SoundsView.defaultSounds
    }
    
    var body: some View {
        GeometryReader { geometry in
            let isIPad = UIDevice.current.isIPad
            let contentMaxWidth: CGFloat? = isIPad ? min(700, geometry.size.width * 0.8) : nil
            let horizontalPadding: CGFloat = isIPad ? max(40, geometry.size.width * 0.1) : 20
            
            ZStack {
                BackgroundView()
                
                ScrollView {
                    VStack(spacing: 0) {
                        // Header
                        headerView(isIPad: isIPad)
                            .padding(.top, geometry.safeAreaInsets.top + (isIPad ? 40 : 24))
                        
                        // Category Filter
                        categoryFilterView(isIPad: isIPad, horizontalPadding: horizontalPadding)
                        
                        // Sound List
                        soundListView(isIPad: isIPad, horizontalPadding: horizontalPadding)
                        
                        // Current Selection Info
                        currentSelectionView(isIPad: isIPad, horizontalPadding: horizontalPadding)
                        
                        // Reduced bottom spacing since MainTabView handles tab bar spacing
                        Spacer()
                            .frame(height: isIPad ? 30 : 20)
                    }
                    .frame(maxWidth: contentMaxWidth)
                    .frame(maxWidth: .infinity) // Center the content
                    .frame(minHeight: geometry.size.height)
                }
            }
        }
        .ignoresSafeArea(.all, edges: [.top, .leading, .trailing]) // Don't ignore bottom for tab bar
        .onAppear {
            setupAudioSession()
            // Initialize selectedSound based on metronome's current sound
            if let currentSound = SoundsView.defaultSounds.first(where: { $0.name == metronome.selectedSoundName }) {
                selectedSound = currentSound
            }
        }
    }
    
    private func headerView(isIPad: Bool) -> some View {
        VStack(spacing: isIPad ? 12 : 8) {
            Text("METRONOME SOUNDS")
                .font(.system(size: isIPad ? 16 : 12, weight: .medium))
                .kerning(1.5)
                .foregroundColor(Color.white.opacity(0.4))
                .padding(.top, isIPad ? 20 : 12)
            
            Text("Choose Your Beat")
                .font(.system(size: isIPad ? 18 : 12, weight: .medium))
                .kerning(1)
                .foregroundColor(Color.white.opacity(0.9))
                .padding(.bottom, isIPad ? 20 : 12)
        }
    }
    
    private func categoryFilterView(isIPad: Bool, horizontalPadding: CGFloat) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: isIPad ? 16 : 12) {
                // All category button
                categoryButton(category: nil, title: "All", isIPad: isIPad)
                
                ForEach(SoundCategory.allCases, id: \.self) { category in
                    categoryButton(category: category, title: category.rawValue, isIPad: isIPad)
                }
            }
            .padding(.horizontal, horizontalPadding)
        }
        .padding(.bottom, isIPad ? 24 : 16)
    }
    
    private func categoryButton(category: SoundCategory?, title: String, isIPad: Bool) -> some View {
        let isSelected = selectedCategory == category
        
        return Button(action: {
            selectedCategory = category
            
            if #available(iOS 10.0, *) {
                UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: 0.5)
            }
        }) {
            HStack(spacing: isIPad ? 8 : 6) {
                if let category = category {
                    Image(systemName: category.icon)
                        .font(.system(size: isIPad ? 16 : 12, weight: .medium))
                } else {
                    Image(systemName: "music.note.list")
                        .font(.system(size: isIPad ? 16 : 12, weight: .medium))
                }
                
                Text(title)
                    .font(.system(size: isIPad ? 16 : 12))
                    .kerning(0.5)
            }
            .foregroundColor(isSelected ? Color.white.opacity(0.9) : Color.white.opacity(0.6))
            .padding(.horizontal, isIPad ? 20 : 16)
            .padding(.vertical, isIPad ? 12 : 8)
            .background(
                RoundedRectangle(cornerRadius: isIPad ? 25 : 20)
                    .fill(isSelected ? Color.white.opacity(0.15) : Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: isIPad ? 25 : 20)
                            .stroke(
                                isSelected ? Color.white.opacity(0.25) : Color.white.opacity(0.1),
                                lineWidth: 1
                            )
                    )
            )
        }
    }
    
    private func soundListView(isIPad: Bool, horizontalPadding: CGFloat) -> some View {
        LazyVStack(spacing: isIPad ? 16 : 12) {
            ForEach(filteredSounds) { sound in
                soundRowView(sound: sound, isIPad: isIPad)
            }
        }
        .padding(.horizontal, horizontalPadding)
        .padding(.bottom, isIPad ? 24 : 16)
    }
    
    private func soundRowView(sound: SoundOption, isIPad: Bool) -> some View {
        // Check if this sound is the currently selected metronome sound
        let isSelected = sound.name == metronome.selectedSoundName
        let isCurrentlyPlaying = isPlaying && selectedSound == sound
        
        return Button(action: {
            // Update the metronome's sound selection
            metronome.updateSoundSelection(to: sound.name)
            selectedSound = sound
            
            // Only play preview if metronome is NOT currently playing
            if !metronome.isPlaying {
                playSound(sound)
            } else {
                // If metronome is playing, just provide haptic feedback
                if #available(iOS 10.0, *) {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }
                print("🔊 Sound updated to '\(sound.name)' - preview skipped (metronome playing)")
            }
        }) {
            HStack(spacing: isIPad ? 20 : 16) {
                // Sound category icon
                Image(systemName: sound.category.icon)
                    .font(.system(size: isIPad ? 24 : 18, weight: .medium))
                    .foregroundColor(isSelected ? Color.white.opacity(0.9) : Color.white.opacity(0.5))
                    .frame(width: isIPad ? 32 : 24, height: isIPad ? 32 : 24)
                
                // Sound info
                VStack(alignment: .leading, spacing: isIPad ? 6 : 4) {
                    Text(sound.displayName)
                        .font(.system(size: isIPad ? 20 : 16))
                        .kerning(0.5)
                        .foregroundColor(isSelected ? Color.white.opacity(0.9) : Color.white.opacity(0.7))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(sound.description)
                        .font(.system(size: isIPad ? 16 : 12))
                        .foregroundColor(isSelected ? Color.white.opacity(0.6) : Color.white.opacity(0.4))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Spacer()
                
                // Play/Playing indicator - show different states based on metronome
                HStack(spacing: isIPad ? 12 : 8) {
                    if metronome.isPlaying && isSelected {
                        // Show that this sound is actively being used by the metronome
                        HStack(spacing: isIPad ? 3 : 2) {
                            ForEach(0..<3) { index in
                                Rectangle()
                                    .fill(Color.green.opacity(0.8))
                                    .frame(width: isIPad ? 4 : 3, height: isIPad ? 16 : 12)
                                    .scaleEffect(y: 1.0)
                                    .animation(
                                        Animation.easeInOut(duration: 0.5)
                                            .repeatForever()
                                            .delay(Double(index) * 0.1),
                                        value: true
                                    )
                            }
                        }
                        .frame(width: isIPad ? 28 : 20, height: isIPad ? 28 : 20)
                    } else if isCurrentlyPlaying && !metronome.isPlaying {
                        // Show preview playing indicator (only when metronome is not playing)
                        HStack(spacing: isIPad ? 3 : 2) {
                            ForEach(0..<3) { index in
                                Rectangle()
                                    .fill(Color.white.opacity(0.8))
                                    .frame(width: isIPad ? 4 : 3, height: isIPad ? 16 : 12)
                                    .scaleEffect(y: isCurrentlyPlaying ? 1.0 : 0.3)
                                    .animation(
                                        Animation.easeInOut(duration: 0.5)
                                            .repeatForever()
                                            .delay(Double(index) * 0.1),
                                        value: isCurrentlyPlaying
                                    )
                            }
                        }
                        .frame(width: isIPad ? 28 : 20, height: isIPad ? 28 : 20)
                    } else {
                        // Show play button
                        Image(systemName: metronome.isPlaying ? "waveform" : "play.circle")
                            .font(.system(size: isIPad ? 28 : 20, weight: .medium))
                            .foregroundColor(metronome.isPlaying && isSelected ? Color.green.opacity(0.8) : Color.white.opacity(0.6))
                    }
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: isIPad ? 28 : 20, weight: .medium))
                            .foregroundColor(metronome.isPlaying ? Color.green.opacity(0.8) : Color.white.opacity(0.8))
                    }
                }
            }
            .padding(.horizontal, isIPad ? 24 : 20)
            .padding(.vertical, isIPad ? 20 : 16)
            .background(
                RoundedRectangle(cornerRadius: isIPad ? 20 : 16)
                    .fill(isSelected ? Color.white.opacity(0.1) : Color.black.opacity(0.2))
                    .overlay(
                        RoundedRectangle(cornerRadius: isIPad ? 20 : 16)
                            .stroke(
                                isSelected ? Color.white.opacity(0.2) : Color.white.opacity(0.05),
                                lineWidth: 1
                            )
                    )
            )
        }
        .scaleEffect(isCurrentlyPlaying ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isCurrentlyPlaying)
    }
    
    private func currentSelectionView(isIPad: Bool, horizontalPadding: CGFloat) -> some View {
        VStack(spacing: isIPad ? 16 : 12) {
            Rectangle()
                .fill(Color.white.opacity(0.1))
                .frame(height: 1)
                .padding(.horizontal, horizontalPadding)
            
            HStack(spacing: isIPad ? 20 : 16) {
                VStack(alignment: .leading, spacing: isIPad ? 6 : 4) {
                    Text("CURRENT SOUND")
                        .font(.system(size: isIPad ? 14 : 10, weight: .medium))
                        .kerning(1)
                        .foregroundColor(Color.white.opacity(0.4))
                    
                    Text(metronome.selectedSoundName)
                        .font(.system(size: isIPad ? 20 : 16))
                        .kerning(0.5)
                        .foregroundColor(Color.white.opacity(0.9))
                }
                
                Spacer()
                
                Button(action: {
                    // Only preview if metronome is not playing
                    if !metronome.isPlaying {
                        if let currentSound = SoundsView.defaultSounds.first(where: { $0.name == metronome.selectedSoundName }) {
                            playSound(currentSound)
                        }
                    } else {
                        // Provide feedback that preview is disabled during playback
                        if #available(iOS 10.0, *) {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        }
                    }
                }) {
                    HStack(spacing: isIPad ? 12 : 8) {
                        Image(systemName: metronome.isPlaying ? "waveform" : "play.fill")
                            .font(.system(size: isIPad ? 18 : 14, weight: .medium))
                        
                        Text(metronome.isPlaying ? "PLAYING" : "PREVIEW")
                            .font(.system(size: isIPad ? 16 : 12))
                            .kerning(0.5)
                    }
                    .foregroundColor(metronome.isPlaying ? Color.green.opacity(0.9) : Color.white.opacity(0.9))
                    .padding(.horizontal, isIPad ? 20 : 16)
                    .padding(.vertical, isIPad ? 14 : 10)
                    .background(
                        RoundedRectangle(cornerRadius: isIPad ? 25 : 20)
                            .fill(metronome.isPlaying ? Color.green.opacity(0.15) : Color.white.opacity(0.15))
                            .overlay(
                                RoundedRectangle(cornerRadius: isIPad ? 25 : 20)
                                    .stroke(metronome.isPlaying ? Color.green.opacity(0.25) : Color.white.opacity(0.25), lineWidth: 1)
                            )
                    )
                }
                .disabled(metronome.isPlaying) // Disable the button when metronome is playing
            }
            .padding(.horizontal, horizontalPadding)
            .padding(.bottom, isIPad ? 20 : 12)
        }
    }
    
    // MARK: - Audio Functions
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    private func playSound(_ sound: SoundOption) {
        // Stop any currently playing sound
        audioPlayer?.stop()
        
        // Try to find the sound file
        guard let url = findSoundFile(sound) else {
            print("Could not find sound file: \(sound.fileName).\(sound.fileExtension)")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.volume = 1.0
            audioPlayer?.prepareToPlay()
            
            // Create and store the delegate
            playerDelegate = SoundPlayerDelegate {
                DispatchQueue.main.async {
                    self.isPlaying = false
                }
            }
            
            // Set the delegate
            audioPlayer?.delegate = playerDelegate
            
            isPlaying = true
            audioPlayer?.play()
            
            // Add haptic feedback
            if #available(iOS 10.0, *) {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
            
            // Auto-stop playing indicator after a reasonable time if no delegate callback
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                if self.isPlaying {
                    self.isPlaying = false
                }
            }
            
        } catch {
            print("Failed to play sound: \(error)")
            isPlaying = false
        }
    }
    
    private func findSoundFile(_ sound: SoundOption) -> URL? {
        // Try the exact filename first
        if let url = Bundle.main.url(forResource: sound.fileName, withExtension: sound.fileExtension) {
            return url
        }
        
        // Try common variations
        let variations = [
            sound.fileName.lowercased(),
            sound.fileName.uppercased(),
            sound.fileName.capitalized
        ]
        
        let extensions = [sound.fileExtension, "wav", "mp3", "aiff", "m4a"]
        
        for name in variations {
            for ext in extensions {
                if let url = Bundle.main.url(forResource: name, withExtension: ext) {
                    return url
                }
            }
        }
        
        return nil
    }
}

// MARK: - Audio Player Delegate
class SoundPlayerDelegate: NSObject, AVAudioPlayerDelegate {
    private let onFinish: () -> Void
    
    init(onFinish: @escaping () -> Void) {
        self.onFinish = onFinish
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        onFinish()
    }
}

// MARK: - Preview
#Preview {
    SoundsView(metronome: MetronomeEngine())
}
