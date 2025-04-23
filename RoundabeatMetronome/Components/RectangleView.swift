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
            
            //start outlines
            
                HStack {
                    VStack {
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.gray, lineWidth: 1)
                            .frame(width: 75, height: 50)
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.gray, lineWidth: 1)
                            .frame(width: 75, height: 50)
                    }
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.gray, lineWidth: 1)
                        .frame(width: 115, height: 108)
                    
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.gray, lineWidth: 1)
                        .frame(width: 75, height: 108)
                }
            
            // end outlines
            
            
            // start BPM VStack
            VStack {
                Text("BPM")
                Text("120")
                Text("ALLEGRO")
                
            }
            //end BPM VStack
            
            
            
            
            
            
            
        }
        
        
        
        
        
    }
}

#Preview {
    RectangleView()
}
