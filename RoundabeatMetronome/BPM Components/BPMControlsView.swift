import SwiftUI

struct BPMControlsView: View {
    @ObservedObject var metronome: MetronomeEngine
    @Binding var isShowingKeypad: Bool
    @Binding var previousTempo: Double
    let adaptiveLayout: AdaptiveLayout
    
    var body: some View {
        HStack(spacing: adaptiveLayout.isIPad ? 40 : 0) {
            // Minus Button
            ZStack {
                Image(systemName: "chevron.backward")
                    .font(.system(size: adaptiveLayout.isIPad ? 24 : 18, weight: .bold))
                    .foregroundColor(Color.white.opacity(0.9))
                    .shadow(color: Color.white.opacity(0.3), radius: 0.5, x: 0, y: 0)
            }
            .frame(width: adaptiveLayout.isIPad ? 50 : 30, height: adaptiveLayout.isIPad ? 50 : 30)
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
                    .font(.custom("Kanit-SemiBold", size: adaptiveLayout.bpmFontSize))
                    .kerning(adaptiveLayout.isIPad ? 3 : 2)
                    .padding(.top, -20)
                    .padding(.bottom, -20)
                    .foregroundColor(Color.white.opacity(0.8))
                    .shadow(color: Color.white.opacity(0.1), radius: 0.5, x: 0, y: 0)
                    .monospacedDigit()
            }
            .frame(width: adaptiveLayout.isIPad ? 300 : 200, alignment: .center)
            .contentShape(Rectangle())
            .onTapGesture {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
                isShowingKeypad = true
            }
            
            // Plus Button
            ZStack {
                Image(systemName: "chevron.forward")
                    .font(.system(size: adaptiveLayout.isIPad ? 24 : 18, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.white.opacity(0.9))
                    .shadow(color: Color.white.opacity(0.3), radius: 0.5, x: 0, y: 0)
            }
            .frame(width: adaptiveLayout.isIPad ? 50 : 30, height: adaptiveLayout.isIPad ? 50 : 30)
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

// Legacy initializer for compatibility
extension BPMControlsView {
    init(metronome: MetronomeEngine, isShowingKeypad: Binding<Bool>, previousTempo: Binding<Double>) {
        self.metronome = metronome
        self._isShowingKeypad = isShowingKeypad
        self._previousTempo = previousTempo
        // Create a default layout for legacy usage
        self.adaptiveLayout = AdaptiveLayout.default
    }
}

#Preview {
    ZStack{
        BackgroundView()
        BPMControlsView(
            metronome: MetronomeEngine(),
            isShowingKeypad: .constant(false),
            previousTempo: .constant(120),
            adaptiveLayout: AdaptiveLayout.default
        )
        .overlay(
            Rectangle()
                .stroke(Color.red, lineWidth: 1)
        )
    }
}
