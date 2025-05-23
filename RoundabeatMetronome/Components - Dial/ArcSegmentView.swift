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

            // Always show a faint outer structure
            arcPath
                .stroke(Color.white.opacity(0.1),
                        style: StrokeStyle(lineWidth: lineWidth + 2, lineCap: .round))

            if isActive {
                // Active arc - solid and glowy
                arcPath
                    .stroke(Color.white.opacity(0.9),
                            style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                    .shadow(color: Color.white.opacity(0.2), radius: 4)
                    .blur(radius: 2)

                arcPath
                    .stroke(Color.gray.opacity(0.4),
                            style: StrokeStyle(lineWidth: lineWidth + 6, lineCap: .round))
                    .blur(radius: 10)
            } else {
                // Outline effect: simulate a ring by layering two strokes
                let backgroundGradient = LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 44/255, green: 44/255, blue: 44/255),
                        Color(red: 20/255, green: 20/255, blue: 20/255)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                    )
                ZStack {
                    arcPath
                        .stroke(Color.white.opacity(0.3),
                                style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))

                    arcPath
                        .stroke(backgroundGradient,
                                style: StrokeStyle(lineWidth: lineWidth - 0.25, lineCap: .round))
                }
                .compositingGroup() // Helps blend the layers nicely
            }
        }
        .animation(.easeInOut(duration: 0.1), value: isActive)
    }
}

#Preview {
    ZStack {
        Color.black.opacity(0.8).ignoresSafeArea()

        GeometryReader { geometry in
            ArcSegmentView(
                center: CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2),
                radius: 80,
                startAngle: 225,
                endAngle: 315,
                lineWidth: 12,
                isActive: false,
                isFirstBeat: true,
                gapWidth: 10
            )
        }
    }
    .frame(width: 300, height: 300)
}

