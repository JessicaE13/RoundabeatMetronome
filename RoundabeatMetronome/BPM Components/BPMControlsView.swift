


import SwiftUI

struct BPMControlsView: View {
    @ObservedObject var metronome: MetronomeEngine
    @Binding var isShowingKeypad: Bool
    @Binding var previousTempo: Double
    
    var body: some View {
        HStack() {
            // Minus Button
            ZStack {
                Image(systemName: "chevron.backward")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color.white.opacity(0.9))
                    .shadow(color: Color.white.opacity(0.3), radius: 0.5, x: 0, y: 0)
            }
            .frame(width: 30, height: 30)
            .contentShape(Rectangle())
            .onTapGesture {
                let generator = UIImpactFeedbackGenerator(style: .soft)
                generator.impactOccurred(intensity: 0.5)
                metronome.updateTempo(to: metronome.tempo - 1)
                previousTempo = metronome.tempo
            }
            
            // BPM Number Display
            VStack {
                Text("\(Int(metronome.tempo))")
                    .font(.custom("Kanit-SemiBold", size: 90))
                    .kerning(2)
                    .padding(.bottom, -20)
                    .foregroundColor(Color.white.opacity(0.8))
                    .shadow(color: Color.white.opacity(0.1), radius: 0.5, x: 0, y: 0)
                    .monospacedDigit()
                
                Text("BEATS PER MINUTE (BPM)")
                                   .font(.system(size: 12, weight: .medium, design: .monospaced))
                                   .foregroundColor(Color.white.opacity(0.6))
                                  // .padding(.top, -80)
                                   .padding(.bottom, 16)
                                   .tracking(1)
            }
            .frame(width: 200, alignment: .center)
            .contentShape(Rectangle())
            .onTapGesture {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
                isShowingKeypad = true
            }
            
            // Plus Button
            ZStack {
                Image(systemName: "chevron.forward")
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.white.opacity(0.9))
                    .shadow(color: Color.white.opacity(0.3), radius: 0.5, x: 0, y: 0)
            }
            .frame(width: 30, height: 30)
            .contentShape(Rectangle())
            .onTapGesture {
                let generator = UIImpactFeedbackGenerator(style: .soft)
                generator.impactOccurred(intensity: 0.5)
                metronome.updateTempo(to: metronome.tempo + 1)
                previousTempo = metronome.tempo
            }
        }
    }
}

#Preview {
    ZStack{
        BackgroundView()
        BPMControlsView(
            metronome: MetronomeEngine(),
            isShowingKeypad: .constant(false),
            previousTempo: .constant(120)
        )
        .overlay(
                    Rectangle()
                        .stroke(Color.red, lineWidth: 1)
                )
    }
}
