//
//  Dial2View.swift
//  RoundabeatMetronome
//
//  Created by Jessica Estes on 7/1/25.
//

import SwiftUI

struct Dial2View: View {
    @State private var rotation: Double = 0
    @State private var isDragging: Bool = false
    
    var body: some View {
        ZStack {
            // Dark gray background
            Color(.darkGray)
                .ignoresSafeArea()
            
            // Dial
            ZStack {
                // Base dial with 3D effect
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color.black.opacity(0.95),
                                Color.black.opacity(0.85),
                                Color.gray.opacity(0.3)
                            ]),
                            center: .center,
                            startRadius: 0,
                            endRadius: 100
                        )
                    )
                    .frame(width: 200, height: 200)
                    .shadow(color: .black.opacity(0.5), radius: 10, x: 5, y: 5)
                    .shadow(color: .white.opacity(0.1), radius: 10, x: -5, y: -5)
                
                // Highlight ring
                Circle()
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                .white.opacity(0.3),
                                .clear,
                                .white.opacity(0.1)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 4
                    )
                    .frame(width: 190, height: 190)
                
                // Knob indicator
                Capsule()
                    .fill(Color.white.opacity(0.8))
                    .frame(width: 4, height: 30)
                    .offset(y: -80)
                    .rotationEffect(.degrees(rotation))
                
                // Center hub
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                .gray.opacity(0.5),
                                .black
                            ]),
                            center: .center,
                            startRadius: 0,
                            endRadius: 20
                        )
                    )
                    .frame(width: 30, height: 30)
                    .shadow(color: .black.opacity(0.3), radius: 5, x: 2, y: 2)
            }
            .rotationEffect(.degrees(rotation))
            .gesture(
                DragGesture()
                    .onChanged { value in
                        isDragging = true
                        // Calculate rotation based on drag
                        let vector = CGPoint(x: value.location.x - 100, y: value.location.y - 100)
                        let angle = atan2(vector.y, vector.x) * 180 / .pi
                        rotation = angle + 90 // Adjust for natural rotation
                    }
                    .onEnded { _ in
                        isDragging = false
                    }
            )
            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: rotation)
        }
    }
}



#Preview {
    Dial2View()
}
