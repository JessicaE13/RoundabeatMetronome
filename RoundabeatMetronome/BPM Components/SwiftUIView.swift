//
//  BPMView4.swift
//  RoundabeatMetronome
//
//  Created by Jessica Estes on 5/24/25.
//

import SwiftUI

struct SwiftUIView: View {
    var body: some View {
        VStack(spacing: 0){
                VStack{
                    
                    Text("TEMPO (BPM)")
                        .font(.system(size: 10, weight: .regular, design: .default))
                        .kerning(1)
                        .foregroundColor(.white)
                    
                    Text("120")
                        .font(.system(size: 100, weight: .bold, design: .default))
                        .kerning(1)
                        .foregroundColor(.white)
                
            }
            TempoSelectorView(
                metronome: MetronomeEngine(),
                previousTempo: .constant(120)
            )
        }
        
        
        
    }
}

#Preview {
    ZStack{
 BackgroundView()
        SwiftUIView()
    }
}
