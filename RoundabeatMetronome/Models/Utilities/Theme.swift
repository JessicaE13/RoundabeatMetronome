////
////  Theme.swift
////  RoundabeatMetronome
////
////  Created by Jessica Estes on 5/31/25.
////
//
//import SwiftUI
//
//
////  RADIAL GRADIENT ACCENT COLOR GLOW
////  >> Use examples and code below
////
////            In any view file
////            Button("Start") { }
////                .glowingAccent(size: 20)
////
////            Image(systemName: "heart.fill")
////                .glowingAccent(size: 24, intensity: 0.9)
////
////            Text("♪")
////                .font(.title)
////                .glowingAccent(size: 28)
////
//
//struct GlowingAccentStyle: ViewModifier {
//    let size: CGFloat
//    let intensity: Double
//    
//    init(size: CGFloat = 30, intensity: Double = 0.8) {
//        self.size = size
//        self.intensity = intensity
//    }
//    
//    func body(content: Content) -> some View {
//        content
//            .foregroundStyle(
//                RadialGradient(
//                    colors: [
//                        Color.accentColor.mix(with: .white, by: intensity),
//                        Color.accentColor.opacity(0.7)
//                    ],
//                    center: UnitPoint(x: 0.35, y: 0.5),
//                    startRadius: size * 0.2,
//                    endRadius: size * 0.67
//                )
//            )
//    }
//}
//
//extension View {
//    func glowingAccent(size: CGFloat = 30, intensity: Double = 0.8) -> some View {
//        modifier(GlowingAccentStyle(size: size, intensity: intensity))
//    }
//}
//
//// KEEP AS STYLE REFERENCE FOR FUTURE UPDATES POSSIBLE TO ADD STYLE LATER
//
////struct NeumorphicCircle: View {
////    private let knobSize: CGFloat = 220
////    var body: some View {
////        ZStack {
////            // Center Knob Fill matching DarkGrayBackground view
////            Circle()
////                .fill(LinearGradient(
////                    colors: [
////                       Color(red: 28/255, green: 28/255, blue: 29/255),
////                       Color(red: 24/255, green: 24/255, blue: 25/255)
////                    ],
////                    startPoint: .top,
////                    endPoint: .bottom
////                ))
////                .frame(width: knobSize, height: knobSize)
////            
////            // Center Knob Dark Outline
////            Circle()
////                .stroke(Color(red: 1/255, green: 1/255, blue: 2/255), lineWidth: 3.0)
////                .frame(width: knobSize, height: knobSize)
////            
////            // Center Knob outer highlight
////            Circle()
////                .stroke(
////                    LinearGradient(
////                        gradient: Gradient(colors: [
////                            Color(red: 101/255, green: 101/255, blue: 102/255).opacity(0.01),
////                            Color(red: 101/255, green: 101/255, blue: 102/255).opacity(0.1),
////                            Color(red: 101/255, green: 101/255, blue: 102/255).opacity(0.2),
////                            Color(red: 101/255, green: 101/255, blue: 102/255).opacity(0.3)
////                        ]),
////                        startPoint: .topLeading,
////                        endPoint: .bottomTrailing
////                    ),
////                    lineWidth: 0.75
////                )
////                .frame(width: knobSize + 10, height: knobSize + 10)
////            
////            // Center Knob inner highlight
////            Circle()
////                .stroke(
////                    LinearGradient(
////                        gradient: Gradient(colors: [
////                            Color(red: 101/255, green: 101/255, blue: 102/255).opacity(0.6),
////                            Color(red: 101/255, green: 101/255, blue: 102/255).opacity(0.3),
////                            Color(red: 101/255, green: 101/255, blue: 102/255).opacity(0.3),
////                            Color(red: 101/255, green: 101/255, blue: 102/255).opacity(0.3)
////                        ]),
////                        startPoint: .topLeading,
////                        endPoint: .bottomTrailing
////                    ),
////                    lineWidth: 0.75
////                )
////                .frame(width: knobSize - 3, height: knobSize - 3)
////            
////            playPauseIcon
////        }
////        .onTapGesture {
////            let generator = UIImpactFeedbackGenerator(style: .medium)
////            generator.impactOccurred()
////      
////        }
////    }
////    private var playPauseIcon: some View {
////        Image(systemName:"play.fill")
////            .font(.system(size: 30))
////            .glowingAccent()
////    }
////      }
////  
