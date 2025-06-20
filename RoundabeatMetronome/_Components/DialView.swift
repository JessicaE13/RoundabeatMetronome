import SwiftUI

// MARK: - Individual Beat Arc (Fixed multiplier consistency)

struct BeatArc: View {
    let beatNumber: Int
    let totalBeats: Int
    let isActive: Bool
    let size: CGFloat
    let emphasizeFirstBeatOnly: Bool
    
    // FIXED: Consistent stroke width calculations
    private var arcWidth: CGFloat { size * 0.1 }
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
                .shadow(color: Color(red: 101/255, green: 101/255, blue: 102/255).opacity(shouldShowNormalActive ? 0.2 : 0.75),
                        radius: 0.5, x: 0, y: 0)
            
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
                    .fill(Color(red: 58/255, green: 58/255, blue: 59/255))
                    //.shadow(color: Color(red: 101/255, green: 101/255, blue: 102/255).opacity(0.3),
                      //      radius: 0.5, x: 0, y: 0)
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
            
            // Center play/stop button - made slightly bigger
            Button(action: onTogglePlay) {
                ZStack {
                    Circle()
                        .fill(Color(red: 43/255, green: 44/255, blue: 44/255))
                        .frame(width: size * 0.35, height: size * 0.35)
              
                    Circle()
                        .stroke(Color(red: 4/255, green: 4/255, blue: 4/255))
                        .frame(width: size * 0.35, height: size * 0.35)
                    
                    Image(systemName: isPlaying ? "stop.fill" : "play.fill")
                        .font(.system(size: size * 0.12, weight: .bold))
                        .foregroundColor(.white)
                        .offset(x: isPlaying ? 0 : size * 0.006) // Slight offset for play button visual balance
                }
            }
            .buttonStyle(.plain)
        }
        .frame(width: arcFrameSize, height: arcFrameSize) // Constrain the entire component to its actual size
    }
}

// MARK: - Tempo Dial Component (unchanged)
struct TempoDialView: View {
    let size: CGFloat
    let bpm: Int
    let onTempoChange: (Int) -> Void
    
    @State private var currentRotation: Double = 0
    @State private var lastRotation: Double = 0
    
    // Gray circle size multiplier - increased to make dial bigger
    private let grayCircleMultiplier: CGFloat = 0.72
    
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
    
    // Dial size variables - make circle fit exactly in the square outline
    private var totalDialDiameter: CGFloat { size * grayCircleMultiplier }
    private var donutHoleDiameter: CGFloat { size * 0.45 }
    private var dialWidth: CGFloat { (totalDialDiameter - donutHoleDiameter) / 2 }
    
    var body: some View {
        ZStack {
            // Full filled circle (no hole)
 
            Circle()
                       .fill(
                           LinearGradient(
                               gradient: Gradient(colors: [
                                   Color(red: 3/255, green: 3/255, blue: 3/255),
                                   Color(red: 1/255, green: 1/255, blue: 2/255)
                               ]),
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing
                           )
                       )
                       .frame(width: totalDialDiameter + 10, height: totalDialDiameter + 10)
                   
                   Circle()
                       .fill(
                           LinearGradient(
                               gradient: Gradient(colors: [
                                    Color(red: 4/255, green: 4/255, blue: 5/255),
                                   Color(red: 2/255, green: 2/255, blue: 3/255)
                               ]),
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing
                           )
                       )
                       .frame(width: totalDialDiameter, height: totalDialDiameter)
            
            Circle()
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 20/255, green: 20/255, blue: 20/255).opacity(0.5),
                            Color(red: 18/255, green: 18/255, blue: 18/255).opacity(0.5)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 8
                )
                .frame(width: totalDialDiameter, height: totalDialDiameter)
                .blur(radius: 0.5)

            
            // Circle indicator - positioned closer to outer edge and made slightly bigger
            Circle()
                .fill(Color(red: 43/255, green: 44/255, blue: 44/255).opacity(0.9))
                .frame(width: totalDialDiameter * 0.08, height: totalDialDiameter * 0.08)
                .offset(y: -(totalDialDiameter/2 - totalDialDiameter * 0.1))
                .rotationEffect(.degrees(currentRotation))
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    // Calculate angle from center to current touch point
                    let center = CGPoint(x: totalDialDiameter/2, y: totalDialDiameter/2)
                    let vector = CGPoint(x: value.location.x - center.x, y: value.location.y - center.y)
                    let angle = atan2(vector.y, vector.x) * 180 / .pi
                    
                    // Convert to 0-360 range
                    let normalizedAngle = angle < 0 ? angle + 360 : angle
                    
                    // Initialize lastRotation on first touch to prevent jumping
                    if lastRotation == 0 {
                        lastRotation = normalizedAngle
                        return
                    }
                    
                    // Calculate rotation difference
                    let angleDifference = normalizedAngle - lastRotation
                    var adjustedDifference = angleDifference
                    
                    // Handle angle wrapping (crossing 0/360 boundary)
                    if adjustedDifference > 180 {
                        adjustedDifference -= 360
                    } else if adjustedDifference < -180 {
                        adjustedDifference += 360
                    }
                    
                    // Check BPM limits before updating rotation
                    let canRotate: Bool
                    if bpm >= 400 && adjustedDifference > 0 {
                        canRotate = false
                    } else if bpm <= 40 && adjustedDifference < 0 {
                        canRotate = false
                    } else {
                        canRotate = true
                    }
                    
                    if canRotate {
                        currentRotation += adjustedDifference
                        currentRotation = max(180.0, min(1980.0, currentRotation))
                        lastRotation = normalizedAngle
                        
                        let newBPM = rotationToBpm(currentRotation)
                        onTempoChange(newBPM)
                    } else {
                        lastRotation = normalizedAngle
                    }
                }
                .onEnded { _ in
                    lastRotation = 0
                }
        )
        .onAppear {
            currentRotation = bpmToRotation(bpm)
        }
        .onChange(of: bpm) { _, newBPM in
            currentRotation = bpmToRotation(newBPM)
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
