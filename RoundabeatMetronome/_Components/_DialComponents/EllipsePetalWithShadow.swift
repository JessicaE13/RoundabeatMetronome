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
    
    // Define light source direction (top-left) - adjusted for indented behavior
    private let lightSourceAngle: Double = 135 // degrees (top-left, but for indented surfaces)
    
    // Calculate the relative angle between light source and this ellipse
    private var relativeAngle: Double {
        let angle = rotationAngle - lightSourceAngle
        return angle.truncatingRemainder(dividingBy: 360)
    }
    
    // Calculate how much this ellipse faces the light (0 = facing away, 1 = facing toward)
    // For indented surfaces, the lighting is inverted
    private var lightIntensity: Double {
        let radians = relativeAngle * .pi / 180
        let rawIntensity = max(0, cos(radians) * 0.5 + 0.5)
        // Reduced intensity for darker overall appearance: 0.1-0.4 instead of 0.2-0.8
        return 0.1 + (rawIntensity * 0.3)
    }
    
    // Calculate shadow intensity (inverse of light intensity, but also softened)
    private var shadowIntensity: Double {
        let rawShadow = 1.0 - ((lightIntensity - 0.1) / 0.3) // Convert back to 0-1 range
        // Increased shadow range for darker overall appearance: 0.3-0.9 instead of 0.15-0.85
        return 0.3 + (rawShadow * 0.6)
    }
    
    // Calculate highlight position based on light direction - for indented surfaces
    // The highlight appears on the side opposite to where it would on a raised surface
    private var highlightPosition: UnitPoint {
        // Invert the direction for indented behavior (add 180 degrees)
        let adjustedAngle = (lightSourceAngle - rotationAngle + 180) * .pi / 180
        let x = 0.5 + cos(adjustedAngle) * 0.4 // Increased offset for more pronounced effect
        let y = 0.5 + sin(adjustedAngle) * 0.4
        return UnitPoint(x: max(0, min(1, x)), y: max(0, min(1, y)))
    }
    
    // Calculate shadow position (opposite of highlight for indented surfaces)
    private var shadowPosition: UnitPoint {
        let adjustedAngle = (lightSourceAngle - rotationAngle) * .pi / 180
        let x = 0.5 + cos(adjustedAngle) * 0.4
        let y = 0.5 + sin(adjustedAngle) * 0.4
        return UnitPoint(x: max(0, min(1, x)), y: max(0, min(1, y)))
    }
    
    var body: some View {
        ZStack {
            // Base darker fill - overall darker appearance
            EllipsePetal()
                .fill(
                    RadialGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color.black.opacity(0.4), location: 0.0),
                            .init(color: Color.black.opacity(0.5), location: 0.3),
                            .init(color: Color.black.opacity(0.6), location: 0.7),
                            .init(color: Color.black.opacity(0.7), location: 1.0)
                        ]),
                        center: .center,
                        startRadius: 2,
                        endRadius: 25
                    )
                )
            
            // Enhanced shadow on the light-facing side (for indented behavior)
            EllipsePetal()
                .fill(
                    RadialGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color.black.opacity(0.2 + shadowIntensity * 0.3), location: 0.0),
                            .init(color: Color.black.opacity(0.3 + shadowIntensity * 0.4), location: 0.4),
                            .init(color: Color.black.opacity(0.4 + shadowIntensity * 0.3), location: 0.8),
                            .init(color: Color.clear, location: 1.0)
                        ]),
                        center: shadowPosition,
                        startRadius: 1,
                        endRadius: 20
                    )
                )
            
            // Subtle highlight on the shadow side (bottom-right when light is top-left)
            EllipsePetal()
                .fill(
                    RadialGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color.white.opacity(0.05 + lightIntensity * 0.1), location: 0.0),
                            .init(color: Color.white.opacity(0.03 + lightIntensity * 0.08), location: 0.4),
                            .init(color: Color.white.opacity(0.02 + lightIntensity * 0.05), location: 0.7),
                            .init(color: Color.clear, location: 1.0)
                        ]),
                        center: highlightPosition,
                        startRadius: 1,
                        endRadius: 18
                    )
                )
            
            // Subtle highlight stroke - much less intense
            EllipsePetal()
                .stroke(
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color.white.opacity(0.08 + lightIntensity * 0.12), location: 0.0),
                            .init(color: Color.white.opacity(0.05 + lightIntensity * 0.08), location: 0.5),
                            .init(color: Color.white.opacity(0.02 + lightIntensity * 0.05), location: 1.0)
                        ]),
                        startPoint: highlightPosition,
                        endPoint: UnitPoint(x: 1 - highlightPosition.x, y: 1 - highlightPosition.y)
                    ),
                    lineWidth: 0.6
                )
                .scaleEffect(0.9)
            
            // Enhanced inner shadow stroke
            EllipsePetal()
                .stroke(
                    RadialGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color.black.opacity(0.2 + shadowIntensity * 0.3), location: 0.0),
                            .init(color: Color.black.opacity(0.3 + shadowIntensity * 0.4), location: 0.5),
                            .init(color: Color.black.opacity(0.4 + shadowIntensity * 0.5), location: 1.0)
                        ]),
                        center: shadowPosition,
                        startRadius: 1,
                        endRadius: 15
                    ),
                    lineWidth: 0.5
                )
                .scaleEffect(0.8)
            
            // Crisp edge definition - slightly more prominent
            EllipsePetal()
                .stroke(Color.black.opacity(0.8), lineWidth: 0.6)
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

#Preview("Single Petal") {
    ZStack {
        Color.black
        EllipsePetalWithDynamicShadow(rotationAngle: 0)
            .frame(width: 50, height: 30)
    }
    .frame(width: 200, height: 200)
}

#Preview("Rotating Petals") {
    ZStack {
        Color.blue
        CircularEllipseBorderView()
    }
}

#Preview("Multiple Angles") {
    ZStack {
        Color.black
        VStack(spacing: 20) {
            HStack(spacing: 20) {
                EllipsePetalWithDynamicShadow(rotationAngle: 0)
                    .frame(width: 40, height: 25)
                Text("0°")
                    .foregroundColor(.white)
                    .font(.caption)
            }
            
            HStack(spacing: 20) {
                EllipsePetalWithDynamicShadow(rotationAngle: 90)
                    .frame(width: 40, height: 25)
                Text("90°")
                    .foregroundColor(.white)
                    .font(.caption)
            }
            
            HStack(spacing: 20) {
                EllipsePetalWithDynamicShadow(rotationAngle: 180)
                    .frame(width: 40, height: 25)
                Text("180°")
                    .foregroundColor(.white)
                    .font(.caption)
            }
            
            HStack(spacing: 20) {
                EllipsePetalWithDynamicShadow(rotationAngle: 270)
                    .frame(width: 40, height: 25)
                Text("270°")
                    .foregroundColor(.white)
                    .font(.caption)
            }
        }
    }
    .frame(width: 300, height: 400)
}
