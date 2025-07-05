import SwiftUI

// MARK: - Sounds View
struct SoundsView: View {
    @ObservedObject var metronome: MetronomeEngine
    @State private var isPreviewPlaying = false
    @State private var searchText = ""
    @State private var sortOption: LibrarySortOption = .none
    @State private var filterOption: LibraryFilterOption = .all
    
    var filteredAndSortedSounds: [SyntheticSound] {
        let filtered: [SyntheticSound]
        if searchText.isEmpty {
            filtered = SyntheticSound.allCases
        } else {
            filtered = SyntheticSound.allCases.filter { sound in
                sound.rawValue.localizedCaseInsensitiveContains(searchText) ||
                sound.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        let filteredByOption: [SyntheticSound]
        switch filterOption {
        case .all:
            filteredByOption = filtered
        case .favorites:
            // For sounds, we could potentially filter by user preferences if implemented
            // For now, this will just show all sounds
            filteredByOption = filtered
        case .applied:
            // Show only the currently selected sound
            filteredByOption = filtered.filter { $0 == metronome.selectedSoundType }
        }
        
        switch sortOption {
        case .none:
            return filteredByOption
        case .aToZ:
            return filteredByOption.sorted { $0.rawValue.localizedCaseInsensitiveCompare($1.rawValue) == .orderedAscending }
        case .zToA:
            return filteredByOption.sorted { $0.rawValue.localizedCaseInsensitiveCompare($1.rawValue) == .orderedDescending }
        }
    }
    
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
        NavigationView {
            VStack(spacing: 0) {
                // Search Section with embedded icons (matching LibraryView style)
                VStack(spacing: 0) {
                    HStack {
                        // Search bar with embedded icons
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.secondary)
                                .font(.system(size: 16))
                            
                            TextField("Search sounds...", text: $searchText)
                                .textFieldStyle(.plain)
                            
                            Spacer()
                            
                            // Sort button inside search bar
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    sortOption = sortOption.nextOption
                                }
                            }) {
                                Image(systemName: sortOption.iconName)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(sortOption == .none ? .secondary : .accentColor)
                            }
                            .buttonStyle(.plain)
                            
                            // Filter button inside search bar
                            Menu {
                                ForEach(LibraryFilterOption.allCases, id: \.self) { option in
                                    Button(action: {
                                        filterOption = option
                                    }) {
                                        HStack {
                                            Text(option.rawValue)
                                            if filterOption == option {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                            } label: {
                                Image(systemName: filterOption.iconName)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(filterOption == .all ? .secondary : .accentColor)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(.systemGray6))
                        )
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 12)
                    
                    Divider()
                        .background(Color.white.opacity(0.2))
                }
                .background(Color(.systemBackground))
                
                // Scrollable content
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        // Current Sound Section
                        VStack(alignment: .leading, spacing: settingsSectionSpacing) {
                            Text("Current Sound")
                                .font(.system(size: sectionHeaderFontSize, weight: .bold))
                                .padding(.bottom, settingsItemSpacing)
                            
                            currentSoundCard
                        }
                        .padding(.top, sectionPadding)
                        .padding(.bottom, sectionSpacing)
                        
                        Divider()
                            .padding(.bottom, sectionSpacing)
                        
                        // Available Sounds Section
                        VStack(alignment: .leading, spacing: settingsSectionSpacing) {
                            Text("\(filteredAndSortedSounds.count) sound\(filteredAndSortedSounds.count == 1 ? "" : "s")")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                                .padding(.bottom, 8)
                            
                            LazyVStack(spacing: soundItemSpacing) {
                                ForEach(filteredAndSortedSounds, id: \.self) { sound in
                                    soundRowView(sound: sound)
                                }
                            }
                        }
                        
                        // Add extra padding at the bottom
                        Spacer()
                            .frame(height: isIPad ? 100 : 80)
                    }
                    .padding(.horizontal, horizontalPadding)
                }
                
                // Fixed "Currently Applied" section at bottom - Always visible
                VStack(spacing: 0) {
                    Divider()
                        .background(Color.white.opacity(0.2))
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Currently Applied")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        CurrentlyAppliedSoundView(
                            sound: metronome.selectedSoundType,
                            metronome: metronome,
                            isPreviewPlaying: $isPreviewPlaying,
                            playPreview: { sound in
                                playPreview(sound)
                            }
                        )
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(.systemBackground))
                }
            }
            .navigationTitle("Sounds")
            .navigationBarTitleDisplayMode(.large)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private var currentSoundCard: some View {
        HStack(spacing: 16) {
            // Sound icon
            Image(systemName: soundIcon(for: metronome.selectedSoundType))
                .font(.system(size: isIPad ? 32 : 28, weight: .medium))
                .foregroundColor(.accentColor)
                .frame(width: isIPad ? 50 : 44, height: isIPad ? 50 : 44)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.accentColor.opacity(0.1))
                )
            
            // Sound info
            VStack(alignment: .leading, spacing: 4) {
                Text(metronome.selectedSoundType.rawValue)
                    .font(.system(size: currentSoundTitleSize, weight: .semibold))
                    .foregroundColor(.primary)
                
                
                HStack {
                    Text(metronome.selectedSoundType.description)
                        .font(.system(size: currentSoundDescSize))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                    
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
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(isPreviewPlaying ? Color.green.opacity(0.1) : Color.accentColor.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(isPreviewPlaying ? Color.green.opacity(0.3) : Color.accentColor.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
                .disabled(isPreviewPlaying)
                    
                }
            }
        }
        .padding(cardPadding)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.accentColor.opacity(0.2), lineWidth: 1.5)
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
            
            // Only play preview if metronome is NOT playing
            if !metronome.isPlaying {
                playPreview(sound)
            }
        }) {
            HStack(spacing: 16) {
                // Sound icon
                Image(systemName: soundIcon(for: sound))
                    .font(.system(size: soundIconSize, weight: .medium))
                    .foregroundColor(isSelected ? .black : .accentColor)
                    .frame(width: soundIconFrameSize, height: soundIconFrameSize)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
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
                    // Preview button - only show if not selected AND metronome is not playing
                    if !isSelected && !metronome.isPlaying {
                        Button(action: {
                            playPreview(sound)
                        }) {
                            Image(systemName: "play.circle")
                                .font(.system(size: actionButtonSize, weight: .medium))
                                .foregroundColor(.accentColor)
                        }
                        .disabled(isPreviewPlaying)
                    }
                    
                    // Show a different icon when metronome is playing to indicate preview is disabled
                    if !isSelected && metronome.isPlaying {
                        Image(systemName: "speaker.slash.circle")
                            .font(.system(size: actionButtonSize, weight: .medium))
                            .foregroundColor(.secondary)
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
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6).opacity(isSelected ? 1.0 : 0.5))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isSelected ? Color.accentColor.opacity(0.3) : Color.clear,
                                lineWidth: 1
                            )
                    )
            )
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? Color(.systemGray6) : Color.clear)
                .padding(.horizontal, 16)
        )
    }
    
    // MARK: - Helper Methods
    
    private func playPreview(_ sound: SyntheticSound) {
        guard !isPreviewPlaying else { return }
        
        isPreviewPlaying = true
        metronome.playSoundPreviewAdvanced(sound)
        
        // Reset preview state after a reasonable duration
        let previewDuration = sound == .snap ? 0.25 : 0.25
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
    
    // MARK: - Responsive Properties (Same as original SoundsView)
    
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

// MARK: - Currently Applied Sound View
struct CurrentlyAppliedSoundView: View {
    let sound: SyntheticSound
    @ObservedObject var metronome: MetronomeEngine
    @Binding var isPreviewPlaying: Bool
    let playPreview: (SyntheticSound) -> Void
    
    var body: some View {
        HStack {
            // Sound icon
            Image(systemName: soundIcon(for: sound))
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 30, height: 30)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.15))
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(sound.rawValue)
                    .font(.body)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                Text(sound.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Preview button
            Button(action: {
                playPreview(sound)
            }) {
                Image(systemName: isPreviewPlaying ? "waveform" : "play.circle.fill")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.accentColor)
            }
            .buttonStyle(.plain)
            .disabled(isPreviewPlaying || metronome.isPlaying)
        }
        .padding(.vertical, 12)
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
}

#Preview {
    SoundsView(metronome: MetronomeEngine())
}
