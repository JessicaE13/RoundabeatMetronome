import SwiftUI

struct BackgroundView: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                AppTheme.backgroundColor.darker(by: 0.03),
                AppTheme.backgroundColor.darker(by: 0.1)
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

