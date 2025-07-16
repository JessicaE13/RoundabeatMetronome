import SwiftUI

// MARK: - Individual Beat Arc (Fixed multiplier consistency)

struct BeatArc: View {
    let beatNumber: Int
    let totalBeats: Int
    let isActive: Bool
    let size: CGFloat
    let emphasizeFirstBeatOnly: Bool
    
    // FIXED: Consistent stroke width calculations
    private var arcWidth: CGFloat { size * 0.08 }
    private var activeArcWidth: CGFloat { arcWidth * 1.0 } // Consistent with frame calculation
    
    // The maximum stroke width (for active state) determines the frame size needed
    private var maxStrokeWidth: CGFloat { activeArcWidth }
    
    // Frame size needs to account for stroke extending beyond the path
    private var frameSize: CGFloat { size + maxStrokeWidth }
    
    // Calculate arc parameters
    private var center: CGPoint { CGPoint(x: frameSize / 2, y: frameSize / 2) }
    private var radius: CGFloat { size / 2 }
    private var lineWidth: CGFloat { isActive ? activeArcWidth : arcWidth }
    
    // Determine if this beat should show the special outline glow
    private var shouldShowOutlineGlow: Bool {
        emphasizeFirstBeatOnly && isActive && beatNumber != 1
    }
    
    // Determine if this beat should show the normal active state
    private var shouldShowNormalActive: Bool {
        isActive && (!emphasizeFirstBeatOnly || beatNumber == 1)
    }
    
    private var arcAngles: (start: Double, end: Double) {
        let fixedGapDegrees: Double = 16.0 // 16 degrees gap between segments
        let gapAsFraction: CGFloat = CGFloat(fixedGapDegrees / 360.0)
        let totalGapFraction = gapAsFraction * CGFloat(totalBeats)
        let availableSpaceForSegments = 1.0 - totalGapFraction
        let segmentWidth = availableSpaceForSegments / CGFloat(totalBeats)
        
        let adjustedStart = CGFloat(beatNumber - 1) * (segmentWidth + gapAsFraction)
        let adjustedEnd = adjustedStart + segmentWidth
        
        // Convert to degrees and adjust for rotation
        let halfSegmentWidthInDegrees = Double(segmentWidth) * 360.0 / 2.0
        let rotationOffset = -90.0 - halfSegmentWidthInDegrees
        
        let startAngle = (Double(adjustedStart) * 360.0) + rotationOffset
        let endAngle = (Double(adjustedEnd) * 360.0) + rotationOffset
        
        return (startAngle, endAngle)
    }
    
