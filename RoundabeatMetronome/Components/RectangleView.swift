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
    }}


        struct ContentView2: View {
            @State private var isGlowing = false
            
            var body: some View {
                ZStack {
                    // Background
                    Color.black.edgesIgnoringSafeArea(.all)
                    
                    VStack(spacing: 30) {
                        // Basic glow
                        Text("Basic Glow")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.top)
                        
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 100, height: 100)
                            .shadow(color: Color.blue.opacity(0.7), radius: 20, x: 0, y: 0)
                        
                        // Animated glow
                        Text("Animated Glow")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Circle()
                            .fill(Color.green)
                            .frame(width: 100, height: 100)
                            .shadow(color: Color.green.opacity(isGlowing ? 0.7 : 0.3),
                                    radius: isGlowing ? 30 : 10,
                                    x: 0,
                                    y: 0)
                            .onAppear {
                                withAnimation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                                    isGlowing.toggle()
                                }
                            }
                        
                        // Multi-layer glow
                        Text("Multi-layer Glow")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        ZStack {
                            // Outer glow
                            Circle()
                                .fill(Color.red.opacity(0.2))
                                .frame(width: 130, height: 130)
                                .blur(radius: 20)
                            
                            // Middle glow
                            Circle()
                                .fill(Color.red.opacity(0.4))
                                .frame(width: 110, height: 110)
                                .blur(radius: 10)
                            
                            // Core
                            Circle()
                                .fill(Color.red)
                                .frame(width: 100, height: 100)
                        }
                    }
                }
            }
        }
        
        
        
        
      

#Preview {
    RectangleView()
    ContentView2()
}
