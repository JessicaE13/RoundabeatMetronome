import SwiftUI

struct LogoView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var shimmerOffset: CGFloat = -1.0  // Start off-screen to the left
    @State private var isAnimating = false  // Track animation state
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
            ? Color("Gray1")   // Dark gray for dark mode (subtle)
            : Color(red: 210/255, green: 211/255, blue: 211/255) // Light gray for light mode (subtle)
    }
    
    // Adaptive shimmer color based on color scheme
    private var shimmerColor: Color {
        colorScheme == .dark
            ? Color("AccentColor")  // Light shimmer for dark mode
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
                    .opacity(shimmerOffset >= 1.0 ? 0 : 1)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                startShimmerAnimation()
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private func startShimmerAnimation() {
        // Stop any current animation and reset immediately
        isAnimating = false
        shimmerOffset = -1.0
        
        // Start new animation
        isAnimating = true
        withAnimation(.easeInOut(duration: 3.0)) {
            shimmerOffset = 1.0
        }
        
        // Reset animation state after completion
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            isAnimating = false
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
