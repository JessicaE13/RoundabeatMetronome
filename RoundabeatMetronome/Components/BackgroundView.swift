//
//  BackgroundView.swift
//  RoundabeatMetronome
//
//  Created by Jessica Estes on 5/31/25.
//

import SwiftUI

struct BackgroundView: View {
    var body: some View {
      

                     ZStack {
                         LinearGradient(
                             colors: [
                                Color(red: 28/255, green: 28/255, blue: 29/255),
                                Color(red: 24/255, green: 24/255, blue: 25/255)
                                  ],
                             startPoint: .top,
                             endPoint: .bottom
                         )
                         .ignoresSafeArea()
                         
              
                     }
                   
                 }
               
             }
    


#Preview {
    BackgroundView()
}
