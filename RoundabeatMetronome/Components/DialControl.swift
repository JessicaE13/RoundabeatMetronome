//
//  DialControl.swift
//  RoundabeatMetronome
//
//  Created by Jessica Estes on 4/14/25.
//
// Make sure we have access to SegmentedCircleView
// If BeatSegments.swift is in a different module, you may need to import it

import SwiftUI

// MARK: - Dial Control Component
struct DialControl: View {
    @ObservedObject var metronome: MetronomeEngine
    @State private var dialRotation: Double = 0.0
    @State private var previousAngle: Double?
    @State private var isDragging: Bool = false
    
    // Constants
    private let dialSize: CGFloat = 275
    private let knobSize: CGFloat = 275/2.5
    private let minRotation: Double = -150 // Degrees
    private let maxRotation: Double = 150 // Degrees
    private let ringLineWidth: CGFloat = 7
    
    init(metronome: MetronomeEngine) {
        self.metronome = metronome
        self._dialRotation = State(initialValue: tempoToRotation(metronome.tempo))
    }
    
    var body: some View {
        ZStack {
            // Outer dial background with gradient for better visuals
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [Color.gray.opacity(0.2), Color.gray.opacity(0.3)]),
                        center: .center,
                        startRadius: 0,
                        endRadius: dialSize/2
                    )
                )
                .frame(width: dialSize, height: dialSize)
            
            // Segmented ring showing beats in the time signature
            SegmentedCircleView(
                metronome: metronome,
                diameter: dialSize - 20,
                lineWidth: ringLineWidth
            )
            
            CircleArcView()
            
            // Center knob with play/pause button
            ZStack {
                Circle()
                    .fill(metronome.isPlaying ? Color.background : Color.background)
                    .frame(width: knobSize, height: knobSize)
                    .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 3)
                
                Image(systemName: metronome.isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 30))
                    .foregroundColor(Color("AccentBlue"))
            }
            .onTapGesture {
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                metronome.togglePlayback()
            }
            
            // Debug visual - shows when drag is detected (remove in production)
            if isDragging {
                Text("Dragging: \(Int(metronome.tempo)) BPM")
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.blue.opacity(0.7))
                    .cornerRadius(8)
                    .position(x: dialSize/2, y: dialSize - 30)
                    .transition(.opacity)
            }
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

#Preview {
    // Create a sample MetronomeEngine for the preview
    let sampleMetronome = MetronomeEngine()
    return DialControl(metronome: sampleMetronome)
}
