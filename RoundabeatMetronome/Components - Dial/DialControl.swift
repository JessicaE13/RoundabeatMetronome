import SwiftUI

struct DialControl: View {
    @ObservedObject var metronome: MetronomeEngine
    @State private var dialRotation: Double = 0.0
    @State private var previousAngle: Double?
    @State private var isDragging = false
    @State private var isKnobTouched = false

    private let dialSize: CGFloat = 225
    private let knobSize: CGFloat = 90
    private let innerDonutRatio: CGFloat = 0.35
    
    // Changed: Now uses 5 full rotations (1800 degrees total)
    private let minRotation: Double = -900  // -5 * 180 = -900 degrees
    private let maxRotation: Double = 900   // +5 * 180 = +900 degrees
    
    private let ringLineWidth: CGFloat = 24
    private var innerDonutDiameter: CGFloat { knobSize + 4 }

    init(metronome: MetronomeEngine) {
        self.metronome = metronome
        self._dialRotation = State(initialValue: tempoToRotation(metronome.tempo))
    }

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                segmentedRing
                dialBackground
                centerKnob
            }
            .frame(width: dialSize + 55, height: dialSize + 55)
            .gesture(createDragGesture())
            .onChange(of: metronome.tempo) { _, newTempo in
                // Only update dial rotation if we're not currently dragging
                // This prevents conflicts between user input and programmatic updates
                if !isDragging {
                    dialRotation = tempoToRotation(newTempo)
                }
            }
            .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
                isKnobTouched = pressing
            }, perform: {})
        }
    }

    private var dialBackground: some View {
        ZStack {
            // Main Circle Background - darker color
            Circle()
                .fill(Color(red: 7/255, green: 7/255, blue: 8/255))
                .frame(width: dialSize, height: dialSize)
                .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)

            // Main Circle Dark Outline - subtle inner shadow effect
            Circle()
                .stroke(Color(red: 2/255, green: 2/255, blue: 3/255), lineWidth: 2.0)
                .frame(width: dialSize, height: dialSize)

            // Outer highlight ring - simulates light hitting the raised edge
            Circle()
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 85/255, green: 85/255, blue: 86/255).opacity(0.4),
                            Color(red: 65/255, green: 65/255, blue: 66/255).opacity(0.2),
                            Color(red: 45/255, green: 45/255, blue: 46/255).opacity(0.1),
                            Color(red: 25/255, green: 25/255, blue: 26/255).opacity(0.05)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.0
                )
                .frame(width: dialSize + 2, height: dialSize + 2)

            // Inner shadow ring - creates depth
            Circle()
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 25/255, green: 25/255, blue: 26/255).opacity(0.1),
                            Color(red: 15/255, green: 15/255, blue: 16/255).opacity(0.2),
                            Color(red: 5/255, green: 5/255, blue: 6/255).opacity(0.3),
                            Color(red: 1/255, green: 1/255, blue: 2/255).opacity(0.4)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.8
                )
                .frame(width: dialSize - 2, height: dialSize - 2)
            
            // Rotating indicator line - shows current position
            Rectangle()
                .fill(Color.white.opacity(0.8))
                .frame(width: 3, height: 20)
                .shadow(color: Color.black.opacity(0.3), radius: 1, x: 0, y: 0)
                .offset(y: -(dialSize / 2 - 14))
                .rotationEffect(Angle(degrees: dialRotation))
        }
    }

    private var segmentedRing: some View {
        SegmentedCircleView(metronome: metronome, diameter: dialSize + 80, lineWidth: ringLineWidth)
    }

    private var centerKnob: some View {
        ZStack {
            // Center Knob Fill matching DarkGrayBackground view
            Circle()
                .fill(LinearGradient(
                    colors: [
                       Color(red: 28/255, green: 28/255, blue: 29/255),
                       Color(red: 24/255, green: 24/255, blue: 25/255)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                ))
                .frame(width: knobSize, height: knobSize)
            
            // Center Knob Dark Outline
            Circle()
                .stroke(Color(red: 1/255, green: 1/255, blue: 2/255), lineWidth: 3.0)
                .frame(width: knobSize, height: knobSize)
            
            // Center Knob outer highlight
            Circle()
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 101/255, green: 101/255, blue: 102/255).opacity(0.1),
                            Color(red: 101/255, green: 101/255, blue: 102/255).opacity(0.1),
                            Color(red: 101/255, green: 101/255, blue: 102/255).opacity(0.2),
                            Color(red: 101/255, green: 101/255, blue: 102/255).opacity(0.3)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.5
                )
                .frame(width: knobSize + 3.5, height: knobSize + 3.5)
            
            // Center Knob inner highlight
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
                .frame(width: knobSize - 3, height: knobSize - 3)
            
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
    }

    private func createDragGesture() -> some Gesture {
        DragGesture(minimumDistance: 1)
            .onChanged { value in
                if !isKnobTouched {
                    isKnobTouched = true
                    // Strong haptic feedback when starting to drag
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred(intensity: 0.8)
                }
                isDragging = true
                handleDragChange(value)
            }
            .onEnded { _ in
                isDragging = false
                isKnobTouched = false
                previousAngle = nil
                
                // Heavy haptic feedback when ending drag
                let generator = UIImpactFeedbackGenerator(style: .heavy)
                generator.impactOccurred(intensity: 1.0)
            }
    }

    private func handleDragChange(_ value: DragGesture.Value) {
        // Calculate center relative to the gesture's coordinate space
        let frameSize = dialSize + 55
        let center = CGPoint(x: frameSize / 2, y: frameSize / 2)
        let angle = calculateAngle(center: center, point: value.location)
        
        guard let prevAngle = previousAngle else {
            previousAngle = angle
            return
        }
        
        let angleDelta = calculateAngleDelta(from: prevAngle, to: angle)
        
        // Update the dial rotation first
        let newDialRotation = dialRotation + angleDelta
        
        // Clamp the dial rotation to our 5-rotation range
        let clampedDialRotation = max(minRotation, min(maxRotation, newDialRotation))
        
        // Convert the clamped dial rotation to tempo
        let newTempo = rotationToTempo(clampedDialRotation)
        
        // Update both the dial rotation and tempo
        dialRotation = clampedDialRotation
        
        // Only update metronome tempo if it actually changed
        if newTempo != metronome.tempo {
            let oldTempo = metronome.tempo
            metronome.updateTempo(to: newTempo)
            
            // Haptic feedback when tempo changes by a whole number
            if Int(oldTempo) != Int(newTempo) {
                let generator = UIImpactFeedbackGenerator(style: .soft)
                generator.impactOccurred(intensity: 0.5)
            }
        }
        
        previousAngle = angle
    }

    private func calculateAngleDelta(from prevAngle: Double, to currentAngle: Double) -> Double {
        var delta = currentAngle - prevAngle
        if delta > 180 { delta -= 360 } else if delta < -180 { delta += 360 }
        return delta
    }

    // Convert tempo to dial rotation (now spanning 1800 degrees total)
    private func tempoToRotation(_ tempo: Double) -> Double {
        let tempoRange = metronome.maxTempo - metronome.minTempo
        let rotationRange = maxRotation - minRotation  // 1800 degrees total
        let normalizedTempo = (tempo - metronome.minTempo) / tempoRange
        return minRotation + (normalizedTempo * rotationRange)
    }
    
    // Convert dial rotation back to tempo
    private func rotationToTempo(_ rotation: Double) -> Double {
        let rotationRange = maxRotation - minRotation  // 1800 degrees total
        let tempoRange = metronome.maxTempo - metronome.minTempo
        let normalizedRotation = (rotation - minRotation) / rotationRange
        return metronome.minTempo + (normalizedRotation * tempoRange)
    }

    private func calculateAngle(center: CGPoint, point: CGPoint) -> Double {
        var degrees = atan2(point.y - center.y, point.x - center.x) * 180 / .pi
        if degrees < 0 { degrees += 360 }
        return degrees
    }
}

#Preview {
    ZStack {
        DarkGrayBackgroundView()
        DialControl(metronome: MetronomeEngine())
    }
}
