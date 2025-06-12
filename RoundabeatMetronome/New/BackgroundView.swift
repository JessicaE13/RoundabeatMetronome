//  BackgroundView.swift

import SwiftUI

struct BackgroundView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        
        
        ZStack {
            LinearGradient(
                colors: colorScheme == .dark ? [
                    // Dark mode colors
                    Color(red: 32/255, green: 32/255, blue: 33/255),
                    Color(red: 28/255, green: 28/255, blue: 29/255)
                ] : [
                    // Light mode colors
                    Color(red: 248/255, green: 248/255, blue: 249/255),
                    Color(red: 240/255, green: 240/255, blue: 242/255)
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
