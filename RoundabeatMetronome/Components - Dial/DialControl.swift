import SwiftUI

struct DialGradientMesh: View {
    @State private var animateGradient = false
    
    var body: some View {
        ZStack {
            // Base radial gradient
//            RadialGradient(
//                gradient: Gradient(colors: [
//                    Color.black.opacity(0.95),
//                    Color("colorPurpleBackground").opacity(0.3),
//                    Color.black.opacity(0.98)
//                ]),
//                center: .center,
//                startRadius: 50,
//                endRadius: 200
//            )
//            
            // Animated mesh overlay
            MeshGradient(
                width: 3,
                height: 3,
                points: [
                    // Top row
                    [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                    // Middle row
                    [0.0, 0.5], [0.5, 0.5], [1.0, 0.5],
                    // Bottom row
                    [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
                ],
                colors: [
                        //Top Row
                        Color(red: 82/255, green: 78/255, blue: 113/255),
                        Color(red: 149/255, green: 119/255, blue: 154/255),
                        Color(red: 197/255, green: 147/255, blue: 173/255),
                        //Middle Row
                        Color(red: 27/255, green: 24/255, blue: 57/255),
                        Color(red: 26/255, green: 18/255, blue: 37/255),
                        Color(red: 152/255, green: 83/255, blue: 104/255),
                        // Bottom Row
                        Color(red: 116/255, green: 95/255, blue: 128/255),
                        Color(red: 130/255, green: 101/255, blue: 132/255),
                        Color(red: 130/255, green: 90/255, blue: 115/255)
                    
                ]
            )
            .opacity(0.8)
//            .animation(
//                Animation.easeInOut(duration: 3.0)
//                    .repeatForever(autoreverses: true),
//                value: animateGradient
//            )
            
            // Additional radial highlights
//            RadialGradient(
//                gradient: Gradient(colors: [
//                    Color.white.opacity(animateGradient ? 0.05 : 0.02),
//                    Color.clear
//                ]),
//                center: UnitPoint(x: 0.3, y: 0.3),
//                startRadius: 0,
//                endRadius: 120
//            )
//            .animation(
//                Animation.easeInOut(duration: 4.0)
//                    .repeatForever(autoreverses: true),
//                value: animateGradient
//            )
//            
//            RadialGradient(
//                gradient: Gradient(colors: [
//                    Color("colorPurpleBackground").opacity(animateGradient ? 0.15 : 0.08),
//                    Color.clear
//                ]),
//                center: UnitPoint(x: 0.7, y: 0.8),
//                startRadius: 0,
//                endRadius: 100
//            )
//            .animation(
//                Animation.easeInOut(duration: 5.0)
//                    .repeatForever(autoreverses: true),
//                value: animateGradient
//            )
//        }
//        .onAppear {
//            animateGradient = true
       }
  }
}

// Updated DialControl with gradient mesh background
struct DialControl: View {
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
    
    // Tick count constraints
    private let minTicks: Int = 12
    private let maxTicks: Int = 120
    
    // Slant angle for tick marks (in degrees)
    private let tickSlantAngle: Double = -60.0

    private var innerDonutDiameter: CGFloat { knobSize + 4 }

    init(metronome: MetronomeEngine) {
        self.metronome = metronome
        self._dialRotation = State(initialValue: tempoToRotation(metronome.tempo))
    }

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                dialBackground
                segmentedRing
                centerKnob
            }
            .frame(width: dialSize + 55, height: dialSize + 55)
            .gesture(createDragGesture())
            .onChange(of: metronome.tempo) { _, newTempo in
                dialRotation = tempoToRotation(newTempo)
            }
            .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
                isKnobTouched = pressing
            }, perform: {})
        }
    }

    private var dialBackground: some View {
        ZStack {
            // Gradient mesh as the dial face - rotates with dial
            DialGradientMesh()
                .frame(width: dialSize, height: dialSize)
                .clipShape(Circle())
                .rotationEffect(Angle(degrees: dialRotation))
            
            // Subtle overlay to maintain depth
            Circle()
                .fill(Color.black.opacity(0.2))
                .frame(width: dialSize, height: dialSize)
        }
        .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
        .overlay(dialTickMarks)
    }

    private var dialTickMarks: some View {
        ZStack {
            ForEach(0..<numberOfTicks, id: \.self) { index in
                tickMark(at: index)
            }
        }
        .rotationEffect(Angle(degrees: dialRotation))
    }

    private func tickMark(at index: Int) -> some View {
        let tickAngle = Double(index) * (360.0 / Double(numberOfTicks))
        
        return Rectangle()
            .fill(isKnobTouched ? Color.white.opacity(0.6) : Color.white.opacity(0.3))
            .frame(width: 1.0, height: tickLength)
            .offset(y: (dialSize / 2.4 - tickLength) * -1)
            // Apply slant first with bottom anchor (where tick connects to circle)
            .rotationEffect(.degrees(tickSlantAngle), anchor: .bottom)
            // Then position around the circle
            .rotationEffect(.degrees(tickAngle))
            // Enhanced glow effect
            .shadow(
                color: isKnobTouched ? Color.white.opacity(0.9) : Color.white.opacity(0.1),
                radius: isKnobTouched ? 4 : 1,
                x: 0,
                y: 0
            )
    }

    private var segmentedRing: some View {
        SegmentedCircleView(metronome: metronome, diameter: dialSize + 80, lineWidth: ringLineWidth)
    }

    private var centerKnob: some View {
        ZStack {
            // Enhanced knob with gradient
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color("colorDial").opacity(0.9),
                            Color("colorDial").opacity(0.6)
                        ]),
                        center: UnitPoint(x: 0.3, y: 0.3),
                        startRadius: 5,
                        endRadius: knobSize/2
                    )
                )
                .frame(width: knobSize, height: knobSize)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.7), lineWidth: 0.3)
                )
                .shadow(color: Color.black.opacity(0.3), radius: 4, x: 2, y: 2)
            
            playPauseIcon
        }
        .onTapGesture {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            metronome.togglePlayback()
        }
    }

    private var playPauseIcon: some View {
        Image(systemName: metronome.isPlaying ? "stop.fill" : "play.fill")
            .font(.system(size: 30))
            .foregroundColor(Color.white.opacity(metronome.isPlaying ? 0.95 : 0.85))
            .shadow(color: Color("colorPurpleBackground").opacity(0.8), radius: 1)
    }
    
    // Rest of the methods remain the same...
    private func increaseTickCount() {
        if numberOfTicks < maxTicks {
            numberOfTicks += 6
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
    }
    
    private func decreaseTickCount() {
        if numberOfTicks > minTicks {
            numberOfTicks -= 6
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
    }

    private func createDragGesture() -> some Gesture {
        DragGesture(minimumDistance: 1)
            .onChanged { value in
                if !isKnobTouched { isKnobTouched = true }
                handleDragChange(value)
            }
            .onEnded { _ in
                isDragging = false
                isKnobTouched = false
                previousAngle = nil
            }
    }

    private func handleDragChange(_ value: DragGesture.Value) {
        isDragging = true
        let center = CGPoint(x: dialSize / 2, y: dialSize / 2)
        let angle = calculateAngle(center: center, point: value.location)
        guard let prevAngle = previousAngle else { previousAngle = angle; return }
        let angleDelta = calculateAngleDelta(from: prevAngle, to: angle)
        let tempoChange = angleDelta * 0.4
        let oldTempo = metronome.tempo
        let newTempo = metronome.tempo + tempoChange
        metronome.updateTempo(to: newTempo)
        if Int(oldTempo) != Int(newTempo) {
            let generator = UIImpactFeedbackGenerator(style: .soft)
            generator.impactOccurred(intensity: 0.5)
        }
        previousAngle = angle
    }

    private func calculateAngleDelta(from prevAngle: Double, to currentAngle: Double) -> Double {
        var delta = currentAngle - prevAngle
        if delta > 180 { delta -= 360 } else if delta < -180 { delta += 360 }
        return delta
    }

    private func tempoToRotation(_ tempo: Double) -> Double {
        let tempoRange = metronome.maxTempo - metronome.minTempo
        let rotationRange = maxRotation - minRotation
        return minRotation + (tempo - metronome.minTempo) / tempoRange * rotationRange
    }

    private func calculateAngle(center: CGPoint, point: CGPoint) -> Double {
        var degrees = atan2(point.y - center.y, point.x - center.x) * 180 / .pi
        if degrees < 0 { degrees += 360 }
        return degrees
    }
}

#Preview {
    ZStack {
        BackgroundView()
        DialControl(metronome: MetronomeEngine())
    }
}
