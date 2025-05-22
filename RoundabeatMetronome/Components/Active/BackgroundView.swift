import SwiftUI

struct BackgroundView: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 52/255, green: 52/255, blue: 55/255),   // halfway between #2c2c2c and #3c3c3c
                Color(red: 25/255, green: 25/255, blue: 27/255)    // halfway between #141414 and #1e1e1e
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
        .overlay(
            Color.black.opacity(0.09) // gentle matte layer
        )
    }
}

#Preview {
    BackgroundView()
}

