import SwiftUI

struct ParabolaPetal: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        
        let midX = width / 2
        
        for x in stride(from: -midX, through: midX, by: 1) {
            let normalizedX = x / midX  // range: -1 to 1
            let y = 1 - (normalizedX * normalizedX)
            let point = CGPoint(x: midX + x, y: height * (1 - y))
            
            if x == -midX {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        
        return path
    }
}

struct ParabolaPetalWithShadow: View {
    var body: some View {
        ZStack {
            // Main shadow fill - stronger at top, fading to transparent at bottom
            ParabolaPetal()
                .fill(
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color.black.opacity(0.12), location: 0.0),
                            .init(color: Color.black.opacity(0.06), location: 0.4),
                            .init(color: Color.black.opacity(0.02), location: 0.8),
                            .init(color: Color.clear, location: 1.0)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            
            // Right side shadow for directional lighting
            ParabolaPetal()
                .fill(
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color.clear, location: 0.0),
                            .init(color: Color.black.opacity(0.04), location: 0.5),
                            .init(color: Color.black.opacity(0.08), location: 0.8),
                            .init(color: Color.clear, location: 1.0)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .mask(
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color.white, location: 0.0),
                            .init(color: Color.white.opacity(0.3), location: 0.7),
                            .init(color: Color.clear, location: 1.0)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            
            // Subtle top-left highlight
            ParabolaPetal()
                .stroke(
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color.white.opacity(0.15), location: 0.0),
                            .init(color: Color.white.opacity(0.05), location: 0.3),
                            .init(color: Color.clear, location: 0.6)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.5
                )
                .scaleEffect(0.95)
            
            // Inner edge shadow - more subtle and natural
            ParabolaPetal()
                .stroke(
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color.black.opacity(0.1), location: 0.0),
                            .init(color: Color.black.opacity(0.04), location: 0.5),
                            .init(color: Color.clear, location: 1.0)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 0.3
                )
                .scaleEffect(0.88)
            
            // Original stroke outline
            ParabolaPetal()
                .stroke(Color.gray, lineWidth: 1.5)
        }
    }
}

struct CircularParabolaBorderView: View {
    let petalCount = 30
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray, lineWidth: 1)
                .frame(width: 340, height: 340)
            
            Circle()
                .fill(Color.gray)
                .opacity(0.2)
                .padding(20)
                .frame(width: 300, height: 300)
            
            ForEach(0..<petalCount, id: \.self) { i in
                ParabolaPetalWithShadow()
                    .frame(width: 20, height: 20)
                    .scaleEffect(x: 1, y: -1) // this flips the petal upside down
                    .offset(y: -150)
                    .rotationEffect(.degrees(Double(i) * (360.0 / Double(petalCount))))
            }
        }
        .frame(width: 340, height: 340)
        .background(Color.white)
    }
}

#Preview {
    CircularParabolaBorderView()
}
