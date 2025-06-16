//import SwiftUI
//
//// MARK: - Sound Picker View
//struct SoundPickerView: View {
//    @ObservedObject var metronome: MetronomeEngine
//    @Binding var isShowingPicker: Bool
//    
//    var body: some View {
//        ZStack {
//            // Base shape with black fill matching other picker views
//            RoundedRectangle(cornerRadius: 35)
//                .fill(Color.black.opacity(0.95))
//            
//            // Outer stroke with gradient
//            RoundedRectangle(cornerRadius: 35)
//                .inset(by: 0.5)
//                .stroke(LinearGradient(
//                    gradient: Gradient(colors: [Color.white.opacity(0.2), Color.white.opacity(0.15)]),
//                    startPoint: .top,
//                    endPoint: .bottomTrailing)
//                )
//            
//            VStack(spacing: 25) {
//                headerView
//                currentSoundDisplay
//                soundOptionsSection
//            }
//            .padding(30)
//        }
//        .frame(width: 360, height: 500)
//        .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
//    }
//    
//    private var headerView: some View {
//        HStack {
//            Spacer()
//            Text("METRONOME SOUNDS")
//                .font(.system(size: 12))
//                .kerning(1.5)
//                .foregroundColor(Color.white.opacity(0.4))
//            Spacer()
//            Button(action: {
//                if #available(iOS 10.0, *) {
//                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
//                }
//                isShowingPicker = false
//            }) {
//                Image(systemName: "xmark.circle.fill")
//                    .foregroundColor(Color.white.opacity(0.6))
//                    .font(.system(size: 20, weight: .medium))
//            }
//        }
//    }
//    
//    private var currentSoundDisplay: some View {
//        VStack(spacing: 8) {
//            Text(metronome.selectedSoundType.rawValue)
//                .font(.custom("Kanit-SemiBold", size: 24))
//                .kerning(1)
//                .foregroundColor(Color.white.opacity(0.8))
//                .shadow(color: Color.white.opacity(0.1), radius: 0.5, x: 0, y: 0)
//                .frame(height: 40)
//                .frame(minWidth: 250)
//                .background(
//                    RoundedRectangle(cornerRadius: 20)
//                        .fill(Color.black.opacity(0.4))
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 20)
//                                .stroke(Color.white.opacity(0.15), lineWidth: 1)
//                        )
//                )
//            
//            Text(metronome.selectedSoundType.description)
//                .font(.system(size: 12))
//                .kerning(0.5)
//                .foregroundColor(Color.white.opacity(0.6))
//                .multilineTextAlignment(.center)
//        }
//    }
//    
//    private var soundOptionsSection: some View {
//        VStack(spacing: 15) {
//            Text("CHOOSE SOUND")
//                .font(.system(size: 10))
//                .kerning(1.2)
//                .foregroundColor(Color.white.opacity(0.4))
//            
//            ScrollView {
//                VStack(spacing: 12) {
//                    ForEach(SyntheticSound.allCases, id: \.self) { sound in
//                        soundButton(sound: sound)
//                    }
//                }
//            }
//            .frame(maxHeight: 250)
//        }
//    }
//    
//    private func soundButton(sound: SyntheticSound) -> some View {
//        let isSelected = sound == metronome.selectedSoundType
//        
//        return Button(action: {
//            if #available(iOS 10.0, *) {
//                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
//            }
//            
//            // Update the selected sound
//            metronome.updateSoundType(to: sound)
//            
//            // Play preview if metronome is not currently playing
//            if !metronome.isPlaying {
//                metronome.playSoundPreview(sound)
//            }
//        }) {
//            HStack(spacing: 16) {
//                // Sound icon based on type
//                Image(systemName: soundIcon(for: sound))
//                    .font(.system(size: 20))
//                    .foregroundColor(isSelected ? Color.white.opacity(0.9) : Color.white.opacity(0.6))
//                    .frame(width: 30, alignment: .center)
//                
//                // Sound info
//                VStack(alignment: .leading, spacing: 4) {
//                    Text(sound.rawValue)
//                        .font(.system(size: 16))
//                        .kerning(0.5)
//                        .foregroundColor(isSelected ? Color.white.opacity(0.9) : Color.white.opacity(0.7))
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                    
//                    Text(sound.description)
//                        .font(.system(size: 12))
//                        .foregroundColor(isSelected ? Color.white.opacity(0.6) : Color.white.opacity(0.4))
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                }
//                
//                Spacer()
//                
//                HStack(spacing: 8) {
//                    // Preview button
//                    Button(action: {
//                        if !metronome.isPlaying {
//                            metronome.playSoundPreview(sound)
//                        }
//                    }) {
//                        Image(systemName: "play.circle")
//                            .font(.system(size: 18, weight: .medium))
//                            .foregroundColor(Color.white.opacity(0.6))
//                    }
//                    .disabled(metronome.isPlaying)
//                    
//                    if isSelected {
//                        Image(systemName: "checkmark.circle.fill")
//                            .font(.system(size: 20, weight: .medium))
//                            .foregroundColor(Color.white.opacity(0.8))
//                    }
//                }
//            }
//            .padding(.horizontal, 20)
//            .padding(.vertical, 16)
//            .background(
//                RoundedRectangle(cornerRadius: 16)
//                    .fill(isSelected ? Color.white.opacity(0.15) : Color.white.opacity(0.05))
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 16)
//                            .stroke(
//                                isSelected ? Color.white.opacity(0.25) : Color.white.opacity(0.1),
//                                lineWidth: 1
//                            )
//                    )
//            )
//        }
//    }
//    
//    private func soundIcon(for sound: SyntheticSound) -> String {
//        switch sound {
//        case .click:
//            return "waveform.path"
//        case .snap:
//            return "hand.point.up"
//        case .beep:
//            return "speaker.wave.2"
//        case .blip:
//            return "dot.radiowaves.left.and.right"
//        }
//    }
//}
//
//// MARK: - Preview
//#Preview {
//    ZStack {
//        BackgroundView()
//        SoundPickerView(
//            metronome: MetronomeEngine(),
//            isShowingPicker: .constant(true)
//        )
//    }
//}
