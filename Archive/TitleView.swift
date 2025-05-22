//
//  TitleView.swift
//  RoundabeatMetronome
//
//  Created by Jessica Estes on 4/21/25.
//

import SwiftUI

struct TitleView: View {
    var body: some View {
        Text("r o u n d a b e a t")
            .font(.system(.title2, design: .default))
            .fontWeight(.medium)
            .foregroundStyle(
                         LinearGradient(
                            colors: [.black.opacity(0.7), .black.opacity(0.9), .black.opacity(0.6)],
                             startPoint: .leading,
                             endPoint: .trailing
                         )
                     )
            .shadow(radius: 1)
      
    
        
        Text("Test Font")
          .font(.custom("Museo", size: 50))
        
    }
}

#Preview {
    TitleView()
}
