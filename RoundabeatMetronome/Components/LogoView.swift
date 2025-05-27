//
//  logo.swift
//  RoundabeatMetronome
//
//  Created by Jessica Estes on 5/17/25.
//

import SwiftUI

struct LogoView: View {
    @State private var shimmerOffset: CGFloat = 0.0
    private let logoWidth: CGFloat = 700 // adjust this as needed

    var body: some View {
        ZStack {
            Image("roundabeatlogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 25)
                .foregroundStyle(Color(red: 43/255, green: 44/255, blue: 44/255))
        

            Image("roundabeatlogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 25)
                .padding(8)
                .foregroundStyle(Color(red: 43/255, green: 44/255, blue: 44/255))
                .overlay(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            .clear,
                            Color(red: 240/255, green: 241/255, blue: 241/255),
                            .clear
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    
                    .offset(x: shimmerOffset * logoWidth)
                    .mask(
                        Image("roundabeatlogo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 25)
                    )
                )
                .onAppear {
                    startShimmerAnimation()
                }
                .opacity(shimmerOffset >= 1.0 ? 0 : 1)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            startShimmerAnimation()
        }
    }

    private func startShimmerAnimation() {
        shimmerOffset = 0.0
        DispatchQueue.main.async {
            withAnimation(.easeInOut(duration: 3.0)) {
                shimmerOffset = 1.0
            }
        }
    }
}


#Preview {
    ZStack {
        DarkGrayBackgroundView()
        LogoView()
    }
}
