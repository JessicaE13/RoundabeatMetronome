import SwiftUI

struct TimeSignatureView: View {
    @ObservedObject var metronome: MetronomeEngine
    @Binding var showTimeSignaturePicker: Bool
    @Binding var showSettings: Bool
    
    var body: some View {
        ZStack {
            HStack(spacing: 32) {
                // Time Signature Section
                VStack(spacing: 4) {
                    Button(action: {
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                        showTimeSignaturePicker = true
                    }) {
                        HStack(spacing: 2) {
                            Text("TIME")
                                .font(.system(size: 9, weight: .medium))
                                .kerning(1.5)
                                .foregroundColor(Color.white.opacity(0.4))
                            
                            Text("\(metronome.beatsPerMeasure)")
                                .font(.custom("Kanit-Regular", size: 16))
                                .kerning(1.0)
                                .foregroundColor(Color.white.opacity(0.9))
                            
                            Text("/")
                                .font(.custom("Kanit-Regular", size: 16))
                                .kerning(1.0)
                                .foregroundColor(Color.white.opacity(0.7))
                            
                            Text("\(metronome.beatUnit)")
                                .font(.custom("Kanit-Regular", size: 16))
                                .kerning(1.0)
                                .foregroundColor(Color.white.opacity(0.9))
                        }
                        .frame(width: 100, height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.black.opacity(0.4))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                                )
                        )
                    }
                    .contentShape(Rectangle())
                }
                
                // Rhythm Section
                VStack(spacing: 4) {
                    Button(action: {
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                        // Add rhythm selection logic here
                    }) {
                        HStack(spacing: 8) {
                            Text("RHYTHM")
                                .font(.system(size: 9, weight: .medium))
                                .kerning(1.5)
                                .foregroundColor(Color.white.opacity(0.4))
                            
                            Image(systemName: "music.note")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color.white.opacity(0.9))
                        }
                        .frame(width: 100, height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.black.opacity(0.4))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                                )
                        )
                    }
                    .contentShape(Rectangle())
                }
            }
        }
    }
}

#Preview {
    ZStack {
        BackgroundView()
        TimeSignatureView(
            metronome: MetronomeEngine(),
            showTimeSignaturePicker: .constant(false),
            showSettings: .constant(false)
        )
    }
}
