import SwiftUI

struct DialView: View {
    
    @ObservedObject var metronome: MetronomeEngine
    
    @State private var dialRotation: Double = 0.0
    @State private var previousAngle: Double?
    @State private var isDragging = false
    @State private var isKnobTouched = false
    @State private var numberOfTicks: Int = 50
    
    private let dialSize: CGFloat = 225
    private let knobSize: CGFloat = 90
    private let innerDonutRatio: CGFloat = 0.35
    private let minRotation: Double = -150
    private let maxRotation: Double = 150
    private let ringLineWidth: CGFloat = 27
    private let tickLength: CGFloat = 40
    private let minTicks: Int = 12
    private let maxTicks: Int = 120
    private let tickSlantAngle: Double = -60.0
    private var innerDonutDiameter: CGFloat { knobSize + 4 }
    private var additionalCircleSize: CGFloat { dialSize - 43 }
    
    var body: some View {
        
        ZStack{
            
            SegmentedCircleView(
                metronome: metronome,
                diameter: dialSize + 80,
                lineWidth: ringLineWidth)
            
            //Main Circle Background
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 28/255, green: 28/255, blue: 29/255),
                            Color(red: 24/255, green: 24/255, blue: 25/255)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: dialSize)
                .shadow(color: .black.opacity(0.4), radius: 12, x: 0, y: 6)

            // Main Circle Dark Outline (matching knob style)
            Circle()
                .stroke(Color(red: 1/255, green: 1/255, blue: 2/255), lineWidth: 3.0)
                .frame(width: dialSize)

            // Main Circle Outer Highlight (matching knob style)
            Circle()
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 101/255, green: 101/255, blue: 102/255).opacity(0.3),
                            Color(red: 101/255, green: 101/255, blue: 102/255).opacity(0.3),
                            Color(red: 101/255, green: 101/255, blue: 102/255).opacity(0.3),
                            Color(red: 101/255, green: 101/255, blue: 102/255).opacity(0.6)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.5
                )
                .frame(width: dialSize + 3)

            // Main Circle Inner Highlight (matching knob style)
            Circle()
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 101/255, green: 101/255, blue: 102/255).opacity(0.6),
                            Color(red: 101/255, green: 101/255, blue: 102/255).opacity(0.3),
                            Color(red: 101/255, green: 101/255, blue: 102/255).opacity(0.3),
                            Color(red: 101/255, green: 101/255, blue: 102/255).opacity(0.3)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.5
                )
                .frame(width: dialSize - 3)
            
            //Center Knob
            Circle()
                .stroke(Color(red: 1/255, green: 1/255, blue: 2/255), lineWidth: 3.0)
                .frame(width: knobSize, height: knobSize)
            
            //Center Knob outer highlight
            Circle()
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 101/255, green: 101/255, blue: 102/255).opacity(0.3),
                            Color(red: 101/255, green: 101/255, blue: 102/255).opacity(0.3),
                            Color(red: 101/255, green: 101/255, blue: 102/255).opacity(0.3),
                            Color(red: 101/255, green: 101/255, blue: 102/255).opacity(0.6)
                            
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.5
                )
                .frame(width: knobSize+3, height: knobSize+3)
            
            //Center Knob inner highlight
            Circle()
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 101/255, green: 101/255, blue: 102/255).opacity(0.6),
                            Color(red: 101/255, green: 101/255, blue: 102/255).opacity(0.3),
                            Color(red: 101/255, green: 101/255, blue: 102/255).opacity(0.3),
                            Color(red: 101/255, green: 101/255, blue: 102/255).opacity(0.3)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.5
                )
                .frame(width: knobSize-3, height: knobSize-3)
            
            // Play/Pause Icon
            Image(systemName: metronome.isPlaying ? "stop.fill" : "play.fill")
                .font(.system(size: 30))
                .foregroundStyle(
                    RadialGradient(
                        colors: [
                            Color(red: 249/255, green: 250/255, blue: 252/255),
                            Color(red: 187/255, green: 189/255, blue: 192/255)
                        ],
                        center: UnitPoint(x: 0.35, y: 0.5),
                        startRadius: 6,
                        endRadius: 20
                    )
                )
                .onTapGesture {
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    metronome.togglePlayback()
                }
        }
    }
}

#Preview {
    DialView(metronome: MetronomeEngine())
}
