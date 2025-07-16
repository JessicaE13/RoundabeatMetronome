import SwiftUI

struct EllipsePetal: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        
        // Create an ellipse that fits the rect
        let ellipseRect = CGRect(x: 0, y: 0, width: width, height: height)
        path.addEllipse(in: ellipseRect)
        
        return path
    }
}

struct EllipsePetalWithDynamicShadow: View {
    let rotationAngle: Double // The rotation angle of this specific ellipse
    
    // Define light source direction (top-left)
    private let lightSourceAngle: Double = 315 // degrees (top-left)
    
    // Calculate the relative angle between light source and this ellipse
    private var relativeAngle: Double {
        let angle = rotationAngle - lightSourceAngle
        return angle.truncatingRemainder(dividingBy: 360)
    }
    
    // Calculate how much this ellipse faces the light (0 = facing away, 1 = facing toward)
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
            // Main shadow fill — intensity varies with lighting
            EllipsePetal()
                .fill(
                    RadialGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color.black.opacity(0.1 + shadowIntensity * 0.15), location: 0.0),
                            .init(color: Color.black.opacity(0.15 + shadowIntensity * 0.2), location: 0.3),
                            .init(color: Color.black.opacity(0.25 + shadowIntensity * 0.25), location: 0.7),
                            .init(color: Color.black.opacity(0.35 + shadowIntensity * 0.3), location: 1.0)
                        ]),
                        center: .center,
                        startRadius: 2,
                        endRadius: 25
                    )
                )
            
            // Directional shadow — varies based on light position
            EllipsePetal()
                .fill(
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color.clear, location: 0.0),
                            .init(color: Color.black.opacity(0.1 + shadowIntensity * 0.15), location: 0.3),
                            .init(color: Color.black.opacity(0.2 + shadowIntensity * 0.25), location: 0.7),
                            .init(color: Color.black.opacity(0.15 + shadowIntensity * 0.2), location: 1.0)
                        ]),
                        startPoint: UnitPoint(x: highlightPosition.x, y: highlightPosition.y),
                        endPoint: UnitPoint(x: 1 - highlightPosition.x, y: 1 - highlightPosition.y)
                    )
                )
            
            // Dynamic highlight — positioned based on light source
            EllipsePetal()
                .fill(
                    RadialGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color.white.opacity(0.15 + lightIntensity * 0.2), location: 0.0),
                            .init(color: Color.white.opacity(0.1 + lightIntensity * 0.15), location: 0.4),
                            .init(color: Color.white.opacity(0.05 + lightIntensity * 0.1), location: 0.7),
                            .init(color: Color.clear, location: 1.0)
                        ]),
                        center: highlightPosition,
                        startRadius: 1,
                        endRadius: 15
                    )
                )
            
            // Dynamic highlight stroke — stronger on lit side
            EllipsePetal()
                .stroke(
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color.white.opacity(0.2 + lightIntensity * 0.2), location: 0.0),
                            .init(color: Color.white.opacity(0.15 + lightIntensity * 0.15), location: 0.5),
                            .init(color: Color.white.opacity(0.1 + lightIntensity * 0.1), location: 1.0)
                        ]),
                        startPoint: UnitPoint(x: highlightPosition.x, y: highlightPosition.y),
                        endPoint: UnitPoint(x: 1 - highlightPosition.x, y: 1 - highlightPosition.y)
                    ),
                    lineWidth: 0.8
                )
                .scaleEffect(0.9)
            
            // Inner shadow stroke — stronger on shadow side
            EllipsePetal()
                .stroke(
                    RadialGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color.black.opacity(0.1 + shadowIntensity * 0.2), location: 0.0),
                            .init(color: Color.black.opacity(0.2 + shadowIntensity * 0.3), location: 0.5),
                            .init(color: Color.black.opacity(0.3 + shadowIntensity * 0.4), location: 1.0)
                        ]),
                        center: UnitPoint(x: 1 - highlightPosition.x, y: 1 - highlightPosition.y),
                        startRadius: 1,
                        endRadius: 12
                    ),
                    lineWidth: 0.4
                )
                .scaleEffect(0.8)
            
            // Crisp edge definition
            EllipsePetal()
                .stroke(Color.black.opacity(0.6), lineWidth: 0.5)
        }
    }
}

struct CircularEllipseBorderView: View {
    let petalCount = 30
    @State private var currentRotation: Double = 0
    
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
            
            // Rotating ellipse petals
            ZStack {
                ForEach(0..<petalCount, id: \.self) { i in
                    let baseRotation = Double(i) * (360.0 / Double(petalCount))
                    let totalRotation = baseRotation + currentRotation
                    
                    EllipsePetalWithDynamicShadow(rotationAngle: totalRotation)
                        .frame(width: 16, height: 10) // Elliptical shape - wider than tall
                        .offset(y: -150)
                        .rotationEffect(.degrees(baseRotation))
                }
            }
            .rotationEffect(.degrees(currentRotation))
            .onAppear {
                // Animate the rotation
                withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                    currentRotation = 360
                }
            }
        }
        .frame(width: 340, height: 340)
    }
}

// Legacy component for backwards compatibility
struct EllipsePetalWithShadow: View {
    var body: some View {
        EllipsePetalWithDynamicShadow(rotationAngle: 0)
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
        
        CircularEllipseBorderView()
    }
}
