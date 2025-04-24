//
//  CombinedMetronomeView.swift
//  RoundabeatMetronome
//
//  Created on 4/15/25.
//



import SwiftUI

// MARK: - Beat Segment Arc View
struct ArcSegment: View {
    let center: CGPoint
    let radius: CGFloat
    let startAngle: Double
    let endAngle: Double
    let lineWidth: CGFloat
    let isActive: Bool
    let isFirstBeat: Bool
    let gapWidth: CGFloat // Width of the gap in points (not degrees)
    
    var body: some View {
        ZStack {
            
            // When not active, show gradient version
            if !isActive {
                Path { path in
                    path.addArc(
                        center: center,
                        radius: radius,
                        startAngle: Angle(degrees: startAngle),
                        endAngle: Angle(degrees: endAngle),
                        clockwise: false
                    )
                }
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.gray.opacity(0.45), Color.gray.opacity(0.40)]),
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .butt)
                )
            }
            
            // When active, show colored version
            if isActive {
                
                Path { path in
                    path.addArc(
                        center: center,
                        radius: radius,
                        startAngle: Angle(degrees: startAngle),
                        endAngle: Angle(degrees: endAngle),
                        clockwise: false
                    )
                }
                .stroke(
                    isFirstBeat ? Color("skinGreen").opacity(0.4) : Color("colorPurpleBackground").opacity(0.4),
                    style: StrokeStyle(lineWidth: lineWidth + 6, lineCap: .round)
                )
                .blur(radius: 10)
                
                Path { path in
                    path.addArc(
                        center: center,
                        radius: radius,
                        startAngle: Angle(degrees: startAngle),
                        endAngle: Angle(degrees: endAngle),
                        clockwise: false
                    )
                }
                .stroke(
                    isFirstBeat ? Color("colorGlow").opacity(0.8) : Color("colorGlow"),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .butt)
                )
            }
        }
        // Add a subtle animation when segment becomes active
        .animation(.easeInOut(duration: 0.1), value: isActive)
    }
}

// MARK: - Segmented Circle View
struct SegmentedCircleView: View {
    @ObservedObject var metronome: MetronomeEngine
    let diameter: CGFloat
    let lineWidth: CGFloat
    
    private var radius: CGFloat {
        (diameter - lineWidth) / 2
    }
    
    // Fixed gap width in points
    private let gapWidthPoints: CGFloat = 15.0
    
    var body: some View {
        ZStack {

            
            // Draw each segment based on the time signature
            ForEach(0..<metronome.beatsPerMeasure, id: \.self) { beatIndex in
                let (startAngle, endAngle) = angleRangeForBeat(beatIndex)
                
                ArcSegment(
                    center: CGPoint(x: diameter/2, y: diameter/2),
                    radius: radius,
                    startAngle: startAngle,
                    endAngle: endAngle,
                    lineWidth: lineWidth,
                    isActive: beatIndex == metronome.currentBeat && metronome.isPlaying,
                    isFirstBeat: beatIndex == 0,
                    gapWidth: gapWidthPoints
                )
            }
            
            // Rectangle dividers have been removed
            
        }
        .frame(width: diameter, height: diameter)
    }
    
    // Check if a divider is adjacent to the active beat
    private func isAdjacentToBeat(index: Int, activeBeat: Int) -> Bool {
        // In a circular arrangement, need to handle wrapping around
        let totalBeats = metronome.beatsPerMeasure
        
        // The divider at index is before beat index and after beat (index-1)
        let beatAfterDivider = index
        let beatBeforeDivider = (index - 1 + totalBeats) % totalBeats
        
        // Return true if either adjacent beat is the active one
        return beatAfterDivider == activeBeat || beatBeforeDivider == activeBeat
    }
    
