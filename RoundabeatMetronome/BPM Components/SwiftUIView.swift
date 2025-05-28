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
            
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.blue)
                .frame(width: 200, height: 100)
            
            Rectangle()
                .fill(Color.blue)
                .frame(width: 200, height: 1)
                .offset(y: 30)
        
            Rectangle()
                .fill(Color.blue)
                .frame(width: 200, height: 1)
                .offset(y: -30)
            
        }
    }
}

#Preview {
    SwiftUIView()
}