    var body: some View {
        ZStack {
            // Shared arc path
            let arcPath = Path { path in
                path.addArc(center: center,
                            radius: radius,
                            startAngle: Angle(degrees: arcAngles.start),
                            endAngle: Angle(degrees: arcAngles.end),
                            clockwise: false)
            }
            
            // Base etched outline
            arcPath
                .strokedPath(StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .stroke(shouldShowNormalActive ?
                        Color(red: 1/255, green: 1/255, blue: 2/255).opacity(0.3) :
                        Color(red: 1/255, green: 1/255, blue: 2/255),
                        lineWidth: shouldShowNormalActive ? 1.0 : 2.75)
//                .shadow(color: Color(red: 101/255, green: 101/255, blue: 102/255).opacity(shouldShowNormalActive ? 0.2 : 0.75),
//                        radius: 0.5, x: 0, y: 0)
            
            // Special bright white glowing outline for non-first beats when emphasizeFirstBeatOnly is true
            if shouldShowOutlineGlow {
                arcPath
                    .strokedPath(StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                    .fill(Color(red: 43/255, green: 44/255, blue: 44/255))
                    .shadow(color: Color(red: 101/255, green: 101/255, blue: 102/255).opacity(0.3),
                            radius: 0.5, x: 0, y: 0)
                
                arcPath
                    .strokedPath(StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                    .stroke(Color.white.opacity(0.6), lineWidth: 1.75)
                    .shadow(color: Color.white.opacity(shouldShowNormalActive ? 0.3 : 0.6), radius: 4, x: 0, y: 0)
                    .shadow(color: Color.white.opacity(shouldShowNormalActive ? 0.2 : 0.4), radius: 8, x: 0, y: 0)
                    .shadow(color: Color(red: 101/255, green: 101/255, blue: 102/255).opacity(shouldShowNormalActive ? 0.1 : 0.3), radius: 12, x: 0, y: 0)
            }
            
            // Normal active state (only for first beat when emphasizeFirstBeatOnly is true, or all beats when false)
            if shouldShowNormalActive {
                // Inner light core - brightest white
                arcPath
                    .strokedPath(StrokeStyle(lineWidth: lineWidth * 0.98, lineCap: .round))
                    .fill(Color.white)
                
                // Medium glow layer that bleeds over the outline
                arcPath
                    .strokedPath(StrokeStyle(lineWidth: lineWidth * 0.99, lineCap: .round))
                    .fill(Color.white.opacity(0.7))
                    .blur(radius: 2)
                
                // Wider glow layer that further bleeds over the outline
                arcPath
                    .strokedPath(StrokeStyle(lineWidth: lineWidth * 1.1, lineCap: .round))
                    .fill(Color.white.opacity(0.5))
                    .blur(radius: 4)
                
                // Outer atmospheric glow
                arcPath
                    .strokedPath(StrokeStyle(lineWidth: lineWidth * 1.2, lineCap: .round))
                    .fill(Color.white.opacity(0.3))
                    .blur(radius: 8)
                
                // Outermost subtle glow
                arcPath
                    .strokedPath(StrokeStyle(lineWidth: lineWidth * 1.5, lineCap: .round))
                    .fill(Color.white.opacity(0.15))
                    .blur(radius: 12)
            } else if !isActive {
                // Inactive state - subtle fill
                arcPath
                    .strokedPath(StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                    .fill(Color("Gray1").opacity(0.2))
                    .shadow(color: Color(red: 101/255, green: 101/255, blue: 102/255).opacity(0.3),
                            radius: 0.5, x: 0, y: 0)
            }
        }
        .frame(width: frameSize, height: frameSize, alignment: .center)
    }
}

// MARK: - Circular Beat Indicator View with Tempo Dial
struct CircularBeatIndicator: View {
    let beatsPerBar: Int
    let currentBeat: Int
    let isPlaying: Bool
    let size: CGFloat
    let bpm: Int
    let emphasizeFirstBeatOnly: Bool
    let onTogglePlay: () -> Void
    let onTempoChange: (Int) -> Void
    
    @State private var lastAngle: Double = 0
    @State private var totalRotation: Double = 0
    
    // FIXED: Consistent frame size calculations
    private var arcWidth: CGFloat { size * 0.1 }
    private var activeArcWidth: CGFloat { arcWidth * 1.0 } // Match BeatArc
    private var maxStrokeWidth: CGFloat { activeArcWidth }
    private var arcFrameSize: CGFloat { size + maxStrokeWidth }
    
    var body: some View {
        ZStack {
            // Beat arc segments
            ForEach(1...beatsPerBar, id: \.self) { beatNumber in
                BeatArc(
                    beatNumber: beatNumber,
                    totalBeats: beatsPerBar,
                    isActive: currentBeat == beatNumber && isPlaying,
                    size: size,
                    emphasizeFirstBeatOnly: emphasizeFirstBeatOnly
                )
            }
            
            // Tempo dial - circle that touches the square edges
            let dialSize = arcFrameSize // Use the same size as the arc frame
            
            TempoDialView(size: dialSize, bpm: bpm, onTempoChange: onTempoChange)
            
            // Center play/stop button - made slightly bigger with elevated outline
            Button(action: onTogglePlay) {
                ZStack {
                    let buttonSize = size * 0.28
                    
// MARK: - Play button
                    
                // Play button background circle fill
                    Circle()
                        .fill(Color("Gray1").opacity(0.3))
                        .frame(width: buttonSize, height: buttonSize)
                        .shadow(color: Color.black.opacity(0.4),
                                radius: 2, x: 0, y: 1)
                
                // Play button background circle outline
                    Circle()
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(stops: [
                                    .init(color: Color("Gray1").opacity(0.6), location: 0.0),
                                    .init(color: Color("Gray1").opacity(0.5), location: 1.0)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.0
                        )
                        .frame(width: buttonSize, height: buttonSize)
                    
                // Play button outer outline
                    Circle()
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(stops: [
                                    .init(color: Color("Gray1").opacity(0.4), location: 0.0),
                                    .init(color: Color("Gray1").opacity(0.3), location: 1.0)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.0
                        )
                        .frame(width: buttonSize + 6, height: buttonSize + 6)
                    
                // Play/stop icon
                    Image(systemName: isPlaying ? "stop.fill" : "play.fill")
                        .font(.system(size: size * 0.12, weight: .bold))
                        .foregroundStyle(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color.white,
                                    Color.white.opacity(0.8),
                                    Color.white.opacity(0.6)
                                ]),
                                center: .center,
                                startRadius: 0,
                                endRadius: size * 0.06
                            )
                        )
                        .offset(x: isPlaying ? 0 : size * 0.006)
                        .shadow(color: Color.white.opacity(0.15), radius: 4, x: 0, y: 0) // soft outer glow
                        .shadow(color: Color.black.opacity(0.3), radius: 1, x: 0, y: 1) // subtle depth

                }
            }
            .buttonStyle(.plain)
        }
        .frame(width: arcFrameSize, height: arcFrameSize) // Constrain the entire component to its actual size
    }
}



// MARK: - Tempo Dial Component with Capsule Indicator and Rotating Parabola Outline
struct TempoDialView: View {
    let size: CGFloat
    let bpm: Int
    let onTempoChange: (Int) -> Void
    
    @State private var currentRotation: Double = 0
    @State private var isDragging: Bool = false
    @State private var dragStartRotation: Double = 0
    
    // Gray circle size multiplier - increased to make dial bigger
    private let grayCircleMultiplier: CGFloat = 0.72
    
    // Parabola configuration
    private let petalCount = 30
    
    // BPM to rotation mapping - bottom center (180°) for both min/max, 5 rotations total
    private func bpmToRotation(_ bpm: Int) -> Double {
        // Map BPM range (40-400) to 5 full rotations (1800°)
        // Both min and max BPM at bottom center (180°)
        let bpmRange = 400.0 - 40.0  // 360 BPM range
        let totalRotations = 5.0     // 5 full rotations
        let rotationRange = totalRotations * 360.0  // 1800° total range
        let bpmProgress = (Double(bpm) - 40.0) / bpmRange
        return 180.0 + (bpmProgress * rotationRange) // Start at 180° (bottom center)
    }
    
    private func rotationToBpm(_ rotation: Double) -> Int {
        // Convert rotation back to BPM
        let totalRotations = 5.0
        let rotationRange = totalRotations * 360.0
        let bpmRange = 400.0 - 40.0
        let rotationProgress = (rotation - 180.0) / rotationRange
        let bpm = 40.0 + (rotationProgress * bpmRange)
        return max(40, min(400, Int(bpm.rounded())))
    }
    
    // Calculate angle from center to a point
    private func angleFromCenter(_ location: CGPoint, center: CGPoint) -> Double {
        let vector = CGPoint(x: location.x - center.x, y: location.y - center.y)
        let angle = atan2(vector.y, vector.x) * 180 / .pi
        // Convert to 0-360 range
        return angle < 0 ? angle + 360 : angle
    }
    
    // Dial size variables - make circle fit exactly in the square outline
    private var totalDialDiameter: CGFloat { size * grayCircleMultiplier }
    private var donutHoleDiameter: CGFloat { size * 0.45 }
    private var dialWidth: CGFloat { (totalDialDiameter - donutHoleDiameter) / 2 }
    
    // Calculate the size of the inner circle that touches the parabola tops
    private var innerCircleDiameter: CGFloat {
        // The parabolas are positioned at -(totalDialDiameter/2 - totalDialDiameter * 0.05)
        // So the inner circle should have a diameter that reaches to their tops
        let parabolaOffset = totalDialDiameter/2 - totalDialDiameter * 0.05
        let parabolaHeight = totalDialDiameter * 0.06
        return (parabolaOffset - parabolaHeight/2) * 2
    }
    
    var body: some View {
        ZStack {
            // Outer elevated outline with shadows - using Background3 as base
            Circle()
                .stroke(Color("Background3"), lineWidth: 3.0)
                .frame(width: totalDialDiameter + 6, height: totalDialDiameter + 6)
                .shadow(color: Color("Background3").opacity(0.8),
                        radius: 1, x: 0, y: 1)
                .shadow(color: Color.black.opacity(0.3),
                        radius: 3, x: 0, y: 2)
                .shadow(color: Color.black.opacity(0.15),
                        radius: 6, x: 0, y: 4)
            
            // Inner elevated highlight - lighter version of Background3
            Circle()
                .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
                .frame(width: totalDialDiameter + 3, height: totalDialDiameter + 3)
                .shadow(color: Color.white.opacity(0.2),
                        radius: 1, x: 0, y: -1)
            
            // Parabola background with concave depth effect - LIGHTER COLORS
            ZStack {
                // Outer shadow for the recessed edge effect
                Circle()
                    .fill(Color.black.opacity(0.4))
                    .frame(width: totalDialDiameter + 3.5, height: totalDialDiameter + 3.5)
                    .blur(radius: 2.6)
                    .offset(x: 1, y: 2) // Shadow offset opposite to light source (top-left)
                
                // Main background circle with radial gradient for concave effect - using Background3 as base
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(stops: [
                                // Center appears higher (lighter from top-left light) - lighter Background3
                                .init(color: Color("Background3").opacity(1.2), location: 0.0),
                                .init(color: Color("Background3").opacity(1.0), location: 0.3),
                                .init(color: Color("Background3").opacity(0.9), location: 0.6),
                                // Edges appear lower (darker, in shadow) - darker Background3
                                .init(color: Color("Background3").opacity(0.8), location: 0.85),
                                .init(color: Color("Background3").opacity(0.7), location: 1.0)
                            ]),
                            center: UnitPoint(x: 0.35, y: 0.35), // Offset center toward top-left light source
                            startRadius: 0,
                            endRadius: totalDialDiameter * 0.6
                        )
                    )
                    .frame(width: totalDialDiameter, height: totalDialDiameter)
                
 
            }
            
            // Rotating parabola outline - positioned inside the dial circle (on top of dark gray circle)
            ZStack {
                ForEach(0..<petalCount, id: \.self) { i in
                    let baseRotation = Double(i) * (360.0 / Double(petalCount))
                    let totalRotation = baseRotation + currentRotation
                    
                    ParabolaPetalWithDynamicShadow(rotationAngle: totalRotation)
                        .frame(width: totalDialDiameter * 0.06, height: totalDialDiameter * 0.05)
                        .scaleEffect(x: 1, y: -1) // Flip the petal upside down
                        .offset(y: -(totalDialDiameter/2 - totalDialDiameter * 0.04)) // Position inside the dial circle
                        .rotationEffect(.degrees(baseRotation))
                }
            }
            .rotationEffect(.degrees(currentRotation)) // Rotate with the dial
            
            // Inner dark/black circle that touches the tops of the parabolas - slightly lighter
            Circle()
                .fill(Color(red: 15/255, green: 15/255, blue: 17/255))
                .frame(width: innerCircleDiameter, height: innerCircleDiameter)

            
            // Capsule indicator - positioned closer to outer edge and made as a rounded line
            Capsule()
                .fill(Color.white) // Same white color as the play button
                .frame(width: totalDialDiameter * 0.01, height: totalDialDiameter * 0.08) // Width: extra skinny, Height: longer line
                .offset(y: -(totalDialDiameter/2 - totalDialDiameter * 0.16)) // Position near outer edge
                .rotationEffect(.degrees(currentRotation))
                .shadow(color: Color.black.opacity(0.3), radius: 1, x: 0, y: 1)
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    let center = CGPoint(x: totalDialDiameter/2, y: totalDialDiameter/2)
                    let currentAngle = angleFromCenter(value.location, center: center)
                    
                    if !isDragging {
                        // Start of drag - store the initial rotation offset
                        isDragging = true
                        dragStartRotation = currentRotation - currentAngle
                    }
                    
                    // Calculate new rotation by adding the drag angle to the start offset
                    let newRotation = dragStartRotation + currentAngle
                    
                    // Clamp rotation to valid range and check BPM limits
                    let clampedRotation = max(180.0, min(1980.0, newRotation))
                    let newBPM = rotationToBpm(clampedRotation)
                    
                    // Only update if within BPM limits
                    if newBPM >= 40 && newBPM <= 400 {
                        currentRotation = clampedRotation
                        onTempoChange(newBPM)
                    }
                }
                .onEnded { _ in
                    isDragging = false
                    dragStartRotation = 0
                }
        )
        .onAppear {
            currentRotation = bpmToRotation(bpm)
        }
        .onChange(of: bpm) { _, newBPM in
            if !isDragging {
                currentRotation = bpmToRotation(newBPM)
            }
        }
    }
}

