import SwiftUI

struct DialControl: View {
    @ObservedObject var metronome: MetronomeEngine
    @State private var dialRotation: Double = 0.0
    @State private var previousAngle: Double?
    @State private var isDragging = false
    @State private var isKnobTouched = false
    
    let adaptiveLayout: AdaptiveLayout

    // Use adaptive sizing
    private var dialSize: CGFloat { AdaptiveValues.dialSize }
    private var knobSize: CGFloat {
        if UIDevice.isCompactDevice {
            return AdaptiveValues.dialSize * 0.35  // Proportional to dial
        } else if UIDevice.current.isIPad {
            return 120
        } else {
            return 90
        }
    }
    private var ringLineWidth: CGFloat {
        if UIDevice.isCompactDevice {
            return 20  // Slightly thicker for bigger iPhone SE dial
        } else if UIDevice.current.isIPad {
            return 32
        } else {
            return 24
        }
    }
    
    // Dial rotation remains the same
    private let minRotation: Double = -900
    private let maxRotation: Double = 900

    init(metronome: MetronomeEngine, adaptiveLayout: AdaptiveLayout) {
        self.metronome = metronome
        self.adaptiveLayout = adaptiveLayout
        self._dialRotation = State(initialValue: tempoToRotation(metronome.tempo))
    }

    var body: some View {
        VStack(spacing: adaptiveLayout.isIPad ? 30 : (UIDevice.isCompactDevice ? 16 : 20)) {
            ZStack {
                segmentedRing
                dialBackground
                centerKnob
            }
            .frame(width: dialSize + (adaptiveLayout.isIPad ? 120 : (UIDevice.isCompactDevice ? 60 : 85)),
                   height: dialSize + (adaptiveLayout.isIPad ? 120 : (UIDevice.isCompactDevice ? 60 : 85)))
            .gesture(createDragGesture())
            .onChange(of: metronome.tempo) { _, newTempo in
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
                .fill(LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0/255, green: 0/255, blue: 0/255).opacity(0.75),
                        Color(red: 1/255, green: 1/255, blue: 1/255).opacity(0.95)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: dialSize + 13, height: dialSize + 13)
            
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
                    lineWidth: 0.75
                )
                .frame(width: dialSize + 13, height: dialSize + 13)

            Circle()
                .fill(Color(red: 7/255, green: 7/255, blue: 8/255))
                .frame(width: dialSize, height: dialSize)
                .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
           
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
                    lineWidth: 0.75
                )
                .frame(width: dialSize + 2, height: dialSize + 2)

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
                    lineWidth: 2.8
                )
                .frame(width: dialSize - 2, height: dialSize - 2)
            
            // Rotating indicator - scale size for different devices
            Circle()
                .glowingAccent(intensity: 0.5)
                .opacity(0.85)
                .frame(width: UIDevice.isCompactDevice ? 3 : (adaptiveLayout.isIPad ? 8 : 5),
                       height: UIDevice.isCompactDevice ? 3 : (adaptiveLayout.isIPad ? 8 : 5))
                .shadow(color: Color.black.opacity(0.3), radius: 1, x: 0, y: 0)
                .offset(y: -(dialSize / 2 - (UIDevice.isCompactDevice ? 8 : (adaptiveLayout.isIPad ? 16 : 11))))
                .rotationEffect(Angle(degrees: dialRotation))
        }
    }

    private var segmentedRing: some View {
        SegmentedCircleView(
            metronome: metronome,
            diameter: dialSize + (adaptiveLayout.isIPad ? 120 : (UIDevice.isCompactDevice ? 75 : 85)),
            lineWidth: ringLineWidth
        )
    }

    private var centerKnob: some View {
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
                    lineWidth: 0.75
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
                    lineWidth: 0.75
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
            .font(.system(size: UIDevice.isCompactDevice ? 20 : (adaptiveLayout.isIPad ? 40 : 30)))
            .glowingAccent()
    }
    
    private func createDragGesture() -> some Gesture {
        DragGesture(minimumDistance: 1)
            .onChanged { value in
                if !isKnobTouched {
                    isKnobTouched = true
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
                
                let generator = UIImpactFeedbackGenerator(style: .heavy)
                generator.impactOccurred(intensity: 1.0)
            }
    }

    private func handleDragChange(_ value: DragGesture.Value) {
        let frameSize = dialSize + (adaptiveLayout.isIPad ? 120 : (UIDevice.isCompactDevice ? 60 : 85))
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

// Keep your existing legacy initializer
extension DialControl {
    init(metronome: MetronomeEngine) {
        self.metronome = metronome
        self.adaptiveLayout = AdaptiveLayout.default
        self._dialRotation = State(initialValue: tempoToRotation(metronome.tempo))
    }
}

#Preview {
    ZStack {
        BackgroundView()
        DialControl(
            metronome: MetronomeEngine(),
            adaptiveLayout: AdaptiveLayout.default
        )
    }
}
