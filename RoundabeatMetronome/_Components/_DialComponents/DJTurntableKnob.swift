//
//  DJTurntableKnob.swift
//  RoundabeatMetronome
//
//  Created by Jessica Estes on 7/1/25.
//

import SwiftUI

struct DJTurntableKnob: View {
    let size: CGFloat

    var body: some View {
        ZStack {
            // Drop shadow for depth
            Circle()
                .fill(Color.black)
                .frame(width: size * 1.05, height: size * 1.05)
                .offset(y: size * 0.04)
                .blur(radius: size * 0.03)

            // Outer shell with soft matte gradient
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color(white: 0.25),
                            Color(white: 0.12)
                        ]),
                        center: .center,
                        startRadius: size * 0.05,
                        endRadius: size * 0.5
                    )
                )
                .frame(width: size, height: size)

            // CRISP edge ring — like a subtle plastic lip
            Circle()
                .stroke(Color(white: 0.4), lineWidth: size * 0.006)
                .frame(width: size, height: size)

            // Inner dial face with subtle lighting
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color(white: 0.10),
                            Color(white: 0.07)
                        ]),
                        center: .topLeading,
                        startRadius: size * 0.1,
                        endRadius: size * 0.8
                    )
                )
                .frame(width: size * 0.85, height: size * 0.85)
                .overlay(
                    Circle()
                        .stroke(Color.black.opacity(0.15), lineWidth: size * 0.005)
                )
            ZStack {
                // Enlarged and slightly colored play button background
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.2, green: 0.2, blue: 0.2), // subtle glow
                                Color(red: 30/255, green: 30/255, blue: 31/255)
                            ]),
                            center: .center,
                            startRadius: 0,
                            endRadius: size * 0.2
                        )
                    )
                    .frame(width: size * 0.4, height: size * 0.4)
                    .shadow(color: Color.white.opacity(0.1), radius: size * 0.03, y: size * 0.01)

                Circle()
                    .stroke(Color(red: 4/255, green: 4/255, blue: 4/255), lineWidth: size * 0.005)
                    .frame(width: size * 0.5, height: size * 0.5)

                Image(systemName: "play.fill")
                    .font(.system(size: size * 0.16, weight: .heavy))
                    .foregroundColor(.white)
            }


        }
        .frame(width: size, height: size)
    }
}

#Preview {
    ZStack{
        BackgroundView()
        DJTurntableKnob(size:200)
    }
}
