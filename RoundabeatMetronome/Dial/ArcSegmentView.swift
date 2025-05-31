import SwiftUI

struct ArcSegmentView: View {
    let center: CGPoint
    let radius: CGFloat
    let startAngle: Double
    let endAngle: Double
    let lineWidth: CGFloat
    let isActive: Bool
    let isFirstBeat: Bool
    let gapWidth: CGFloat
    let highlightFirstBeat: Bool // New parameter
   
    var body: some View {
        ZStack {
            // Shared arc path
            let arcPath = Path { path in
                path.addArc(center: center,
                            radius: radius,
                            startAngle: Angle(degrees: startAngle),
                            endAngle: Angle(degrees: endAngle),
                            clockwise: false)
            }

            if isActive {
                // Determine colors based on first beat highlighting
                let shouldUseNeonMagenta = isFirstBeat && highlightFirstBeat
                let primaryColor = shouldUseNeonMagenta ? Color(red: 0.7, green: 0.6, blue: 0.8) : Color.white // Pale subdued purple-magenta
                
                // LED-style glow effect with multiple layers
                
                // Outermost soft glow (largest radius) - enhanced for neon magenta
                arcPath
                    .stroke(primaryColor.opacity(shouldUseNeonMagenta ? 0.6 : 0.5),
                            style: StrokeStyle(lineWidth: lineWidth + (shouldUseNeonMagenta ? 25 : 20), lineCap: .round))
                    .blur(radius: shouldUseNeonMagenta ? 18 : 15)
                
                // Middle glow layer - more intense for neon magenta
                arcPath
                    .stroke(primaryColor.opacity(shouldUseNeonMagenta ? 0.4 : 0.3),
                            style: StrokeStyle(lineWidth: lineWidth + (shouldUseNeonMagenta ? 15 : 12), lineCap: .round))
                    .blur(radius: shouldUseNeonMagenta ? 10 : 8)
                
                // Inner glow - vibrant for neon magenta
                arcPath
                    .stroke(primaryColor.opacity(shouldUseNeonMagenta ? 0.8 : 0.6),
                            style: StrokeStyle(lineWidth: lineWidth + (shouldUseNeonMagenta ? 6 : 4), lineCap: .round))
                    .blur(radius: shouldUseNeonMagenta ? 4 : 3)
                
                // Core LED light - bright and crisp with enhanced magenta gradient
                arcPath
                    .stroke(
                        LinearGradient(
                            colors: shouldUseNeonMagenta ?
                                [Color(red: 0.75, green: 0.65, blue: 0.85), Color(red: 0.65, green: 0.55, blue: 0.75)] :
                                [Color.white, Color.white.opacity(0.9)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                    )
                    .shadow(color: primaryColor.opacity(shouldUseNeonMagenta ? 0.6 : 0.8),
                           radius: shouldUseNeonMagenta ? 3 : 2, x: 0, y: 0)
                
                // Inner highlight for extra LED brightness - more pronounced for magenta
                arcPath
                    .stroke(primaryColor.opacity(shouldUseNeonMagenta ? 0.7 : 0.9),
                            style: StrokeStyle(lineWidth: lineWidth * (shouldUseNeonMagenta ? 0.4 : 0.3), lineCap: .round))
                
                // Additional subtle glow effect for pale magenta first beat
                if shouldUseNeonMagenta {
                    // Extra outer glow for subtle neon effect - using the pale purple color
                    arcPath
                        .stroke(Color(red: 0.68, green: 0.58, blue: 0.78).opacity(0.2),
                                style: StrokeStyle(lineWidth: lineWidth + 25, lineCap: .round))
                        .blur(radius: 15)
                }
                
            } else {
                // Inactive state - subtle outline
              
                arcPath
                    .strokedPath(StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                    .fill(Color(red: 43/255, green: 44/255, blue: 44/255))
                    .shadow(color:   Color(red: 101/255, green: 101/255, blue: 102/255).opacity(0.3), radius: 0.5, x: 0, y: 0)
                arcPath
                    .strokedPath(StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                    .stroke(Color(red: 1/255, green: 1/255, blue: 2/255), lineWidth: 1.5)
                    .shadow(color:   Color(red: 101/255, green: 101/255, blue: 102/255).opacity(0.75), radius: 0.5, x: 0, y: 0)
                
            }
        }
        .animation(.easeInOut(duration: 0.15), value: isActive)
    }
}

#Preview {
    ZStack {
        BackgroundView()
        
        GeometryReader { geometry in
            ArcSegmentView(
                center: CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2),
                radius: 120,
                startAngle: 225,
                endAngle: 315,
                lineWidth: 25,
                isActive: true, // Changed to true to show LED effect
                isFirstBeat: true,
                gapWidth: 10,
                highlightFirstBeat: true // Added to show neon magenta effect
            )
        }
    }
}
