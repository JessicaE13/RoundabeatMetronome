//import SwiftUI
//
//struct BPMControlsView: View {
//    @ObservedObject var metronome: MetronomeEngine
//    @Binding var isShowingKeypad: Bool
//    @Binding var previousTempo: Double
//    
//    var body: some View {
//        HStack(spacing: AdaptiveSizing.current.spacing(20)) {
//            // Minus Button
//            ZStack {
//                Image(systemName: "chevron.backward")
//                    .adaptiveFont(.title, weight: .bold)
//                    .foregroundColor(Color.white.opacity(0.9))
//                    .shadow(color: Color.white.opacity(0.3), radius: 0.5, x: 0, y: 0)
//            }
//            .adaptiveFrame(width: 30, height: 30)
//            .contentShape(Rectangle())
//            .onTapGesture {
//                let generator = UIImpactFeedbackGenerator(style: .soft)
//                generator.impactOccurred(intensity: 0.5)
//                metronome.updateTempo(to: metronome.tempo - 1)
//                previousTempo = metronome.tempo
//            }
//            
//            // BPM Number Display
//            VStack {
//                Text("\(Int(metronome.tempo))")
//                    .adaptiveCustomFont("Kanit-SemiBold", size: 90) // This will now scale appropriately
//                    .kerning(AdaptiveSizing.current.spacing(2))
//                    .adaptivePadding(.top, -24)
//                    .adaptivePadding(.bottom, -20)
//                    .foregroundColor(Color.white.opacity(0.8))
//                    .shadow(color: Color.white.opacity(0.1), radius: 0.5, x: 0, y: 0)
//                    .monospacedDigit()
//            }
//            .adaptiveFrame(width: 200)
//            .contentShape(Rectangle())
//            .onTapGesture {
//                let generator = UIImpactFeedbackGenerator(style: .light)
//                generator.impactOccurred()
//                isShowingKeypad = true
//            }
//            
//            // Plus Button
//            ZStack {
//                Image(systemName: "chevron.forward")
//                    .adaptiveFont(.title, weight: .bold)
//                    .foregroundColor(Color.white.opacity(0.9))
//                    .shadow(color: Color.white.opacity(0.3), radius: 0.5, x: 0, y: 0)
//            }
//            .adaptiveFrame(width: 30, height: 30)
//            .contentShape(Rectangle())
//            .onTapGesture {
//                let generator = UIImpactFeedbackGenerator(style: .soft)
//                generator.impactOccurred(intensity: 0.5)
//                metronome.updateTempo(to: metronome.tempo + 1)
//                previousTempo = metronome.tempo
//            }
//        }
//    }
//}
//
//#Preview {
//    ZStack{
//        BackgroundView()
//        BPMControlsView(
//            metronome: MetronomeEngine(),
//            isShowingKeypad: .constant(false),
//            previousTempo: .constant(120)
//        )
//        .overlay(
//            Rectangle()
//                .stroke(Color.red, lineWidth: 1)
//        )
//    }
//}
