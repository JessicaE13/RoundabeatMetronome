import SwiftUI

struct BPMControlsView: View {
    @ObservedObject var metronome: MetronomeEngine
    @Binding var isShowingKeypad: Bool
    @Binding var previousTempo: Double
    let adaptiveLayout: AdaptiveLayout
    
    var body: some View {
        HStack(spacing: adaptiveLayout.isIPad ? 40 : (UIDevice.isCompactDevice ? 12 : 20)) {
            // Minus Button
            ZStack {
                Image(systemName: "chevron.backward")
                    .font(.system(size: AdaptiveValues.chevronSize, weight: .bold))
                    .foregroundColor(Color.white.opacity(0.9))
                    .shadow(color: Color.white.opacity(0.3), radius: 0.5, x: 0, y: 0)
            }
            .frame(width: AdaptiveValues.chevronFrameSize, height: AdaptiveValues.chevronFrameSize)
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
                    .font(.custom("Kanit-SemiBold", size: AdaptiveValues.bpmFontSize))
                    .kerning(adaptiveLayout.isIPad ? 3 : (UIDevice.isCompactDevice ? 1 : 2))
                    .padding(.top, -20)
                    .padding(.bottom, -20)
                    .foregroundColor(Color.white.opacity(0.8))
                    .shadow(color: Color.white.opacity(0.1), radius: 0.5, x: 0, y: 0)
                    .monospacedDigit()
            }
            .frame(width: UIDevice.isCompactDevice ? 140 : (adaptiveLayout.isIPad ? 300 : 200), alignment: .center)
            .contentShape(Rectangle())
            .onTapGesture {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
                isShowingKeypad = true
            }
            
            // Plus Button
            ZStack {
                Image(systemName: "chevron.forward")
                    .font(.system(size: AdaptiveValues.chevronSize, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.white.opacity(0.9))
                    .shadow(color: Color.white.opacity(0.3), radius: 0.5, x: 0, y: 0)
            }
            .frame(width: AdaptiveValues.chevronFrameSize, height: AdaptiveValues.chevronFrameSize)
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

// Keep your existing legacy initializer
extension BPMControlsView {
    init(metronome: MetronomeEngine, isShowingKeypad: Binding<Bool>, previousTempo: Binding<Double>) {
        self.metronome = metronome
        self._isShowingKeypad = isShowingKeypad
        self._previousTempo = previousTempo
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