struct DialView: View {
    @ObservedObject var metronome: MetronomeEngine
    
    // Get screen dimensions directly
    private var screenWidth: CGFloat {
        UIScreen.main.bounds.width
    }
    
    private var screenHeight: CGFloat {
        UIScreen.main.bounds.height
    }
    
    // Check if device is iPad
    private var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var body: some View {
        // Calculate the arc segment size based on device and available space
        let arcSegmentSize = calculateArcSegmentSize()
        
        // Calculate the total frame size including stroke width - FIXED
        let frameSize = calculateFrameSize(for: arcSegmentSize)
        
        CircularBeatIndicator(
            beatsPerBar: metronome.beatsPerBar,
            currentBeat: metronome.currentBeat,
            isPlaying: metronome.isPlaying,
            size: arcSegmentSize,
            bpm: metronome.bpm,
            emphasizeFirstBeatOnly: metronome.emphasizeFirstBeatOnly,
            onTogglePlay: {
                metronome.isPlaying.toggle()
            },
            onTempoChange: { newBPM in
                metronome.bpm = newBPM
            }
        )
        .frame(width: frameSize, height: frameSize)
    }
    
    // Helper function to calculate the arc segment size
    private func calculateArcSegmentSize() -> CGFloat {
        if isIPad {
            return screenHeight * 0.44
        } else {
            if screenWidth <= 375 {
                return screenHeight * 0.36
            } else {
                return screenHeight * 0.36
            }
        }
    }
    
    // FIXED: Consistent frame calculation matching BeatArc and CircularBeatIndicator
    private func calculateFrameSize(for arcSize: CGFloat) -> CGFloat {
        let arcWidth = arcSize * 0.1
        let activeArcWidth = arcWidth * 1.0  // NOW MATCHES BeatArc multiplier
        let maxStrokeWidth = activeArcWidth
        return arcSize + maxStrokeWidth
    }
}

#Preview {
    ZStack {
        BackgroundView()
        VStack {
            Spacer()
            DialView(metronome: MetronomeEngine())
        }
    }
}
