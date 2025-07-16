//
//  SwiftUIView.swift
//  RoundabeatMetronome
//
//  Created by Jessica Estes on 7/16/25.
//

import SwiftUI

struct SwiftUIView: View {
    var body: some View {
       

                ZStack {

            BackgroundView()

                    ZStack {
                        
                        // Thick gray outer border
                        Circle()
                            .strokeBorder(
                                LinearGradient(
                                    colors: [Color("Gray1").opacity(0.8), Color("Gray1").opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 8
                            )
                            .frame(width: 280, height: 280)
                        
                        // Purple ring
                        Circle()
                            .strokeBorder(Color("AccentColor").opacity(0.6), lineWidth: 2)
                            .frame(width: 240, height: 240)
                        
                        // Small middle circle
                        ZStack {
                            // Background
                            Circle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 120, height: 120)
                            
                            // Outline
                            Circle()
                                .strokeBorder(Color("Gray1").opacity(0.8), lineWidth: 1)
                                .frame(width: 120, height: 120)
                        }
                        
//
                    }
                }
            }
        }


        
        
        


#Preview {
    SwiftUIView()
}
