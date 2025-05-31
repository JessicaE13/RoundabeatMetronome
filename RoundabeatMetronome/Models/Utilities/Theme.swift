//
//  Theme.swift
//  RoundabeatMetronome
//
//  Created by Jessica Estes on 5/31/25.
//

import SwiftUI


//  RADIAL GRADIENT ACCENT COLOR GLOW
//  >> Use examples and code below
//
//            In any view file
//            Button("Start") { }
//                .glowingAccent(size: 20)
//
//            Image(systemName: "heart.fill")
//                .glowingAccent(size: 24, intensity: 0.9)
//
//            Text("♪")
//                .font(.title)
//                .glowingAccent(size: 28)
//

struct GlowingAccentStyle: ViewModifier {
    let size: CGFloat
    let intensity: Double
    
    init(size: CGFloat = 30, intensity: Double = 0.8) {
        self.size = size
        self.intensity = intensity
    }
    
    func body(content: Content) -> some View {
        content
            .foregroundStyle(
                RadialGradient(
                    colors: [
                        Color.accentColor.mix(with: .white, by: intensity),
                        Color.accentColor.opacity(0.7)
                    ],
                    center: UnitPoint(x: 0.35, y: 0.5),
                    startRadius: size * 0.2,
                    endRadius: size * 0.67
                )
            )
    }
}

extension View {
    func glowingAccent(size: CGFloat = 30, intensity: Double = 0.8) -> some View {
        modifier(GlowingAccentStyle(size: size, intensity: intensity))
    }
}

