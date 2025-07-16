//
//  DJJogWheelView.swift
//  RoundabeatMetronome
//
//  Created by Jessica Estes on 7/16/25.
//

import SwiftUI

struct DJJogWheelView2: View {
    var body: some View {
        ZStack {
            // Outer notched ring
            Circle()
                .strokeBorder(
                    AngularGradient(
                        gradient: Gradient(colors: [.black, .gray, .black]),
                        center: .center
                    ),
                    lineWidth: 20
                )
                .overlay(
                    NotchedRing()
                        .stroke(Color.black.opacity(0.8), lineWidth: 3)
                        .blur(radius: 1)
                )
                .frame(width: 200, height: 200)

            // Inner matte disc
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.gray.opacity(0.9), Color.black]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 160, height: 160)

            // Central indicator ring
            JogRing()
                .stroke(Color.white.opacity(0.8), lineWidth: 2)
                .frame(width: 60, height: 60)
        }
        .background(Color.black)
    }
}
struct NotchedRing: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let count = 24
        let radius = rect.width / 2
        let notchLength: CGFloat = 10

        for i in 0..<count {
            let angle = Angle.degrees(Double(i) / Double(count) * 360)
            let start = CGPoint(
                x: rect.midX + CGFloat(cos(Double(angle.radians))) * (radius - notchLength),
                y: rect.midY + CGFloat(sin(Double(angle.radians))) * (radius - notchLength)
            )
            let end = CGPoint(
                x: rect.midX + CGFloat(cos(Double(angle.radians))) * radius,
                y: rect.midY + CGFloat(sin(Double(angle.radians))) * radius
            )
            path.move(to: start)
            path.addLine(to: end)
        }

        return path
    }
}

struct JogRing: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let tickCount = 40
        let radius = rect.width / 2

        for i in 0..<tickCount {
            // Skip the top 20 degrees for visual gap
            let angle = Double(i) / Double(tickCount) * 360
            if angle > 340 || angle < 20 { continue }
            
            let radians = Angle.degrees(angle).radians
            let tickLength: CGFloat = 6

            let start = CGPoint(
                x: rect.midX + CGFloat(cos(Double(radians))) * (radius - tickLength),
                y: rect.midY + CGFloat(sin(Double(radians))) * (radius - tickLength)
            )
            let end = CGPoint(
                x: rect.midX + CGFloat(cos(Double(radians))) * radius,
                y: rect.midY + CGFloat(sin(Double(radians))) * radius
            )

            path.move(to: start)
            path.addLine(to: end)
        }

        return path
    }
}


#Preview {
    DJJogWheelView2()
}
