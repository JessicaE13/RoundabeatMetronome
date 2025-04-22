//
//  RectangleView.swift
//  RoundabeatMetronome
//
//  Created by Jessica Estes on 4/22/25.
//

import SwiftUI

struct RectangleView: View {
    var body: some View {
      
        ZStack {
            
            RoundedRectangle(cornerRadius: 15)
                .fill(.shadow(.inner(radius: 4, x: 1, y: 1)))
                .foregroundStyle(Color("calculatorColor"))
                .frame(width: 300, height: 175)
        }
    }
}

#Preview {
    RectangleView()
}
