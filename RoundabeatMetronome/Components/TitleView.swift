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
            .font(.body)
            .fontWeight(.bold)
            .foregroundStyle(.black.opacity(0.85))
            .shadow(color: .black.opacity(0.2), radius: 1, x: 2, y: 1)
            .shadow(color: .white.opacity(0.1), radius: 1, x: -2, y: -1)
            .padding(35.0)
    
    }
}

#Preview {
    TitleView()
}
