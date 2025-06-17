//  BackgroundView.swift

import SwiftUI

struct BackgroundView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        
        
        ZStack {
            LinearGradient(
                colors: colorScheme == .dark ? [
                    // Dark mode colors
                    Color(red: 24/255, green: 24/255, blue: 25/255),
                    Color(red: 20/255, green: 20/255, blue: 21/255)
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
