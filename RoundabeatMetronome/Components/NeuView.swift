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
                    
        ZStack {
            Circle()
                .foregroundColor(.pink)
            
            Circle()
                .foregroundColor(.white)
                .scaleEffect(0.6)
        }
        VStack {
            ZStack {
                
                Circle()
                    .fill(Color("MainColor"))
                    .frame(width: 150, height: 150)
                
                Circle()
                    .fill(Color("MainColor"))
                    .frame(width: 100, height: 100)
                    .blur(radius: 10)
                    .shadow(color: Color("ShadowColor"), radius: 40, x: -18, y: -18)
                    .shadow(color: Color("HighlightColor"), radius: 40, x: 18, y: 18)
             
                Circle()
                    .stroke(Color("MainColor"))
                    .frame(width: 30, height: 30)
                    .shadow(color: Color("HighlightColor"), radius: 12, x: -7, y: -7)
                    .shadow(color: Color("ShadowColor"), radius: 12, x: 7, y: 7)
                
                
                Circle()
                    .fill(Color("MainColor"))
                    .frame(width: 30, height: 30)
                    .shadow(color: Color("HighlightColor"), radius: 12, x: -7, y: -7)
                    .shadow(color: Color("ShadowColor"), radius: 12, x: 7, y: 7)
                    
                    .overlay(
                        Image(systemName: "4.circle.fill")
                            .resizable()
                            .frame(width: 10, height: 10)
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.pink)
                    )
                
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
