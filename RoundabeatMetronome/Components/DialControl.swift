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
                        gradient: Gradient(colors: [Color.black.opacity(1.0), Color.black.opacity(0.95)]),
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
                    isFirstBeat ? Color.colorGlow.opacity(0.4) : Color.colorGlow.opacity(0.4),
                    style: StrokeStyle(lineWidth: lineWidth + 6, lineCap: .round)
                )
                .blur(radius: 4)
                
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
                    isFirstBeat ? Color.colorGlow : Color.colorGlow,
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
    private let gapWidthPoints: CGFloat = 7.0
    
    var body: some View {
        ZStack {
            // Background circle (optional - helps see the full circle)
            Circle()
                .stroke(Color.gray.opacity(0.1), lineWidth: lineWidth)
                .frame(width: diameter - lineWidth, height: diameter - lineWidth)
            
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
            
            // Draw square-like dividers between segments
            ForEach(0..<metronome.beatsPerMeasure, id: \.self) { beatIndex in
                // Use the angleForDivider function
                let angle = angleForDivider(beatIndex)
                
                // Calculate position using trigonometry instead of offset+rotation
                let x = diameter/2 + cos(angle * .pi / 180) * radius
                let y = diameter/2 + sin(angle * .pi / 180) * radius
                
                // Create the divider "tick" at each segment boundary
                Rectangle()
                    .fill(Color("Background")) // Red divider
                    .frame(width: gapWidthPoints, height: lineWidth)
                    .rotationEffect(Angle(degrees: angle + 90)) // Add 90 to align rectangle properly
                    .position(x: x, y: y)
            }
            
        }
        .frame(width: diameter, height: diameter)
    }
    
    // Calculate angle for placing square dividers
    private func angleForDivider(_ index: Int) -> Double {
        // Each beat takes up an equal portion of the full circle
        let degreesPerBeat = 360.0 / Double(metronome.beatsPerMeasure)
        
        // In standard mathematical coordinates: 0 degrees is at 3 o'clock
        // 270 degrees is at 12 o'clock
        let startAngle = 270.0
        
        // Calculate angle with index 0 always at 12 o'clock
        let angle = startAngle + (Double(index) * degreesPerBeat)
        
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
    private let ringLineWidth: CGFloat = 5
    
    
  
    
    init(metronome: MetronomeEngine) {
        self.metronome = metronome
        self._dialRotation = State(initialValue: tempoToRotation(metronome.tempo))
    }
    
    var body: some View {
        

        
        

        
        
        
        ZStack {
             //Outer dial background with gradient for better visuals - this is the old one
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [Color.white.opacity(0.3), Color.white.opacity(0.4)]),
                        center: .center,
                        startRadius: 0,
                        endRadius: dialSize/2
                    )
                )
                .frame(width: dialSize*0.82, height: dialSize*0.82)
                .overlay(
                    ZStack {
                        // Add 60 tick marks (one for each minute/second)
                        ForEach(0..<60) { index in
                            Rectangle()
                                .fill(index % 5 == 0 ? Color.black.opacity(0.3) : Color.black.opacity(0.2))
                                .frame(width: index % 5 == 0 ? 2 : 1, height: index % 5 == 0 ? 10 : 5)
                                .offset(y: (dialSize * 0.82 / 2 - 15) * -1)
                                .rotationEffect(.degrees(Double(index) * 6))
                        }
                    }
                    
                        .rotationEffect(Angle(degrees: dialRotation)) // This makes the tick marks rotate with the dial
                )
            //donut shaped thing
            
//            ZStack {
//                //dial colors
//                let nearblack = Color(white: 0.02)
//                let outerDialGradient = LinearGradient(
//                    colors: [Color(white: 0.40), Color(white: 0.30)],
//                    startPoint: .topLeading,
//                    endPoint: .bottomTrailing
//                )
//                let outerDialCircle = Circle().fill(outerDialGradient)
//                outerDialCircle
//                
//                ZStack {
//                    Group{
//                        outerDialCircle
//                        outerDialCircle
//                            .rotationEffect(.degrees(180))
//                            .frame(width: 180)
//                    }
//                    .blur(radius: 16)
//                }
//                .frame(width: dialSize*0.82, height: dialSize*0.82)
//                
//                Circle()
//                    .fill(outerDialGradient)
//                    .frame(width: 50)
//            }
// 
            
            // Segmented ring showing beats in the time signature
            SegmentedCircleView(
                metronome: metronome,
                diameter: dialSize - 20,
                lineWidth: ringLineWidth
            )
            
            // Center knob with play/pause button
            ZStack {
                // Main button background
                Circle()
                    .fill(Color.background)
                    .frame(width: knobSize, height: knobSize)
                    .overlay(
                        Circle()
                            .stroke(Color.black.opacity(0.5), lineWidth: 0.5)
                    )
                    .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 3)
                
                // Play/pause icon with constant glow effect
                Image(systemName: metronome.isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 30))
                    .foregroundColor(Color("colorGlow"))
                    .shadow(color: Color("colorGlow").opacity(0.7), radius: 3, x: 0, y: 0)
            }
            .onTapGesture {
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                metronome.togglePlayback()
            }
            
            
            // Debug visual - shows when drag is detected (remove in production)
//            if isDragging {
//                Text("Dragging: \(Int(metronome.tempo)) BPM")
//                    .foregroundColor(.white)
//                    .padding(8)
//                    .background(Color.blue.opacity(0.7))
//                    .cornerRadius(8)
//                    .position(x: dialSize/2, y: dialSize - 30)
//                    .transition(.opacity)
//            }
        }
        .frame(width: dialSize, height: dialSize)
        // Use the entire dial as a drag target with a simple gesture recognizer
        .gesture(
            DragGesture(minimumDistance: 1)
                .onChanged { value in
                    isDragging = true
                    
                    // Calculate the center of the dial
                    let center = CGPoint(x: dialSize/2, y: dialSize/2)
                    
                    // Calculate the current angle
                    let angle = calculateAngle(
                        center: center,
                        point: value.location
                    )
                    
                    // Process the angle change
                    if let prevAngle = previousAngle {
                        // Calculate the angle delta (how much we've rotated)
                        var angleDelta = angle - prevAngle
                        
                        // Handle wraparound at 0/360 degrees
                        if angleDelta > 180 {
                            angleDelta -= 360
                        } else if angleDelta < -180 {
                            angleDelta += 360
                        }
                        
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
                    }
                    
                    // Save the current angle for next comparison
                    previousAngle = angle
                }
                .onEnded { _ in
                    isDragging = false
                    previousAngle = nil
                }
        )
        .onChange(of: metronome.tempo) { _, newTempo in
            // Update dial rotation when tempo changes from any source
            dialRotation = tempoToRotation(newTempo)
        }
    }
    
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
            .padding(.top, 10)
            
            // Additional metronome controls could go here
            HStack(spacing: 20) {
                Button(action: {
                    // Decrease tempo by 5
                    metronome.updateTempo(to: max(metronome.tempo - 5, metronome.minTempo))
                }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(Color("colorGlow"))
                }
                
                Button(action: {
                    metronome.togglePlayback()
                }) {
                    Image(systemName: metronome.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(Color("colorGlow"))
                }
                
                Button(action: {
                    // Increase tempo by 5
                    metronome.updateTempo(to: min(metronome.tempo + 5, metronome.maxTempo))
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(Color("colorGlow"))
                }
            }
            .padding(.top, 10)
        }
        .padding()
        .background(Color.background)
    }
}



#Preview {
    CombinedMetronomeView()
}
