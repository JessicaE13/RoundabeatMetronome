//
//  DialBackgroundHelp.swift
//  RoundabeatMetronome
//
//  Created by Jessica Estes on 5/29/25.
//

import SwiftUI

struct DialBackgroundHelp: View {
    
    private let dialSize: CGFloat = 225
    @State private var dialRotation: Double = 0.0
    
    var body: some View {
        
        ZStack {
            
            DarkGrayBackgroundView()
            
            // Main Circle Background - darker color
            Circle()
                .fill(Color(red: 0/255, green: 0/255, blue: 1/255))
                .frame(width: dialSize+10, height: dialSize+10)
                .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
            
            // Main Circle Background - darker color
            Circle()
                .fill(Color(red: 7/255, green: 7/255, blue: 8/255))
                .frame(width: dialSize, height: dialSize)
                .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)

//            
//            // Outer highlight ring - simulates light hitting the raised edge
            Circle()
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 85/255, green: 85/255, blue: 86/255).opacity(0.4),
                            Color(red: 65/255, green: 65/255, blue: 66/255).opacity(0.2),
                            Color(red: 45/255, green: 45/255, blue: 46/255).opacity(0.1),
                            Color(red: 25/255, green: 25/255, blue: 26/255).opacity(0.05)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.0
                )
                .frame(width: dialSize + 2, height: dialSize + 2)
            
            // Inner shadow ring - creates depth
            Circle()
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 25/255, green: 25/255, blue: 26/255).opacity(0.1),
                            Color(red: 15/255, green: 15/255, blue: 16/255).opacity(0.2),
                            Color(red: 5/255, green: 5/255, blue: 6/255).opacity(0.3),
                            Color(red: 1/255, green: 1/255, blue: 2/255).opacity(0.4)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2.8
                )
                .frame(width: dialSize - 2, height: dialSize - 2)
            
            // Rotating indicator line - shows current position
            Rectangle()
                .fill(Color.white.opacity(0.8))
                .frame(width: 3, height: 20)
                .shadow(color: Color.black.opacity(0.3), radius: 1, x: 0, y: 0)
                .offset(y: -(dialSize / 2 - 14))
                .rotationEffect(Angle(degrees: dialRotation))
        }
    }
}

#Preview {
    DialBackgroundHelp()
}
