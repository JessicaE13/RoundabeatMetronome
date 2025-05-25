import SwiftUI
import AVFoundation

extension Color {
    func darker(by percentage: CGFloat = 0.1) -> Color {
        return self.opacity(1.0 - percentage)
    }
}

struct DialControl: View {
    @ObservedObject var metronome: MetronomeEngine
    @State private var dialRotation: Double = 0.0
    @State private var previousAngle: Double?
    @State private var isDragging = false
    @State private var isKnobTouched = false
    @State private var numberOfTicks: Int = 50

    private let dialSize: CGFloat = 250
    private let knobSize: CGFloat = 90
    private let innerDonutRatio: CGFloat = 0.35
    private let minRotation: Double = -150
    private let maxRotation: Double = 150
    private let ringLineWidth: CGFloat = 27
    private let tickLength: CGFloat = 50
    
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
        Circle()
            .fill(Color.black.opacity(0.9))
            .frame(width: dialSize, height: dialSize)
            .shadow(color: Color.black.opacity(0.3), radius: 6, x: 0, y: 4)
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
            .fill(isKnobTouched ? Color.white.opacity(0.5) : Color.white.opacity(0.2))
            .frame(width: 1.0, height: tickLength)
            .offset(y: (dialSize / 2.4 - tickLength) * -1)
            // Apply slant first with bottom anchor (where tick connects to circle)
            .rotationEffect(.degrees(tickSlantAngle), anchor: .bottom)
            // Then position around the circle
            .rotationEffect(.degrees(tickAngle))
            // Add glow effect when knob is touched
            .shadow(
                color: isKnobTouched ? Color.white.opacity(0.8) : Color.clear,
                radius: isKnobTouched ? 3 : 0,
                x: 0,
                y: 0
            )
    }

    private var segmentedRing: some View {
        // Now using the convenience initializer from the extension
        SegmentedCircleView(metronome: metronome, diameter: dialSize + 80, lineWidth: ringLineWidth)
    }

    private var centerKnob: some View {
        ZStack {
            Circle()
                .fill(Color("colorDial"))
                .frame(width: knobSize, height: knobSize)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.6), lineWidth: 0.2)
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
            .foregroundColor(Color.white.opacity(metronome.isPlaying ? 0.9 : 0.8))
            .shadow(color: Color("colorPurpleBackground").opacity(0.7), radius: 0)
    }
    
    // Functions to control tick count
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