    // Calculate angle for placing square dividers
    private func angleForDivider(_ index: Int) -> Double {
        // Each beat takes up an equal portion of the full circle
        let degreesPerBeat = 360.0 / Double(metronome.beatsPerMeasure)
        let halfSegment = degreesPerBeat / 2
        
        // In standard mathematical coordinates: 0 degrees is at 3 o'clock
        // 270 degrees is at 12 o'clock
        let startAngle = 270.0
        
        // Calculate angle with index 0 always at 12 o'clock
        let angle = startAngle - halfSegment + (Double(index) * degreesPerBeat)
        
        return angle
    }
    
    // Calculate start and end angles for each beat segment, leaving space for the divider
    private func angleRangeForBeat(_ beat: Int) -> (start: Double, end: Double) {
        // Calculate how many degrees each segment should cover
        let totalAvailableDegrees = 360.0
        let degreesPerBeat = totalAvailableDegrees / Double(metronome.beatsPerMeasure)
        
        // Calculate gap in degrees based on fixed pixel width
        // This is an approximation and will depend on the actual circle size
        let gapDegrees = (gapWidthPoints / (2 * .pi * radius)) * 360.0
        
        // Get the base angle for this beat (at the divider)
        let dividerAngle = angleForDivider(beat)
        
        // Start a bit after the divider, end a bit before the next divider
        let startAngle = dividerAngle + (gapDegrees / 2)
        let endAngle = dividerAngle + degreesPerBeat - (gapDegrees / 2)
        
        return (startAngle, endAngle)
    }
}
// MARK: - Dial Control Component
struct DialControl: View {
    @ObservedObject var metronome: MetronomeEngine
    @State private var dialRotation: Double = 0.0
    @State private var previousAngle: Double?
    @State private var isDragging: Bool = false
    
    // Constants
    private let dialSize: CGFloat = 275
    private let knobSize: CGFloat = 275/3
    private let minRotation: Double = -150 // Degrees
    private let maxRotation: Double = 150 // Degrees
    private let ringLineWidth: CGFloat = 10
    
    init(metronome: MetronomeEngine) {
        self.metronome = metronome
        self._dialRotation = State(initialValue: tempoToRotation(metronome.tempo))
    }
    
    var body: some View {
        ZStack {
            dialBackground
            segmentedRing
            centerKnob
        }
        .frame(width: dialSize, height: dialSize)
        .gesture(createDragGesture())
        .onChange(of: metronome.tempo) { _, newTempo in
            // Update dial rotation when tempo changes from any source
            dialRotation = tempoToRotation(newTempo)
        }
    }

    // MARK: - View Components
    
    private var dialBackground: some View {
        Circle()
            .fill(Color("colorDial"))
            .frame(width: dialSize, height: dialSize)
            .overlay(dialTickMarks)
    }
    
    private var dialTickMarks: some View {
        ZStack {
            // Add 60 tick marks (one for each minute/second)
            ForEach(0..<60) { index in
                tickMark(at: index)
            }
        }
        .rotationEffect(Angle(degrees: dialRotation))
    }
    
    private func tickMark(at index: Int) -> some View {
        let isLargeTick = index % 5 == 0
        
        return Rectangle()
            .fill(isLargeTick ? Color.white.opacity(0.7) : Color.white.opacity(0.6))
            .frame(width: isLargeTick ? 2 : 1, height: isLargeTick ? 10 : 5)
            .offset(y: (dialSize / 2 - 15) * -1)
            .rotationEffect(.degrees(Double(index) * 6))
    }
    
    private var segmentedRing: some View {
        SegmentedCircleView(
            metronome: metronome,
            diameter: dialSize + 45,
            lineWidth: ringLineWidth
        )
    }
    
    private var centerKnob: some View {
        ZStack {
            knobBackground
            playPauseIcon
        }
        .onTapGesture {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            metronome.togglePlayback()
        }
    }
    
