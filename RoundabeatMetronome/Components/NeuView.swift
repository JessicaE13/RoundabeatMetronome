//
//  NeuView.swift
//  RoundabeatMetronome
//
//  Created by Jessica Estes on 4/23/25.
//

import SwiftUI

struct NeuView: View {
    
    var cornerRadius: CGFloat = 20
    
    var body: some View {

     
        
        VStack {
            ZStack {
                
      
                
                Circle()
                    .fill(Color("MainColor"))
                    .frame(width: 100, height: 100)
                    .blur(radius: 10)
                    .shadow(color: Color("ShadowColor"), radius: 40, x: -18, y: -18)
                    .shadow(color: Color("HighlightColor"), radius: 40, x: 18, y: 18)
           
                
                  
                
            }
            
            
            .mask(
                Circle()
            )
            
        }
        
        
                
                
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color("MainColor"))
                .edgesIgnoringSafeArea(.all)
                
                
                
        
        
        
    }
        
    }


#Preview {
    NeuView()
}
