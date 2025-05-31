//
//  NeumorphicCircle.swift
//  RoundabeatMetronome
//
//  Created by Jessica Estes on 5/31/25.
//

import SwiftUI

struct NeumorphicCircle: View {
    private let knobSize: CGFloat = 220
    var body: some View {
        ZStack {
            // Center Knob Fill matching DarkGrayBackground view
            Circle()
                .fill(LinearGradient(
                    colors: [
                       Color(red: 28/255, green: 28/255, blue: 29/255),
                       Color(red: 24/255, green: 24/255, blue: 25/255)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                ))
                .frame(width: knobSize, height: knobSize)
            
            // Center Knob Dark Outline
            Circle()
                .stroke(Color(red: 1/255, green: 1/255, blue: 2/255), lineWidth: 3.0)
                .frame(width: knobSize, height: knobSize)
            
            // Center Knob outer highlight
            Circle()
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 101/255, green: 101/255, blue: 102/255).opacity(0.01),
                            Color(red: 101/255, green: 101/255, blue: 102/255).opacity(0.1),
                            Color(red: 101/255, green: 101/255, blue: 102/255).opacity(0.2),
                            Color(red: 101/255, green: 101/255, blue: 102/255).opacity(0.3)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.75
                )
                .frame(width: knobSize + 10, height: knobSize + 10)
            
            // Center Knob inner highlight
            Circle()
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 101/255, green: 101/255, blue: 102/255).opacity(0.6),
                            Color(red: 101/255, green: 101/255, blue: 102/255).opacity(0.3),
                            Color(red: 101/255, green: 101/255, blue: 102/255).opacity(0.3),
                            Color(red: 101/255, green: 101/255, blue: 102/255).opacity(0.3)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.75
                )
                .frame(width: knobSize - 3, height: knobSize - 3)
            
            playPauseIcon
        }
        .onTapGesture {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
      
        }
    }
    private var playPauseIcon: some View {
        Image(systemName:"play.fill")
            .font(.system(size: 30))
            .glowingAccent()
    }
      }
  


#Preview {
    BackgroundView()
    NeumorphicCircle()
}
