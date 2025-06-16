//
//  SwiftUIView.swift
//  RoundabeatMetronome
//
//  Created by Jessica Estes on 6/16/25.
//

import SwiftUI

struct SwiftUIView: View {
    var body: some View {
        
     //   let backgroundGradient = LinearGradient([Color.white.opacity(0.85), Color.white.opacity(0.65)], to: .bottom)
        
        ZStack{
            
            BackgroundView()
            
            RoundedRectangle(cornerRadius: 70)
                .fill(Color.white.gradient)
                .frame(width: 300, height: 300)
        }
    }
}

#Preview {
    SwiftUIView()
}
