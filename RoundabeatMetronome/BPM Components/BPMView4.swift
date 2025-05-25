//
//  BPMView4.swift
//  RoundabeatMetronome
//
//  Created by Jessica Estes on 5/24/25.
//

import SwiftUI

struct BPMView4: View {
    var body: some View {
        VStack (spacing: 0){
//            
//            
//            ZStack{
//                RoundedRectangle(cornerRadius: 8)
//                    .fill(Color.black.opacity(0.3))
//                    .frame(width: 350, height: 100)
//                HStack{
//                    
//                    
//                    VStack{
//                        
//                        Text("TEMPO (BPM)")
//                            .font(.system(size: 10, weight: .regular, design: .default))
//                            .kerning(1)
//                            .foregroundColor(.white)
//                        
//                        Text("120")
//                            .font(.system(size: 50, weight: .bold, design: .default))
//                            .kerning(1)
//                            .foregroundColor(.white)
//                    }
//                    Spacer()
//                    VStack{
//                        
//                        Text("T.S.")
//                            .font(.system(size: 10, weight: .regular, design: .default))
//                            .kerning(1)
//                            .foregroundColor(.white)
//                        
//                        Text("3/4")
//                            .font(.system(size: 50, weight: .bold, design: .default))
//                            .kerning(1)
//                            .foregroundColor(.white)
//                    }
//                    
//                    VStack{
//                        
//                        Text("RHYTHM")
//                            .font(.system(size: 10, weight: .regular, design: .default))
//                            .kerning(1)
//                            .foregroundColor(.white)
//                        
//                        Text("1")
//                            .font(.system(size: 50, weight: .bold, design: .default))
//                            .kerning(1)
//                            .foregroundColor(.white)
//                    }
//
//                }
//                .frame(width: 300, height: 100)
//            }
            ZStack{
//                RoundedRectangle(cornerRadius: 8)
//                    .fill(Color.black.opacity(0.3))
//                    .frame(width: 350, height: 100)
                VStack (spacing: 0){
                    
                    Text("TEMPO (BPM)")
                        .font(.system(size: 10, weight: .regular, design: .default))
                        .kerning(1)
                        .foregroundColor(.white)
                    
                    Text("120")
                        .font(.system(size: 100, weight: .bold, design: .default))
                        .kerning(1)
                        .foregroundColor(.white)
                }
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
        BPMView4()
    }
}
