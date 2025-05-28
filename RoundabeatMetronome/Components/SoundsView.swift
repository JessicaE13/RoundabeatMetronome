import SwiftUI
import AVFoundation

// MARK: - Sound Option Model
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

// MARK: - Sound Categories
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

// MARK: - Sounds View
struct SoundsView: View {
    @ObservedObject var metronome: MetronomeEngine
    @State private var selectedSound: SoundOption = SoundsView.defaultSounds[0]
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isPlaying = false
    @State private var selectedCategory: SoundCategory? = nil
    @State private var playerDelegate: SoundPlayerDelegate?
    
    // Available sound options (you can expand this based on your actual sound files)
    static let defaultSounds: [SoundOption] = [
        // Percussion
        SoundOption(name: "Wood Block", fileName: "wood_block", fileExtension: "wav", category: .percussion, description: "Classic wooden metronome sound"),
        SoundOption(name: "Bongo", fileName: "bongo", fileExtension: "wav", category: .percussion, description: "Warm bongo drum hit"),
        SoundOption(name: "Snap", fileName: "Snap", fileExtension: "wav", category: .percussion, description: "Crisp finger snap"),
        SoundOption(name: "Clap", fileName: "clap", fileExtension: "wav", category: .percussion, description: "Hand clap sound"),
        SoundOption(name: "Cowbell", fileName: "cowbell", fileExtension: "wav", category: .percussion, description: "Classic cowbell ring"),
        
        // Electronic
        SoundOption(name: "Digital Beep", fileName: "beep", fileExtension: "wav", category: .electronic, description: "Clean digital beep"),
        SoundOption(name: "Synth Click", fileName: "synth_click", fileExtension: "wav", category: .electronic, description: "Electronic click sound"),
        SoundOption(name: "Blip", fileName: "blip", fileExtension: "wav", category: .electronic, description: "Short electronic blip"),
        
        // Acoustic
        SoundOption(name: "Piano Note", fileName: "piano", fileExtension: "wav", category: .acoustic, description: "Single piano note"),
        SoundOption(name: "Guitar Pick", fileName: "guitar_pick", fileExtension: "wav", category: .acoustic, description: "Guitar string pick"),
        
        // Classic
        SoundOption(name: "Classic Tick", fileName: "tick", fileExtension: "wav", category: .classic, description: "Traditional metronome tick"),
        SoundOption(name: "Mechanical Click", fileName: "click", fileExtension: "wav", category: .classic, description: "Mechanical metronome click")
    ]
    
    var filteredSounds: [SoundOption] {
        if let category = selectedCategory {
            return SoundsView.defaultSounds.filter { $0.category == category }
        }
        return SoundsView.defaultSounds
    }
    
    var body: some View {
        ZStack {
            DarkGrayBackgroundView()
            
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Category Filter
                categoryFilterView
                
                // Sound List
                soundListView
                
                // Current Selection Info
                currentSelectionView
            }
        }
        .onAppear {
            setupAudioSession()
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 8) {
            Text("METRONOME SOUNDS")
                .font(.system(size: 12, weight: .medium))
                .kerning(1.5)
                .foregroundColor(Color.white.opacity(0.4))
                .padding(.top, 20)
            
            Text("Choose Your Beat")
                .font(.custom("Kanit-SemiBold", size: 24))
                .kerning(1)
                .foregroundColor(Color.white.opacity(0.9))
                .padding(.bottom, 16)
        }
    }
    
    private var categoryFilterView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // All category button
                categoryButton(category: nil, title: "All")
                
                ForEach(SoundCategory.allCases, id: \.self) { category in
                    categoryButton(category: category, title: category.rawValue)
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 20)
    }
    
    private func categoryButton(category: SoundCategory?, title: String) -> some View {
        let isSelected = selectedCategory == category
        
        return Button(action: {
            selectedCategory = category
            
            if #available(iOS 10.0, *) {
                UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: 0.5)
            }
        }) {
            HStack(spacing: 6) {
                if let category = category {
                    Image(systemName: category.icon)
                        .font(.system(size: 12, weight: .medium))
                } else {
                    Image(systemName: "music.note.list")
                        .font(.system(size: 12, weight: .medium))
                }
                
                Text(title)
                    .font(.custom("Kanit-Medium", size: 12))
                    .kerning(0.5)
            }
            .foregroundColor(isSelected ? Color.white.opacity(0.9) : Color.white.opacity(0.6))
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? Color.white.opacity(0.15) : Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                isSelected ? Color.white.opacity(0.25) : Color.white.opacity(0.1),
                                lineWidth: 1
                            )
                    )
            )
        }
    }
    
    private var soundListView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(filteredSounds) { sound in
                    soundRowView(sound: sound)
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    private func soundRowView(sound: SoundOption) -> some View {
        let isSelected = selectedSound == sound
        let isCurrentlyPlaying = isPlaying && selectedSound == sound
        
        return Button(action: {
            selectedSound = sound
            playSound(sound)
        }) {
            HStack(spacing: 16) {
                // Sound category icon
                Image(systemName: sound.category.icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(isSelected ? Color.white.opacity(0.9) : Color.white.opacity(0.5))
                    .frame(width: 24, height: 24)
                
                // Sound info
                VStack(alignment: .leading, spacing: 4) {
                    Text(sound.displayName)
                        .font(.custom("Kanit-Medium", size: 16))
                        .kerning(0.5)
                        .foregroundColor(isSelected ? Color.white.opacity(0.9) : Color.white.opacity(0.7))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(sound.description)
                        .font(.system(size: 12))
                        .foregroundColor(isSelected ? Color.white.opacity(0.6) : Color.white.opacity(0.4))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Spacer()
                
                // Play/Playing indicator
                HStack(spacing: 8) {
                    if isCurrentlyPlaying {
                        // Animated playing indicator
                        HStack(spacing: 2) {
                            ForEach(0..<3) { index in
                                Rectangle()
                                    .fill(Color.white.opacity(0.8))
                                    .frame(width: 3, height: 12)
                                    .scaleEffect(y: isCurrentlyPlaying ? 1.0 : 0.3)
                                    .animation(
                                        Animation.easeInOut(duration: 0.5)
                                            .repeatForever()
                                            .delay(Double(index) * 0.1),
                                        value: isCurrentlyPlaying
                                    )
                            }
                        }
                        .frame(width: 20, height: 20)
                    } else {
                        Image(systemName: "play.circle")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(Color.white.opacity(0.6))
                    }
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(Color.white.opacity(0.8))
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.white.opacity(0.1) : Color.black.opacity(0.2))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
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
    
    private var currentSelectionView: some View {
        VStack(spacing: 12) {
            Rectangle()
                .fill(Color.white.opacity(0.1))
                .frame(height: 1)
                .padding(.horizontal, 20)
            
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("CURRENT SOUND")
                        .font(.system(size: 10, weight: .medium))
                        .kerning(1)
                        .foregroundColor(Color.white.opacity(0.4))
                    
                    Text(selectedSound.displayName)
                        .font(.custom("Kanit-Medium", size: 16))
                        .kerning(0.5)
                        .foregroundColor(Color.white.opacity(0.9))
                }
                
                Spacer()
                
                Button(action: {
                    playSound(selectedSound)
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 14, weight: .medium))
                        Text("PREVIEW")
                            .font(.custom("Kanit-Medium", size: 12))
                            .kerning(0.5)
                    }
                    .foregroundColor(Color.white.opacity(0.9))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.15))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white.opacity(0.25), lineWidth: 1)
                            )
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
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
                if isPlaying {
                    isPlaying = false
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
