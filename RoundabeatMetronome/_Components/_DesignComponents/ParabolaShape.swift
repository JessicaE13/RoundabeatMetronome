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

struct ParabolaPetalWithDynamicShadow: View {
    let rotationAngle: Double // The rotation angle of this specific parabola
    
    // Define light source direction (top-left)
    private let lightSourceAngle: Double = 315 // degrees (top-left)
    
    // Calculate the relative angle between light source and this parabola
    private var relativeAngle: Double {
        let angle = rotationAngle - lightSourceAngle
        return angle.truncatingRemainder(dividingBy: 360)
    }
    
    // Calculate how much this parabola faces the light (0 = facing away, 1 = facing toward)
    private var lightIntensity: Double {
        let radians = relativeAngle * .pi / 180
        let rawIntensity = max(0, cos(radians) * 0.5 + 0.5)
        // Soften the contrast: reduce range from 0-1 to 0.2-0.8
        return 0.2 + (rawIntensity * 0.6)
    }
    
    // Calculate shadow intensity (inverse of light intensity, but also softened)
    private var shadowIntensity: Double {
        let rawShadow = 1.0 - ((lightIntensity - 0.2) / 0.6) // Convert back to 0-1 range
        // Soften shadows: reduce range from 0-1 to 0.15-0.85
        return 0.15 + (rawShadow * 0.7)
    }
    
    // Calculate highlight position based on light direction
    private var highlightPosition: UnitPoint {
        let adjustedAngle = (lightSourceAngle - rotationAngle) * .pi / 180
        let x = 0.5 + cos(adjustedAngle) * 0.3
        let y = 0.5 + sin(adjustedAngle) * 0.3
        return UnitPoint(x: max(0, min(1, x)), y: max(0, min(1, y)))
    }
    
    var body: some View {
        ZStack {
            // Main vertical shadow fill — intensity varies with lighting
            ParabolaPetal()
                .fill(
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color.black.opacity(0.25 + shadowIntensity * 0.2), location: 0.0),
                            .init(color: Color.black.opacity(0.18 + shadowIntensity * 0.17), location: 0.5),
                            .init(color: Color.black.opacity(0.08 + shadowIntensity * 0.12), location: 0.85),
                            .init(color: Color.clear, location: 1.0)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            
            // Directional shadow — varies based on light position
            ParabolaPetal()
                .fill(
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color.clear, location: 0.0),
                            .init(color: Color.black.opacity(0.12 + shadowIntensity * 0.15), location: 0.5),
                            .init(color: Color.black.opacity(0.16 + shadowIntensity * 0.2), location: 0.85),
                            .init(color: Color.clear, location: 1.0)
                        ]),
                        startPoint: UnitPoint(x: highlightPosition.x, y: highlightPosition.y),
                        endPoint: UnitPoint(x: 1 - highlightPosition.x, y: 1 - highlightPosition.y)
                    )
                )
                .mask(
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color.white, location: 0.0),
                            .init(color: Color.white.opacity(0.4), location: 0.7),
                            .init(color: Color.clear, location: 1.0)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            
            // Dynamic highlight — positioned based on light source
            ParabolaPetal()
                .fill(
                    RadialGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color.white.opacity(0.08 + lightIntensity * 0.12), location: 0.0),
                            .init(color: Color.white.opacity(0.06 + lightIntensity * 0.1), location: 0.3),
                            .init(color: Color.white.opacity(0.04 + lightIntensity * 0.08), location: 0.6),
                            .init(color: Color.clear, location: 1.0)
                        ]),
                        center: highlightPosition,
                        startRadius: 2,
                        endRadius: 15
                    )
                )
                .mask(
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color.white.opacity(0.6 + lightIntensity * 0.4), location: 0.0),
                            .init(color: Color.white.opacity(0.3 + lightIntensity * 0.3), location: 0.4),
                            .init(color: Color.clear, location: 0.8)
                        ]),
                        startPoint: highlightPosition,
                        endPoint: UnitPoint(x: 1 - highlightPosition.x, y: 1 - highlightPosition.y)
                    )
                )
            
            // Dynamic highlight stroke — stronger on lit side
            ParabolaPetal()
                .stroke(
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color.white.opacity(0.15 + lightIntensity * 0.15), location: 0.0),
                            .init(color: Color.white.opacity(0.08 + lightIntensity * 0.1), location: 0.3),
                            .init(color: Color.white.opacity(0.04 + lightIntensity * 0.08), location: 0.6),
                            .init(color: Color.clear, location: 1.0)
                        ]),
                        startPoint: highlightPosition,
                        endPoint: UnitPoint(x: 1 - highlightPosition.x, y: 1 - highlightPosition.y)
                    ),
                    lineWidth: 0.8
                )
                .scaleEffect(0.95)
            
            // Inner shadow line — stronger on shadow side
            ParabolaPetal()
                .stroke(
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color.black.opacity(0.2 + shadowIntensity * 0.3), location: 0.0),
                            .init(color: Color.black.opacity(0.15 + shadowIntensity * 0.2), location: 0.5),
                            .init(color: Color.clear, location: 1.0)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 0.3
                )
                .scaleEffect(0.88)
            
            // Crisp black edge
            ParabolaPetal()
                .stroke(Color.black, lineWidth: 0.5)
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
                let rotationAngle = Double(i) * (360.0 / Double(petalCount))
                
                ParabolaPetalWithDynamicShadow(rotationAngle: rotationAngle)
                    .frame(width: 20, height: 20)
                    .scaleEffect(x: 1, y: -1) // this flips the petal upside down
                    .offset(y: -150)
                    .rotationEffect(.degrees(rotationAngle))
            }
        }
        .frame(width: 340, height: 340)
    }
}

// Legacy component for backwards compatibility
struct ParabolaPetalWithShadow: View {
    var body: some View {
        ParabolaPetalWithDynamicShadow(rotationAngle: 0)
    }
}

#Preview {
    ZStack {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 80/255, green: 80/255, blue: 90/255),
                Color(red: 40/255, green: 40/255, blue: 50/255)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
        
        CircularParabolaBorderView()
    }
}
