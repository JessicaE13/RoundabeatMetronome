//
//  CircleArcView.swift
//  RoundabeatMetronome
//
//  Created by Jessica Estes on 4/15/25.
//

import SwiftUI

struct CircleArcView: View {
    let numberOfTicks: Int = 4 // this should be equal to the number of beats in the measure (top of the time signature)
    let tickWidth: CGFloat = 5
    let tickHeight: CGFloat = 6
    let circleRadius: CGFloat = 100
    
    var body: some View {
        ZStack {
            // Base circle outline (black)
            Circle()
                .stroke(Color.white, lineWidth: 5)
                .frame(width: circleRadius * 2, height: circleRadius * 2)
            
            // Blue arc between first and second tick, starting at 12 o'clock
            Circle()
                .trim(from: 0.0, to: 1.0 / CGFloat(numberOfTicks)) // One segment
                .stroke(Color.accentBlue, lineWidth: 5)
                .frame(width: circleRadius * 2, height: circleRadius * 2)
         //       .rotationEffect(.degrees(-90)) // Fixed at 12 o'clock
                .rotationEffect(.degrees(360.0 / Double(numberOfTicks) - 90))
            
            
            // Tick marks
            ForEach(0..<numberOfTicks, id: \.self) { index in
                let angle = Double(index) * (360.0 / Double(numberOfTicks))
                Rectangle()
                    .frame(width: tickWidth, height: tickHeight)
                    .offset(y: -circleRadius)
                    .rotationEffect(.degrees(angle))
                    .foregroundColor(.black)
            }
        }
    }
}

#Preview {
    CircleArcView()
}
