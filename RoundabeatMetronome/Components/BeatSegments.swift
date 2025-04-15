//
//  BeatSegments.swift
//  RoundabeatMetronome
//
//  Created by Jessica Estes on 4/13/25.
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
                        gradient: Gradient(colors: [Color.gray.opacity(0.4), Color.gray.opacity(0.2)]),
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
                    isFirstBeat ? Color.accentBlue : Color.accentBlue,
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
                let dividerAngle = angleForDivider(beatIndex)
                
                // Create the divider "tick" at each segment boundary
                Rectangle()
                    .fill(Color.background) // White divider
                    .frame(width: gapWidthPoints, height: lineWidth+1)
                    .offset(x: 0, y: -radius) // Position at the circle's edge
                    .rotationEffect(Angle(degrees: dividerAngle))
                    .position(x: diameter/2, y: diameter/2)
            }
        }
        .frame(width: diameter, height: diameter)
    }
    
    // Calculate angle for placing square dividers
    private func angleForDivider(_ index: Int) -> Double {
        // Each beat takes up an equal portion of the full circle
        let degreesPerBeat = 360.0 / Double(metronome.beatsPerMeasure)
        
        // Starting at top (270 degrees in SwiftUI coordinates where 0 is at 3 o'clock)
        // and going clockwise
        let startAngle = 270.0
        let dividerAngle = startAngle + (Double(index) * degreesPerBeat)
        
        // Normalize to 0-360 range
        return dividerAngle.truncatingRemainder(dividingBy: 360.0)
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

// MARK: - BeatSegments Container View
struct BeatSegments: View {
    // Use the MetronomeEngine from your project
    @StateObject private var metronome = MetronomeEngine()
    
    var body: some View {
        VStack {
            SegmentedCircleView(
                metronome: metronome,
                diameter: 300,
                lineWidth: 30
            )
            
            // Optional controls for preview
            HStack(spacing: 20) {
                Button(action: {
                    metronome.togglePlayback()
                }) {
                    Text(metronome.isPlaying ? "Stop" : "Start")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                Button(action: {
                    metronome.currentBeat = (metronome.currentBeat + 1) % metronome.beatsPerMeasure
                }) {
                    Text("Next Beat")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding()
        }
    }
}

#Preview {
    BeatSegments()
}
