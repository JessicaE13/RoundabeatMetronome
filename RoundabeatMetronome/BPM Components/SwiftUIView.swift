//
//  SwiftUIView.swift
//  RoundabeatMetronome
//
//  Created by Jessica Estes on 5/27/25.
//

import SwiftUI

struct SwiftUIView: View {
    var body: some View {
        ZStack {
            
            
            Circle()
                .fill(Color.gray)
                .frame(width: 200, height: 200)
            
            
            Image("EighthNote")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 25)
                .foregroundStyle(Color.white)
            
        }
    }
}

#Preview {
    SwiftUIView()
}
