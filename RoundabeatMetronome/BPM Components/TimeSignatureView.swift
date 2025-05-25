
import SwiftUI

struct TimeSignatureView: View {
    @ObservedObject var metronome: MetronomeEngine
    @Binding var showTimeSignaturePicker: Bool
    @Binding var showSettings: Bool
    
    var body: some View {
            
            HStack {
                // Time Signature
                Text("TIME:")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Color.white.opacity(0.6))
                
                Button(action: {
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                    showTimeSignaturePicker = true
                }) {
                    HStack(spacing: 2) {
                        Text("\(metronome.beatsPerMeasure)")
                            .font(.custom("Kanit-SemiBold", size: 16))
                            .foregroundColor(Color.white.opacity(0.8))
                        
                        Text("/")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color.white.opacity(0.8))
                        
                        Text("\(metronome.beatUnit)")
                            .font(.custom("Kanit-SemiBold", size: 16))
                            .foregroundColor(Color.white.opacity(0.8))
                    }
                }
                
                Text("   RHYTHM:")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Color.white.opacity(0.6))
                
                Image(systemName: "music.note")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.8))

            }
        }
    }


#Preview {
    ZStack{
        BackgroundView()
        TimeSignatureView(
            metronome: MetronomeEngine(),
            showTimeSignaturePicker: .constant(false),
            showSettings: .constant(false)
        )
        .overlay(
                    Rectangle()
                        .stroke(Color.red, lineWidth: 1)
                )
    }
}
