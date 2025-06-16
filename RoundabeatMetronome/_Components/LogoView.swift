import SwiftUI

struct LogoView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var shimmerOffset: CGFloat = 0.0
    private let logoWidth: CGFloat = 700 // adjust this as needed
    
    // Get screen dimensions directly
    private var screenHeight: CGFloat {
        UIScreen.main.bounds.height
    }
    
    // Check if device is iPad
    private var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    // Computed property to determine logo height based on device
    private var logoHeight: CGFloat {
        if isIPad {
            // Larger for iPads
            return 36
        } else {
            // Smaller for smaller iPhones (iPhone SE, 12 mini, 13 mini)
            if screenHeight <= 667 {
                return 18
            }
            // Regular size for standard iPhones
            else {
                return 24
            }
        }
    }
    
    // Adaptive logo color based on color scheme
    private var logoColor: Color {
        colorScheme == .dark
            ? Color(red: 43/255, green: 44/255, blue: 44/255)   // Dark gray for dark mode (subtle)
            : Color(red: 210/255, green: 211/255, blue: 211/255) // Light gray for light mode (subtle)
    }
    
    // Adaptive shimmer color based on color scheme
    private var shimmerColor: Color {
        colorScheme == .dark
            ? Color(red: 240/255, green: 241/255, blue: 241/255)  // Light shimmer for dark mode
            : Color(red: 120/255, green: 120/255, blue: 120/255)  // Darker shimmer for light mode
    }

    var body: some View {
        VStack {
            ZStack {
                Image("roundabeatlogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: logoHeight)
                    .foregroundStyle(logoColor)
                
                Image("roundabeatlogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: logoHeight)
                    .foregroundStyle(logoColor)
                    .overlay(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                .clear,
                                shimmerColor,
                                .clear
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .offset(x: shimmerOffset * logoWidth)
                        .mask(
                            Image("roundabeatlogo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: logoHeight)
                        )
                    )
                    .onAppear {
                        startShimmerAnimation()
                    }
                    .opacity(shimmerOffset >= 1.0 ? 0 : 1)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                startShimmerAnimation()
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func startShimmerAnimation() {
        shimmerOffset = 0.0
        DispatchQueue.main.async {
            withAnimation(.easeInOut(duration: 3.0)) {
                shimmerOffset = 1.0
            }
        }
    }
}

#Preview {
    ZStack {
        VStack {
            LogoView()
        }
    }
}
