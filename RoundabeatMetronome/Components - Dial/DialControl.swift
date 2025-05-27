import SwiftUI

struct DialGradientMesh: View {
    @State private var animateGradient = false
    
    var body: some View {
        ZStack {
            // Base radial gradient - reduced contrast
            RadialGradient(
                gradient: Gradient(colors: [
                    Color.black.opacity(0.6),
                    Color.white.opacity(0.08),
                    Color.black.opacity(0.7)
                ]),
                center: .center,
                startRadius: 50,
                endRadius: 200
            )

            // Animated mesh overlay - reduced contrast monochromatic
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
                    // Top Row - reduced contrast grayscale variations
                    Color.white.opacity(0.06),
                    Color.white.opacity(0.08),
                    Color.white.opacity(0.05),
                    // Middle Row
                    Color.black.opacity(0.65),
                    Color.black.opacity(0.7),
                    Color.white.opacity(0.04),
                    // Bottom Row
                    Color.white.opacity(0.05),
                    Color.white.opacity(0.07),
                    Color.white.opacity(0.04)
                ]
            )
            .opacity(0.6)
        }
    }
}

// Updated DialControl with reduced contrast and flat play button
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
    
    // Additional circle size (10px smaller than dial)
    private var additionalCircleSize: CGFloat { dialSize - 43 }

    init(metronome: MetronomeEngine) {
        self.metronome = metronome
        self._dialRotation = State(initialValue: tempoToRotation(metronome.tempo))
    }

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                dialBackground
                segmentedRing
                additionalCircle
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
            // Subtle outer shadow - reduced contrast
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.clear,
                            Color.clear,
                            Color.black.opacity(0.08),
                            Color.black.opacity(0.2)
                        ]),
                        center: .center,
                        startRadius: dialSize * 0.45,
                        endRadius: dialSize * 0.6
                    )
                )
                .frame(width: dialSize + 20, height: dialSize + 20)
                .blur(radius: 2)
            
            // Main dial body with reduced contrast 3D beveled edge
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.gray.opacity(0.25),
                            Color.black.opacity(0.45),
                            Color.black.opacity(0.65)
                        ]),
                        center: UnitPoint(x: 0.3, y: 0.3), // Light source from top-left
                        startRadius: 20,
                        endRadius: dialSize * 0.7
                    )
                )
                .frame(width: dialSize, height: dialSize)
                .overlay(
                    // Reduced highlight ring on the edge
                    Circle()
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.15),
                                    Color.clear,
                                    Color.black.opacity(0.2)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
            
            // Recessed inner surface - reduced contrast
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.black.opacity(0.6),
                            Color.gray.opacity(0.08),
                            Color.black.opacity(0.7)
                        ]),
                        center: UnitPoint(x: 0.7, y: 0.7), // Inverted lighting for recess
                        startRadius: 30,
                        endRadius: dialSize * 0.4
                    )
                )
                .frame(width: dialSize - 30, height: dialSize - 30)
                .shadow(color: Color.black.opacity(0.4), radius: 6, x: 0, y: 0)
            
            // Gradient mesh as the dial face texture - rotates with dial
            DialGradientMesh()
                .frame(width: dialSize - 40, height: dialSize - 40)
                .clipShape(Circle())
                .rotationEffect(Angle(degrees: dialRotation))
                .opacity(0.5)
            
            // Inner shadow for depth - reduced
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.clear,
                            Color.clear,
                            Color.black.opacity(0.2)
                        ]),
                        center: .center,
                        startRadius: dialSize * 0.25,
                        endRadius: dialSize * 0.45
                    )
                )
                .frame(width: dialSize - 30, height: dialSize - 30)
            

        }
        .shadow(color: Color.black.opacity(0.25), radius: 12, x: 0, y: 8)
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
            .fill(isKnobTouched ? Color.white.opacity(0.6) : Color.white.opacity(0.15))
            .frame(width: 1.0, height: tickLength)
            .offset(y: (dialSize / 2.4 - tickLength) * -1)
            // Apply slant first with bottom anchor (where tick connects to circle)
            .rotationEffect(.degrees(tickSlantAngle), anchor: .bottom)
            // Then position around the circle
            .rotationEffect(.degrees(tickAngle))
            // Reduced glow effect
            .shadow(
                color: isKnobTouched ? Color.white.opacity(0.6) : Color.white.opacity(0.08),
                radius: isKnobTouched ? 3 : 0.5,
                x: 0,
                y: 0
            )
    }
    
    private var additionalCircle: some View {
        Circle()
            .stroke(
                isKnobTouched ? Color.white.opacity(0.4) : Color.white.opacity(0.12),
                lineWidth: 0.75
            )
            .frame(width: additionalCircleSize, height: additionalCircleSize)
            .shadow(
                color: isKnobTouched ? Color.white.opacity(0.6) : Color.white.opacity(0.08),
                radius: isKnobTouched ? 3 : 0.5,
                x: 0,
                y: 0
            )
    }

    private var segmentedRing: some View {
        SegmentedCircleView(metronome: metronome, diameter: dialSize + 80, lineWidth: ringLineWidth)
    }

    private var centerKnob: some View {
        ZStack {
            // Flat knob with minimal depth
            Circle()
                .fill(Color.black.opacity(0.8))
                .frame(width: knobSize, height: knobSize)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
            
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
            .foregroundColor(Color.white.opacity(0.7))
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
