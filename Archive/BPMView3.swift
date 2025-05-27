//
//  BPMView3.swift
//  RoundabeatMetronome
//
//  Created by Jessica Estes on 5/24/25.
//

import SwiftUI

struct BPMView3: View {

private let gradientColors = [
    Color.white.opacity(0.8),
    Color.white.opacity(0.1),
    Color.white.opacity(0.1),
    Color.white.opacity(0.4),
    Color.white.opacity(0.5)
]
    
    var body: some View {
                ZStack {
                    MeshGradient(
                        width: 3,
                        height: 3,
                        points: [
                            [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                            [0.0, 0.5], [0.5, 0.5], [1.0, 0.5],
                            [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
                        ],
                        colors: [
                            Color(red: 229/255, green: 235/255, blue: 219/255),
                            Color(red: 193/255, green: 168/255, blue: 190/255),
                            Color(red: 221/255, green: 185/255, blue: 198/255),
                            Color(red: 115/255, green: 86/255, blue: 128/255),
                            Color(red: 166/255, green: 119/255, blue: 154/255),
                            Color(red: 222/255, green: 169/255, blue: 193/255),
                            Color(red: 111/255, green: 68/255, blue: 115/255),
                            Color(red: 139/255, green: 98/255, blue: 117/255),
                            Color(red: 187/255, green: 138/255, blue: 144/255)
                        ]
                    )
                    .ignoresSafeArea(.all)
                    
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(LinearGradient(colors: gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 200, height: 200)
                    
                }//end zstack
            }
        }
  

#Preview {
    BPMView3()
}
