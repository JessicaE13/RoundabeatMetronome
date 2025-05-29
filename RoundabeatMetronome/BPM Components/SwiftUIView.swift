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
            
            DarkGrayBackgroundView()
            
            Circle()
                .fill(Color.black)
                .frame(width: 200, height: 200)
            
            Circle()
                .stroke(Color.gray)
                .frame(width: 190, height: 190)
            
        }
    }
}

#Preview {
    SwiftUIView()
}
