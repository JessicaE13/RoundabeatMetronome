import SwiftUI

struct DialControl: View {
    @ObservedObject var metronome: MetronomeEngine
    @State private var dialRotation: Double = 0.0
    @State private var previousAngle: Double?
    @State private var isDragging = false
    @State private var isKnobTouched = false

    // Percentage-based sizing
    private let dialSizePercent: CGFloat = 0.72        // 75% of available space
    private let knobSizePercent: CGFloat = 0.42        // 27% of dial size
    private let ringLineWidthPercent: CGFloat = 0.12   // 7% of dial size
    private let outerFramePercent: CGFloat = 1.0       // 100% of available space
    private let maxHeightPercent: CGFloat = 0.8        // Maximum 50% of screen height
    
    // Dial rotation remains the same
    private let minRotation: Double = -900
    private let maxRotation: Double = 900

    init(metronome: MetronomeEngine) {
        self.metronome = metronome
        self._dialRotation = State(initialValue: tempoToRotation(metronome.tempo))
    }

    var body: some View {
        GeometryReader { geometry in
            let maxAllowedSize = geometry.size.height * maxHeightPercent
            let availableSize = min(geometry.size.width, geometry.size.height, maxAllowedSize)
            let dialSize = availableSize * dialSizePercent
            let knobSize = dialSize * knobSizePercent
            let ringLineWidth = dialSize * ringLineWidthPercent
            let frameSize = availableSize * outerFramePercent
            
            VStack(spacing: availableSize) {
                ZStack {
                    segmentedRing(frameSize: frameSize, lineWidth: ringLineWidth)
                    dialBackground(dialSize: dialSize)
                    centerKnob(knobSize: knobSize)
                }
                .frame(width: frameSize, height: frameSize)
                .gesture(createDragGesture(frameSize: frameSize))
                .onChange(of: metronome.tempo) { _, newTempo in
                    if !isDragging {
                        dialRotation = tempoToRotation(newTempo)
                    }
                }
                .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
                    isKnobTouched = pressing
                }, perform: {})
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .aspectRatio(1, contentMode: .fit) // Keep it square
    }

    private func dialBackground(dialSize: CGFloat) -> some View {
        ZStack {
            // Main Circle Background - darker color
            Circle()
                .fill(LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0/255, green: 0/255, blue: 0/255).opacity(0.75),
                        Color(red: 1/255, green: 1/255, blue: 1/255).opacity(0.95)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: dialSize * 1.05, height: dialSize * 1.05)
            
            Circle()
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 101/255, green: 101/255, blue: 102/255).opacity(0.01),
                            Color(red: 101/255, green: 101/255, blue: 102/255).opacity(0.1),
                            Color(red: 101/255, green: 101/255, blue: 102/255).opacity(0.2),
                            Color(red: 101/255, green: 101/255, blue: 102/255).opacity(0.3)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: dialSize * 0.003
                )
                .frame(width: dialSize * 1.05, height: dialSize * 1.05)

            Circle()
                .fill(Color(red: 7/255, green: 7/255, blue: 8/255))
                .frame(width: dialSize, height: dialSize)
                .shadow(color: .black.opacity(0.3), radius: dialSize * 0.032, x: 0, y: dialSize * 0.016)
           
            Circle()
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 85/255, green: 85/255, blue: 86/255).opacity(0.50),
                            Color(red: 85/255, green: 85/255, blue: 86/255).opacity(0.3),
                            Color(red: 85/255, green: 85/255, blue: 86/255).opacity(0.25),
                            Color(red: 85/255, green: 85/255, blue: 86/255).opacity(0.2)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: dialSize * 0.003
                )
                .frame(width: dialSize * 1.008, height: dialSize * 1.008)

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
                    lineWidth: dialSize * 0.011
                )
                .frame(width: dialSize * 0.992, height: dialSize * 0.992)
            
            Circle()
                .glowingAccent(intensity: 0.5)
                .opacity(0.85)
                .frame(width: dialSize * 0.02, height: dialSize * 0.02)
                .shadow(color: Color.black.opacity(0.3), radius: 1, x: 0, y: 0)
                .offset(y: -(dialSize / 2 - dialSize * 0.044))
                .rotationEffect(Angle(degrees: dialRotation))
        }
    }

    private func segmentedRing(frameSize: CGFloat, lineWidth: CGFloat) -> some View {
        SegmentedCircleView(
            metronome: metronome,
            diameter: frameSize,
            lineWidth: lineWidth
        )
    }

    private func centerKnob(knobSize: CGFloat) -> some View {
        ZStack {
            // Center Knob Fill
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
                .stroke(Color(red: 1/255, green: 1/255, blue: 2/255), lineWidth: knobSize * 0.033)
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
                    lineWidth: knobSize * 0.008
                )
                .frame(width: knobSize * 1.04, height: knobSize * 1.04)
            
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
                    lineWidth: knobSize * 0.008
                )
                .frame(width: knobSize * 0.967, height: knobSize * 0.967)
            
            playPauseIcon(knobSize: knobSize)
        }
        .onTapGesture {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            metronome.togglePlayback()
        }
    }
    
    private func playPauseIcon(knobSize: CGFloat) -> some View {
        Image(systemName: metronome.isPlaying ? "stop.fill" : "play.fill")
            .font(.system(size: knobSize * 0.33))
            .glowingAccent()
    }
    
    private func createDragGesture(frameSize: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 1)
            .onChanged { value in
                if !isKnobTouched {
                    isKnobTouched = true
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred(intensity: 0.8)
                }
                isDragging = true
                handleDragChange(value, frameSize: frameSize)
            }
            .onEnded { _ in
                isDragging = false
                isKnobTouched = false
                previousAngle = nil
                
                let generator = UIImpactFeedbackGenerator(style: .heavy)
                generator.impactOccurred(intensity: 1.0)
            }
    }

    private func handleDragChange(_ value: DragGesture.Value, frameSize: CGFloat) {
        let center = CGPoint(x: frameSize / 2, y: frameSize / 2)
        let angle = calculateAngle(center: center, point: value.location)
        
        guard let prevAngle = previousAngle else {
            previousAngle = angle
            return
        }
        
        let angleDelta = calculateAngleDelta(from: prevAngle, to: angle)
        let newDialRotation = dialRotation + angleDelta
        let clampedDialRotation = max(minRotation, min(maxRotation, newDialRotation))
        let newTempo = rotationToTempo(clampedDialRotation)
        
        dialRotation = clampedDialRotation
        
        if newTempo != metronome.tempo {
            let oldTempo = metronome.tempo
            metronome.updateTempo(to: newTempo)
            
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

    private func tempoToRotation(_ tempo: Double) -> Double {
        let tempoRange = metronome.maxTempo - metronome.minTempo
        let rotationRange = maxRotation - minRotation
        let normalizedTempo = (tempo - metronome.minTempo) / tempoRange
        return minRotation + (normalizedTempo * rotationRange)
    }
    
    private func rotationToTempo(_ rotation: Double) -> Double {
        let rotationRange = maxRotation - minRotation
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
        BackgroundView()
        DialControl(
            metronome: MetronomeEngine()
        )
    }
}
