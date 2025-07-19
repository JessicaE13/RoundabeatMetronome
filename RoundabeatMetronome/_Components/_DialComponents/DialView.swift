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
    private var frameSize: CGFloat { size + maxStrokeWidth * 0.5 }
    
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
        let fixedGapDegrees: Double = 14.0 // 16 degrees gap between segments
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
                        lineWidth: shouldShowNormalActive ? 1.0 : 1.75)
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
            
            // Replace the "Normal active state" section in BeatArc with this enhanced version:

            // Normal active state (only for first beat when emphasizeFirstBeatOnly is true, or all beats when false)
            if shouldShowNormalActive {
                // Base gradient fill with gray shadows - simulates natural lighting on a raised surface
                arcPath
                    .strokedPath(StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                    .fill(
                        RadialGradient(
                            gradient: Gradient(stops: [
                                .init(color: Color.white, location: 0.0),                                    // Bright center
                                .init(color: Color.white.opacity(0.95), location: 0.15),                    // Near-white
                                .init(color: Color.white.opacity(0.8), location: 0.3),                      // Light area
                                .init(color: Color(white: 0.85).opacity(0.9), location: 0.5),               // Light gray transition
                                .init(color: Color(white: 0.7).opacity(0.8), location: 0.7),                // Medium gray
                                .init(color: Color(white: 0.55).opacity(0.7), location: 0.85),              // Darker gray shadow
                                .init(color: Color(white: 0.4).opacity(0.5), location: 1.0)                 // Dark edge shadow
                            ]),
                            center: UnitPoint(x: 0.35, y: 0.25), // Light source from top-left
                            startRadius: 0,
                            endRadius: lineWidth * 1.2
                        )
                    )
                
                // Shadow area on the opposite side from light source
                arcPath
                    .strokedPath(StrokeStyle(lineWidth: lineWidth * 0.8, lineCap: .round))
                    .fill(
                        RadialGradient(
                            gradient: Gradient(stops: [
                                .init(color: Color.clear, location: 0.0),
                                .init(color: Color(white: 0.3).opacity(0.2), location: 0.4),
                                .init(color: Color(white: 0.2).opacity(0.4), location: 0.7),
                                .init(color: Color(white: 0.1).opacity(0.3), location: 1.0)
                            ]),
                            center: UnitPoint(x: 0.7, y: 0.8), // Shadow area bottom-right
                            startRadius: 0,
                            endRadius: lineWidth * 0.6
                        )
                    )
                
                // Inner bright core - the "hot spot" of the light
                arcPath
                    .strokedPath(StrokeStyle(lineWidth: lineWidth * 0.5, lineCap: .round))
                    .fill(
                        RadialGradient(
                            gradient: Gradient(stops: [
                                .init(color: Color.white, location: 0.0),
                                .init(color: Color.white.opacity(0.95), location: 0.3),
                                .init(color: Color(white: 0.9).opacity(0.8), location: 0.7),
                                .init(color: Color(white: 0.8).opacity(0.6), location: 1.0)
                            ]),
                            center: UnitPoint(x: 0.3, y: 0.2), // Bright spot offset toward light
                            startRadius: 0,
                            endRadius: lineWidth * 0.25
                        )
                    )
                
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
                    .fill(Color("Background2").opacity(0.7))
                    .shadow(color: Color(red: 101/255, green: 101/255, blue: 102/255).opacity(0.13),
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
    
    // NEW: Arc circle size multiplier - adjust this to make the arc circle smaller/larger
    private let arcCircleMultiplier: CGFloat = 0.94  // Experiment with values like 0.8, 0.9, 1.1, etc.
    
    // FIXED: Consistent frame size calculations with new multiplier
    private var arcWidth: CGFloat { size * 0.1 }
    private var activeArcWidth: CGFloat { arcWidth * 1.0 } // Match BeatArc
    private var maxStrokeWidth: CGFloat { activeArcWidth }
    private var arcFrameSize: CGFloat { size + maxStrokeWidth }
    
    // Apply the multiplier to the arc size passed to BeatArc
    private var adjustedArcSize: CGFloat { size * arcCircleMultiplier }
    
    var body: some View {
        ZStack {
            // Beat arc segments - now using adjustedArcSize
            ForEach(1...beatsPerBar, id: \.self) { beatNumber in
                BeatArc(
                    beatNumber: beatNumber,
                    totalBeats: beatsPerBar,
                    isActive: currentBeat == beatNumber && isPlaying,
                    size: adjustedArcSize,  // Using adjusted size here
                    emphasizeFirstBeatOnly: emphasizeFirstBeatOnly
                )
            }
            
            // Tempo dial - circle that touches the square edges, use the same size as the arc frame
            let dialSize = arcFrameSize
            
            TempoDialView(size: dialSize, bpm: bpm, onTempoChange: onTempoChange)
            
            // Center play/stop button - made slightly bigger with elevated outline
            Button(action: onTogglePlay) {
                ZStack {
                    let buttonSize = size * 0.28
                    
// MARK: - Play button
                    
                // Play button background circle fill
                    Circle()
                        .fill(Color("Background2").opacity(1.0))
                        .frame(width: buttonSize, height: buttonSize)
                        .shadow(color: Color.black.opacity(0.4),
                                radius: 2, x: 0, y: 1)
                
                // Play button background circle outline
                    Circle()
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(stops: [
                                    .init(color: Color.white.opacity(0.4), location: 0.0),
                                    .init(color: Color.white.opacity(0.3), location: 1.0)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2.0
                        )
                        .frame(width: buttonSize, height: buttonSize)
                    
                // Play button outer outline
                    Circle()
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(stops: [
                                    .init(color: Color("Gray1").opacity(0.2), location: 0.0),
                                    .init(color: Color("Gray1").opacity(0.12), location: 1.0)
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



// MARK: - Enhanced Tempo Dial Component with Haptics
struct TempoDialView: View {
    let size: CGFloat
    let bpm: Int
    let onTempoChange: (Int) -> Void
    
    @State private var currentRotation: Double = 0
    @State private var isDragging: Bool = false
    @State private var lastDragAngle: Double = 0
    @State private var accumulatedRotation: Double = 0
    
    // NEW: Haptic feedback state
    @State private var lastHapticBPM: Int = 0
    @State private var hapticFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    
    private let grayCircleMultiplier: CGFloat = 0.64
    private let petalCount = 30
    
    // BPM to rotation mapping - 5 complete rotations from 40 to 400 BPM
    private func bpmToRotation(_ bpm: Int) -> Double {
        let bpmRange = 400.0 - 40.0  // 360 BPM range
        let totalRotations = 5.0     // 5 full rotations
        let rotationRange = totalRotations * 360.0  // 1800° total range
        let bpmProgress = (Double(bpm) - 40.0) / bpmRange
        return 180.0 + (bpmProgress * rotationRange) // 180° to 1980°
    }
    
    private func rotationToBpm(_ rotation: Double) -> Int {
        let totalRotations = 5.0
        let rotationRange = totalRotations * 360.0
        let bpmRange = 400.0 - 40.0
        
        // Normalize rotation to 180-1980° range
        let adjustedRotation = max(180.0, min(1980.0, rotation))
        let rotationProgress = (adjustedRotation - 180.0) / rotationRange
        let bpm = 40.0 + (rotationProgress * bpmRange)
        return max(40, min(400, Int(bpm.rounded())))
    }
    
    // Calculate angle from center to a point (0-360°)
    private func angleFromCenter(_ location: CGPoint, center: CGPoint) -> Double {
        let vector = CGPoint(x: location.x - center.x, y: location.y - center.y)
        let angle = atan2(vector.y, vector.x) * 180 / .pi
        // Convert to 0-360 range
        return angle < 0 ? angle + 360 : angle
    }
    
    // Calculate the shortest angular distance between two angles
    private func angleDifference(from: Double, to: Double) -> Double {
        let diff = to - from
        if diff > 180 {
            return diff - 360
        } else if diff < -180 {
            return diff + 360
        }
        return diff
    }
    
    // NEW: Trigger haptic feedback for BPM changes
    private func triggerHapticForBPMChange(_ newBPM: Int) {
        // Only trigger haptic if BPM actually changed and we're dragging
        if isDragging && newBPM != lastHapticBPM {
            hapticFeedbackGenerator.impactOccurred(intensity: 0.5)
            lastHapticBPM = newBPM
        }
    }
    
    // Dial size variables
    private var totalDialDiameter: CGFloat { size * grayCircleMultiplier }
    private var donutHoleDiameter: CGFloat { size * 0.45 }
    private var dialWidth: CGFloat { (totalDialDiameter - donutHoleDiameter) / 2 }
    
    private var innerCircleDiameter: CGFloat {
        let parabolaOffset = totalDialDiameter/2 - totalDialDiameter * 0.05
        let parabolaHeight = totalDialDiameter * 0.06
        return (parabolaOffset - parabolaHeight/2) * 2
    }
    
    var body: some View {
        ZStack {
            // Thick gray outer border
            Circle()
                .fill(Color.black.opacity(0.4))
                .frame(width: totalDialDiameter + 20, height: totalDialDiameter + 20)
                .blur(radius: 2.6)
                .offset(x: 1, y: 2)
            
            Circle()
                .strokeBorder(
                    LinearGradient(
                        colors: [Color("Gray1").opacity(0.8), Color("Gray1").opacity(0.4)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 8
                )
                .frame(width: totalDialDiameter + 20, height: totalDialDiameter + 20)
            
            // Rotating parabola outline
            ZStack {
                ForEach(0..<petalCount, id: \.self) { i in
                    let baseRotation = Double(i) * (360.0 / Double(petalCount))
                    let totalRotation = baseRotation + currentRotation
                    
                    EllipsePetalWithDynamicShadow(rotationAngle: totalRotation)
                        .frame(width: totalDialDiameter * 0.08, height: totalDialDiameter * 0.025)
                        .offset(y: -(totalDialDiameter/2 - totalDialDiameter * 0.02))
                        .rotationEffect(.degrees(baseRotation))
                }
            }
            .rotationEffect(.degrees(currentRotation))
            
            // Inner dark/black circle
            Circle()
                .fill(Color(red: 15/255, green: 15/255, blue: 17/255))
                .frame(width: innerCircleDiameter + 8, height: innerCircleDiameter + 8)

            Circle()
                .stroke(Color("AccentColor").opacity(0.9), lineWidth: 2)
                .frame(width: innerCircleDiameter + 12, height: innerCircleDiameter + 12)
            
            // Capsule indicator
            Capsule()
                .fill(Color.white)
                .frame(width: totalDialDiameter * 0.01, height: totalDialDiameter * 0.08)
                .offset(y: -(totalDialDiameter/2 - totalDialDiameter * 0.14))
                .rotationEffect(.degrees(currentRotation))
                .shadow(color: Color.black.opacity(0.3), radius: 1, x: 0, y: 1)
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    let center = CGPoint(x: totalDialDiameter/2, y: totalDialDiameter/2)
                    let currentAngle = angleFromCenter(value.location, center: center)
                    
                    if !isDragging {
                        // Start of drag - prepare haptic generator and set initial state
                        isDragging = true
                        lastDragAngle = currentAngle
                        accumulatedRotation = currentRotation
                        lastHapticBPM = bpm
                        hapticFeedbackGenerator.prepare() // Prepare for responsive haptics
                    } else {
                        // Calculate the angular change
                        let angleDelta = angleDifference(from: lastDragAngle, to: currentAngle)
                        
                        // Update accumulated rotation
                        accumulatedRotation += angleDelta
                        
                        // Apply constraints: 180° to 1980° (bottom position + 5 full rotations)
                        let clampedRotation = max(180.0, min(1980.0, accumulatedRotation))
                        
                        // Convert to BPM and check if it's valid
                        let newBPM = rotationToBpm(clampedRotation)
                        
                        if newBPM >= 40 && newBPM <= 400 {
                            currentRotation = clampedRotation
                            accumulatedRotation = clampedRotation
                            
                            // NEW: Trigger haptic feedback for BPM change
                            triggerHapticForBPMChange(newBPM)
                            
                            onTempoChange(newBPM)
                        }
                        
                        lastDragAngle = currentAngle
                    }
                }
                .onEnded { _ in
                    isDragging = false
                    lastDragAngle = 0
                    lastHapticBPM = 0 // Reset haptic tracking
                }
        )
        .onAppear {
            let initialRotation = bpmToRotation(bpm)
            currentRotation = initialRotation
            accumulatedRotation = initialRotation
            lastHapticBPM = bpm
        }
        .onChange(of: bpm) { _, newBPM in
            if !isDragging {
                let newRotation = bpmToRotation(newBPM)
                currentRotation = newRotation
                accumulatedRotation = newRotation
                lastHapticBPM = newBPM
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
                metronome.handleBPMChangeForDialTick(newBPM : newBPM)
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
