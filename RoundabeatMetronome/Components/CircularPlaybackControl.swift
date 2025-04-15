import SwiftUI

struct CircularPlaybackControl: View {
    // This is just for visual aesthetics, no actual functionality
    @State private var progress: CGFloat = 0.25 // The teal progress indicator appears to be around 25% complete
    
    var body: some View {
        ZStack {
            // Outer shadow for elevation effect
            Circle()
                .fill(Color.clear)
                .frame(width: 220, height: 220)
                .shadow(color: Color.black.opacity(0.7), radius: 15, x: 0, y: 8)
            
            // Background gradient for more dimension
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.black.opacity(0.8),
                            Color.black
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 200, height: 200)
                
            // Inner shadow effect to create depth
            Circle()
                .stroke(Color.black.opacity(0.4), lineWidth: 2)
                .frame(width: 198, height: 198)
                .blur(radius: 1)
                
            // Subtle highlight at the top
            Circle()
                .trim(from: 0.1, to: 0.4)
                .stroke(Color.white.opacity(0.05), lineWidth: 2)
                .frame(width: 195, height: 195)
                .rotationEffect(.degrees(-20))
            
            // Radial lines (tick marks)
            ForEach(0..<60) { index in
                Rectangle()
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: 1, height: 8)
                    .offset(y: -90)
                    .rotationEffect(.degrees(Double(index) * 6))
            }
            
            // Progress indicator with glow effect
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    Color(red: 64/255, green: 224/255, blue: 208/255),
                    style: StrokeStyle(lineWidth: 5, lineCap: .round)
                )
                .frame(width: 180, height: 180)
                .rotationEffect(.degrees(-90)) // Start from top
                .shadow(color: Color(red: 64/255, green: 224/255, blue: 208/255).opacity(0.5), radius: 5, x: 0, y: 0)
            
            // Inner circle (button background) with raised effect
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.black.opacity(0.7),
                            Color.black
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 80, height: 80)
                .shadow(color: Color.black.opacity(0.5), radius: 5, x: 0, y: 2)
                .overlay(
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
            
            // Pause icon with subtle glow
            HStack(spacing: 10) {
                Rectangle()
                    .fill(Color(red: 64/255, green: 224/255, blue: 208/255))
                    .frame(width: 6, height: 20)
                Rectangle()
                    .fill(Color(red: 64/255, green: 224/255, blue: 208/255))
                    .frame(width: 6, height: 20)
            }
            .shadow(color: Color(red: 64/255, green: 224/255, blue: 208/255).opacity(0.5), radius: 3, x: 0, y: 0)
        }
        .background(Color.clear)
    }
}

struct CircularPlaybackControlPreview: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            CircularPlaybackControl()
        }
    }
}
