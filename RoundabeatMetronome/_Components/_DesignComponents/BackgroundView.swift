import SwiftUI

struct BackgroundView: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
//            // Base gradient
            
            LinearGradient(
                colors: colorScheme == .dark ? [
                    Color(red: 38/255, green: 38/255, blue: 39/255),
                    Color(red: 34/255, green: 34/255, blue: 35/255)
                ] : [
                    Color(red: 245/255, green: 245/255, blue: 246/255),
                    Color(red: 235/255, green: 235/255, blue: 237/255)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            
            
            // Matte soft-light haze
            Color.black
                .opacity(colorScheme == .dark ? 0.06 : 0.03)
                .blendMode(.softLight)
                .ignoresSafeArea()

        }
    }
}

#Preview {
    BackgroundView()
}
