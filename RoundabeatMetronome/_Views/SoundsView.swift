import SwiftUI

// MARK: - Sounds View
struct SoundsView: View {
    @ObservedObject var metronome: MetronomeEngine
    @State private var isPreviewPlaying = false
    
    // Get screen dimensions directly
    private var screenWidth: CGFloat {
        UIScreen.main.bounds.width
    }
    
    private var screenHeight: CGFloat {
        UIScreen.main.bounds.height
    }
    
    // Check if device is iPad
    private var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Sounds Title
                Text("Sounds")
                    .font(.system(size: titleFontSize, weight: .bold, design: .default))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, sectionPadding)
                    .padding(.bottom, sectionPadding)
                
                // Current Sound Section
                VStack(alignment: .leading, spacing: settingsSectionSpacing) {
                    Text("Current Sound")
                        .font(.system(size: sectionHeaderFontSize, weight: .bold))
                        .padding(.bottom, settingsItemSpacing)
                    
                    currentSoundCard
                }
                .padding(.bottom, sectionSpacing)
                
                Divider()
                    .padding(.bottom, sectionSpacing)
                
                // Available Sounds Section
                VStack(alignment: .leading, spacing: settingsSectionSpacing) {
                    Text("Available Sounds")
                        .font(.system(size: sectionHeaderFontSize, weight: .bold))
                        .padding(.bottom, settingsItemSpacing)
                    
                    LazyVStack(spacing: soundItemSpacing) {
                        ForEach(SyntheticSound.allCases, id: \.self) { sound in
                            soundRowView(sound: sound)
                        }
                    }
                }
                
                // Add extra padding at the bottom to account for the navigation bar
                Spacer()
                    .frame(height: isIPad ? 100 : 80)
            }
            .padding(.horizontal, horizontalPadding)
        }
    }
    
    private var currentSoundCard: some View {
        HStack(spacing: 16) {
            // Sound icon
            Image(systemName: soundIcon(for: metronome.selectedSoundType))
                .font(.system(size: isIPad ? 32 : 28, weight: .medium))
                .foregroundColor(.accentColor)
                .frame(width: isIPad ? 50 : 44, height: isIPad ? 50 : 44)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.accentColor.opacity(0.1))
                )
            
            // Sound info
            VStack(alignment: .leading, spacing: 4) {
                Text(metronome.selectedSoundType.rawValue)
                    .font(.system(size: currentSoundTitleSize, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(metronome.selectedSoundType.description)
                    .font(.system(size: currentSoundDescSize))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
            
            // Preview button
            Button(action: {
                playPreview(metronome.selectedSoundType)
            }) {
                HStack(spacing: 6) {
                    Image(systemName: isPreviewPlaying ? "waveform" : "play.fill")
                        .font(.system(size: previewButtonIconSize, weight: .medium))
                    
                    Text(isPreviewPlaying ? "PLAYING" : "PREVIEW")
                        .font(.system(size: previewButtonTextSize, weight: .medium))
                        .kerning(0.5)
                }
                .foregroundColor(isPreviewPlaying ? .green : .accentColor)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isPreviewPlaying ? Color.green.opacity(0.1) : Color.accentColor.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(isPreviewPlaying ? Color.green.opacity(0.3) : Color.accentColor.opacity(0.3), lineWidth: 1)
                        )
                )
            }
            .disabled(isPreviewPlaying)
        }
        .padding(cardPadding)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.accentColor.opacity(0.2), lineWidth: 2)
                )
        )
    }
    
    private func soundRowView(sound: SyntheticSound) -> some View {
        let isSelected = sound == metronome.selectedSoundType
        
        return Button(action: {
            if #available(iOS 10.0, *) {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            }
            
            // Update the selected sound
            metronome.updateSoundType(to: sound)
            
            // Play preview
            playPreview(sound)
        }) {
            HStack(spacing: 16) {
                // Sound icon
                Image(systemName: soundIcon(for: sound))
                    .font(.system(size: soundIconSize, weight: .medium))
                    .foregroundColor(isSelected ? .white : .accentColor)
                    .frame(width: soundIconFrameSize, height: soundIconFrameSize)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(isSelected ? Color.accentColor : Color.accentColor.opacity(0.1))
                    )
                
                // Sound info
                VStack(alignment: .leading, spacing: 4) {
                    Text(sound.rawValue)
                        .font(.system(size: soundTitleSize, weight: .medium))
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(sound.description)
                        .font(.system(size: soundDescSize))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Spacer()
                
                HStack(spacing: 8) {
                    // Preview button
                    if !isSelected {
                        Button(action: {
                            playPreview(sound)
                        }) {
                            Image(systemName: "play.circle")
                                .font(.system(size: actionButtonSize, weight: .medium))
                                .foregroundColor(.accentColor)
                        }
                        .disabled(isPreviewPlaying)
                    }
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: actionButtonSize, weight: .medium))
                            .foregroundColor(.accentColor)
                    }
                }
            }
            .padding(soundRowPadding)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6).opacity(isSelected ? 1.0 : 0.5))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isSelected ? Color.accentColor.opacity(0.3) : Color.clear,
                                lineWidth: 1
                            )
                    )
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Helper Methods
    
    private func playPreview(_ sound: SyntheticSound) {
        guard !isPreviewPlaying else { return }
        
        isPreviewPlaying = true
        metronome.playSoundPreview(sound)
        
        // Reset preview state after a reasonable duration
        let previewDuration = sound == .snap ? 0.25 : 0.2
        DispatchQueue.main.asyncAfter(deadline: .now() + previewDuration) {
            isPreviewPlaying = false
        }
    }
    
    private func soundIcon(for sound: SyntheticSound) -> String {
        switch sound {
        case .click:
            return "waveform.path"
        case .snap:
            return "hand.point.up"
        case .beep:
            return "speaker.wave.2"
        case .blip:
            return "dot.radiowaves.left.and.right"
        }
    }
    
    // MARK: - Responsive Properties
    
    private var titleFontSize: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 32 :
                   screenWidth <= 834 ? 36 :
                   screenWidth <= 1024 ? 40 :
                   44
        } else {
            return screenWidth <= 320 ? 20 :
                   screenWidth <= 375 ? 24 :
                   screenWidth <= 393 ? 28 :
                   30
        }
    }
    
    private var sectionHeaderFontSize: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 20 :
                   screenWidth <= 834 ? 22 :
                   screenWidth <= 1024 ? 24 :
                   26
        } else {
            return screenWidth <= 320 ? 16 :
                   screenWidth <= 375 ? 18 :
                   screenWidth <= 393 ? 20 :
                   22
        }
    }
    
    private var currentSoundTitleSize: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 18 :
                   screenWidth <= 834 ? 20 :
                   screenWidth <= 1024 ? 22 :
                   24
        } else {
            return screenWidth <= 320 ? 14 :
                   screenWidth <= 375 ? 16 :
                   screenWidth <= 393 ? 18 :
                   19
        }
    }
    
    private var currentSoundDescSize: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 14 :
                   screenWidth <= 834 ? 15 :
                   screenWidth <= 1024 ? 16 :
                   17
        } else {
            return screenWidth <= 320 ? 11 :
                   screenWidth <= 375 ? 12 :
                   screenWidth <= 393 ? 13 :
                   14
        }
    }
    
    private var soundTitleSize: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 16 :
                   screenWidth <= 834 ? 18 :
                   screenWidth <= 1024 ? 20 :
                   22
        } else {
            return screenWidth <= 320 ? 12 :
                   screenWidth <= 375 ? 14 :
                   screenWidth <= 393 ? 16 :
                   17
        }
    }
    
    private var soundDescSize: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 13 :
                   screenWidth <= 834 ? 14 :
                   screenWidth <= 1024 ? 15 :
                   16
        } else {
            return screenWidth <= 320 ? 10 :
                   screenWidth <= 375 ? 11 :
                   screenWidth <= 393 ? 12 :
                   13
        }
    }
    
    private var previewButtonIconSize: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 12 :
                   screenWidth <= 834 ? 13 :
                   screenWidth <= 1024 ? 14 :
                   15
        } else {
            return screenWidth <= 320 ? 10 :
                   screenWidth <= 375 ? 11 :
                   screenWidth <= 393 ? 12 :
                   13
        }
    }
    
    private var previewButtonTextSize: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 11 :
                   screenWidth <= 834 ? 12 :
                   screenWidth <= 1024 ? 13 :
                   14
        } else {
            return screenWidth <= 320 ? 9 :
                   screenWidth <= 375 ? 10 :
                   screenWidth <= 393 ? 11 :
                   12
        }
    }
    
    private var soundIconSize: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 18 :
                   screenWidth <= 834 ? 20 :
                   screenWidth <= 1024 ? 22 :
                   24
        } else {
            return screenWidth <= 320 ? 14 :
                   screenWidth <= 375 ? 16 :
                   screenWidth <= 393 ? 18 :
                   20
        }
    }
    
    private var soundIconFrameSize: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 36 :
                   screenWidth <= 834 ? 40 :
                   screenWidth <= 1024 ? 44 :
                   48
        } else {
            return screenWidth <= 320 ? 28 :
                   screenWidth <= 375 ? 32 :
                   screenWidth <= 393 ? 36 :
                   40
        }
    }
    
    private var actionButtonSize: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 20 :
                   screenWidth <= 834 ? 22 :
                   screenWidth <= 1024 ? 24 :
                   26
        } else {
            return screenWidth <= 320 ? 16 :
                   screenWidth <= 375 ? 18 :
                   screenWidth <= 393 ? 20 :
                   22
        }
    }
    
    private var sectionPadding: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 32 :
                   screenWidth <= 834 ? 40 :
                   screenWidth <= 1024 ? 48 :
                   56
        } else {
            return screenWidth <= 320 ? 12 :
                   screenWidth <= 375 ? 16 :
                   screenWidth <= 393 ? 20 :
                   22
        }
    }
    
    private var horizontalPadding: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 48 :
                   screenWidth <= 834 ? 60 :
                   screenWidth <= 1024 ? 72 :
                   84
        } else {
            return screenWidth <= 320 ? 12 :
                   screenWidth <= 375 ? 16 :
                   screenWidth <= 393 ? 20 :
                   24
        }
    }
    
    private var settingsSectionSpacing: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 20 :
                   screenWidth <= 834 ? 24 :
                   screenWidth <= 1024 ? 28 :
                   32
        } else {
            return screenWidth <= 320 ? 12 :
                   screenWidth <= 375 ? 16 :
                   screenWidth <= 393 ? 18 :
                   20
        }
    }
    
    private var settingsItemSpacing: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 14 :
                   screenWidth <= 834 ? 16 :
                   screenWidth <= 1024 ? 18 :
                   20
        } else {
            return screenWidth <= 320 ? 8 :
                   screenWidth <= 375 ? 10 :
                   screenWidth <= 393 ? 12 :
                   14
        }
    }
    
    private var sectionSpacing: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 30 :
                   screenWidth <= 834 ? 35 :
                   screenWidth <= 1024 ? 40 :
                   45
        } else {
            return screenWidth <= 320 ? 16 :
                   screenWidth <= 375 ? 20 :
                   screenWidth <= 393 ? 25 :
                   28
        }
    }
    
    private var cardPadding: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 20 :
                   screenWidth <= 834 ? 24 :
                   screenWidth <= 1024 ? 28 :
                   32
        } else {
            return screenWidth <= 320 ? 12 :
                   screenWidth <= 375 ? 16 :
                   screenWidth <= 393 ? 18 :
                   20
        }
    }
    
    private var soundRowPadding: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 16 :
                   screenWidth <= 834 ? 18 :
                   screenWidth <= 1024 ? 20 :
                   22
        } else {
            return screenWidth <= 320 ? 10 :
                   screenWidth <= 375 ? 12 :
                   screenWidth <= 393 ? 14 :
                   16
        }
    }
    
    private var soundItemSpacing: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 12 :
                   screenWidth <= 834 ? 14 :
                   screenWidth <= 1024 ? 16 :
                   18
        } else {
            return screenWidth <= 320 ? 8 :
                   screenWidth <= 375 ? 10 :
                   screenWidth <= 393 ? 12 :
                   14
        }
    }
}

#Preview {
    SoundsView(metronome: MetronomeEngine())
}
