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
                // LED-style glow effect with multiple layers
                
                // Outermost soft glow (largest radius)
                arcPath
                    .stroke(Color.white.opacity(0.15),
                            style: StrokeStyle(lineWidth: lineWidth + 20, lineCap: .round))
                    .blur(radius: 15)
                
                // Middle glow layer
                arcPath
                    .stroke(Color.white.opacity(0.3),
                            style: StrokeStyle(lineWidth: lineWidth + 12, lineCap: .round))
                    .blur(radius: 8)
                
                // Inner glow
                arcPath
                    .stroke(Color.white.opacity(0.6),
                            style: StrokeStyle(lineWidth: lineWidth + 4, lineCap: .round))
                    .blur(radius: 3)
                
                // Core LED light - bright and crisp
                arcPath
                    .stroke(
                        LinearGradient(
                            colors: [Color.white, Color.white.opacity(0.9)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                    )
                    .shadow(color: Color.white.opacity(0.8), radius: 2, x: 0, y: 0)
                
                // Inner highlight for extra LED brightness
                arcPath
                    .stroke(Color.white.opacity(0.9),
                            style: StrokeStyle(lineWidth: lineWidth * 0.3, lineCap: .round))
                
            } else {
                // Inactive state - subtle outline
              
                arcPath
                    .strokedPath(StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                    .fill(Color(red: 15/255, green: 15/255, blue: 16/255))
                    .shadow(color:   Color(red: 101/255, green: 101/255, blue: 102/255).opacity(0.3), radius: 0.5, x: 0, y: 0)
                arcPath
                    .strokedPath(StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                    .stroke(Color(red: 1/255, green: 1/255, blue: 2/255), lineWidth: 1.5)
                    .shadow(color:   Color(red: 101/255, green: 101/255, blue: 102/255).opacity(0.3), radius: 0.5, x: 0, y: 0)
                
            }
        }
        .animation(.easeInOut(duration: 0.15), value: isActive)
    }
}

#Preview {
    ZStack {
Rectangle()
            .fill(Color.gray)
        GeometryReader { geometry in
            ArcSegmentView(
                center: CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2),
                radius: 80,
                startAngle: 225,
                endAngle: 315,
                lineWidth: 8,
                isActive: false, // Changed to true to show LED effect
                isFirstBeat: true,
                gapWidth: 10
            )
        }
    }
    .frame(width: 300, height: 300)
}
