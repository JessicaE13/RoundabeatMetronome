//
//  logo.swift
//  RoundabeatMetronome
//
//  Created by Jessica Estes on 5/17/25.
//

import SwiftUI

struct LogoView: View {
    @State private var shimmerOffset: CGFloat = -1.0

    var body: some View {
        ZStack {
            // Base text
            Text("roundabeat")
                .font(.custom("blippo", size: 36))
                .kerning(5)
                .foregroundColor(.black.opacity(0.9))

            // Shimmer text
            Text("roundabeat")
                .font(.custom("blippo", size: 36))
                .kerning(5)
                .overlay(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.clear,
                            Color.white.opacity(0.8),
                            Color.clear
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: 300) // ensure this is wider than the text
                    .offset(x: shimmerOffset * 300 - 150) // center-start to center-end
                    .mask(
                        Text("roundabeat")
                            .font(.custom("blippo", size: 36))
                            .kerning(5)
                    )
                )
                .onAppear {
                    withAnimation(.easeInOut(duration: 5)) {
                        shimmerOffset = 1.0
                    }
                }
                .opacity(shimmerOffset == 1.0 ? 0 : 1)
        }
    }
}


#Preview {
    LogoView()
}

