//
//  DialMockup.swift
//  RoundabeatMetronome
//
//  Created by Jessica Estes on 7/16/25.
//

import SwiftUI

struct DJJogWheelView: View {
    var body: some View {
        ZStack {
            // Dark background
            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color(red: 0.05, green: 0.05, blue: 0.06)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Jog wheel
            ZStack {
                // Outer ring with studs
                Circle()
                    .strokeBorder(Color(.darkGray), lineWidth: 12)
                    .overlay(
                        ForEach(0..<60) { i in
                            Rectangle()
                                .fill(Color.gray.opacity(0.7))
                                .frame(width: 2, height: 10)
                                .offset(y: -150)
                                .rotationEffect(.degrees(Double(i) * 6))
                        }
                    )
                    .frame(width: 320, height: 320)

                // Inner vinyl with groove shine
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [Color.black, Color(red: 0.1, green: 0.1, blue: 0.1)]),
                            center: .center,
                            startRadius: 0,
                            endRadius: 160
                        )
                    )
                    .frame(width: 300, height: 300)
                    .overlay(
                        WaveReflection()
                            .stroke(Color.white.opacity(0.12), lineWidth: 3)
                            .blur(radius: 1)
                            .rotationEffect(.degrees(-25))
                    )

                // Orange label
                Circle()
                    .fill(Color.orange)
                    .overlay(Circle().stroke(Color.white.opacity(0.4), lineWidth: 2))
                    .frame(width: 60, height: 60)

                // Small center dot
                Circle()
                    .fill(Color.black)
                    .frame(width: 8, height: 8)
            }
        }
    }
}

struct WaveReflection: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let midX = rect.midX
        let midY = rect.midY
        let radius = rect.width / 2

        path.move(to: CGPoint(x: midX - radius * 0.7, y: midY))
        path.addCurve(to: CGPoint(x: midX + radius * 0.7, y: midY),
                      control1: CGPoint(x: midX - radius * 0.4, y: midY - 30),
                      control2: CGPoint(x: midX + radius * 0.4, y: midY + 30))

        return path
    }
}

struct DJJogWheelView_Previews: PreviewProvider {
    static var previews: some View {
        DJJogWheelView()
    }
}