    private var knobBackground: some View {
        Circle()
            .fill(Color.white.opacity(0.9))
        
            .frame(width: knobSize, height: knobSize)
            .overlay(
                Circle()
                    .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
            )
            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 3)
    }
    
    private var playPauseIcon: some View {
        Image(systemName: metronome.isPlaying ? "stop.fill" : "play.fill")
            .font(.system(size: 30))
            .foregroundColor(Color.black.opacity(0.9))
            .shadow(color: Color("colorPurpleBackground").opacity(0.7), radius: 0, x: 0, y: 0)
    }
    
    // MARK: - Gesture Handling
    
    private func createDragGesture() -> some Gesture {
        DragGesture(minimumDistance: 1)
            .onChanged { value in
                handleDragChange(value)
            }
            .onEnded { _ in
                isDragging = false
                previousAngle = nil
            }
    }
    
    private func handleDragChange(_ value: DragGesture.Value) {
        isDragging = true
        
        // Calculate the center of the dial
        let center = CGPoint(x: dialSize/2, y: dialSize/2)
        
        // Calculate the current angle
        let angle = calculateAngle(center: center, point: value.location)
        
        // Process the angle change if we have a previous angle
        guard let prevAngle = previousAngle else {
            previousAngle = angle
            return
        }
        
        // Calculate the angle delta (how much we've rotated)
        let angleDelta = calculateAngleDelta(from: prevAngle, to: angle)
        
        // Apply a sensitivity factor
        let sensitivity = 0.4
        
        // Calculate tempo change (positive = clockwise = increase tempo)
        let tempoChange = angleDelta * sensitivity
        let newTempo = metronome.tempo + tempoChange
        
        // Update the tempo
        metronome.updateTempo(to: newTempo)
        
        // Add haptic feedback
        if abs(tempoChange) > 0.5 {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred(intensity: 0.2)
        }
        
        // Save the current angle for next comparison
        previousAngle = angle
    }
    
    private func calculateAngleDelta(from prevAngle: Double, to currentAngle: Double) -> Double {
        var angleDelta = currentAngle - prevAngle
        
        // Handle wraparound at 0/360 degrees
        if angleDelta > 180 {
            angleDelta -= 360
        } else if angleDelta < -180 {
            angleDelta += 360
        }
        
        return angleDelta
    }
    
    // MARK: - Utility Functions
    
    // Convert tempo to rotation angle
    private func tempoToRotation(_ tempo: Double) -> Double {
        let tempoRange = metronome.maxTempo - metronome.minTempo
        let rotationRange = maxRotation - minRotation
        return minRotation + (tempo - metronome.minTempo) / tempoRange * rotationRange
    }
    
    // Calculate angle in degrees (0-360) between center and point
    private func calculateAngle(center: CGPoint, point: CGPoint) -> Double {
        // Calculate the angle in radians
        let radians = atan2(point.y - center.y, point.x - center.x)
        
        // Convert to degrees (0-360 range)
        var degrees = radians * 180 / .pi
        if degrees < 0 {
            degrees += 360
        }
        
        return degrees
    }
}
// MARK: - Combined Metronome View
struct CombinedMetronomeView: View {
    @StateObject private var metronome = MetronomeEngine()
    
    var body: some View {
        VStack(spacing: 20) {
            // Main control dial (which includes the segmented circle visualization)
            DialControl(metronome: metronome)
            
            // Tempo display
            Text("\(Int(metronome.tempo)) BPM")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            // Time signature controls
            HStack(spacing: 30) {
                VStack {
                    Text("Beats Per Measure")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Stepper("\(metronome.beatsPerMeasure)", value: Binding(
                        get: { self.metronome.beatsPerMeasure },
                        set: { self.metronome.beatsPerMeasure = $0 }
                    ), in: 1...12)
                    .frame(width: 120)
                }
                
                VStack {
                    Text("Beat Unit")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Picker("", selection: Binding(
                        get: { self.metronome.beatUnit },
                        set: { self.metronome.beatUnit = $0 }
                    )) {
                        Text("Quarter").tag(4)
                        Text("Eighth").tag(8)
                        Text("Half").tag(2)
                        Text("Whole").tag(1)
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(width: 120)
                }
            }
        }
        .padding()
        .background(Color.background)
    }
}



#Preview {
    CombinedMetronomeView()
}
