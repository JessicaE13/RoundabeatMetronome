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
            // Main vertical shadow fill — now much darker and more pronounced
            ParabolaPetal()
                .fill(
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color.black.opacity(0.5), location: 0.0),
                            .init(color: Color.black.opacity(0.35), location: 0.5),
                            .init(color: Color.black.opacity(0.15), location: 0.85),
                            .init(color: Color.clear, location: 1.0)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            
            // Directional right-side shadow — deeper, with a heavier gradient
            ParabolaPetal()
                .fill(
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color.clear, location: 0.0),
                            .init(color: Color.black.opacity(0.25), location: 0.5),
                            .init(color: Color.black.opacity(0.35), location: 0.85),
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
                            .init(color: Color.white.opacity(0.4), location: 0.7),
                            .init(color: Color.clear, location: 1.0)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            
            // Highlight stroke — still subtle, for contrast against the dark shadows
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
            
            // Inner shadow line — much darker for strong base definition
            ParabolaPetal()
                .stroke(
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color.black.opacity(0.4), location: 0.0),
                            .init(color: Color.black.opacity(0.25), location: 0.5),
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
                ParabolaPetalWithShadow()
                    .frame(width: 20, height: 20)
                    .scaleEffect(x: 1, y: -1) // this flips the petal upside down
                    .offset(y: -150)
                    .rotationEffect(.degrees(Double(i) * (360.0 / Double(petalCount))))
            }
        }
        .frame(width: 340, height: 340)
        
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
