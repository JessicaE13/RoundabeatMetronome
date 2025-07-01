import SwiftUI

// MARK: - Individual Beat Arc (Fixed multiplier consistency)


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
                BeatArcView(
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
                        .fill(Color(red: 30/255, green: 30/255, blue: 31/255))
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


// MARK: - Tempo Dial Component with DJ-style appearance and tapered beveled edges
struct TempoDialView: View {
    let size: CGFloat
    let bpm: Int
    let onTempoChange: (Int) -> Void
    
    @State private var currentRotation: Double = 0
    @State private var lastRotation: Double = 0
    
    private let grayCircleMultiplier: CGFloat = 0.72
    private let notchCount: Int = 25 // Number of notches around the dial
    private let notchWidth: CGFloat = 0.08 // Relative width of each notch
    private let notchHeight: CGFloat = 0.08 // Relative height of each notch
    
    private func bpmToRotation(_ bpm: Int) -> Double {
        let bpmRange = 400.0 - 40.0
        let totalRotations = 5.0
        let rotationRange = totalRotations * 360.0
        let bpmProgress = (Double(bpm) - 40.0) / bpmRange
        return 180.0 + (bpmProgress * rotationRange)
    }
    
    private func rotationToBpm(_ rotation: Double) -> Int {
        let totalRotations = 5.0
        let rotationRange = totalRotations * 360.0
        let bpmRange = 400.0 - 40.0
        let rotationProgress = (rotation - 180.0) / rotationRange
        let bpm = 40.0 + (rotationProgress * bpmRange)
        return max(40, min(400, Int(bpm.rounded())))
    }
    
    private var totalDialDiameter: CGFloat { size * grayCircleMultiplier }
    private var donutHoleDiameter: CGFloat { size * 0.45 }
    private var dialWidth: CGFloat { (totalDialDiameter - donutHoleDiameter) / 2 }
    
    var body: some View {
        ZStack {
            // DJ-style dial with static lighting and rotating bevels
            ZStack {
                // STATIC LIGHTING/GRADIENT LAYER - These provide the lighting effects and don't rotate
                ZStack {
                    // Outermost dark ring (base shadow) - STATIC
                    Circle()
                        .fill(Color(red: 20/255, green: 20/255, blue: 22/255))
                        .frame(width: totalDialDiameter * 1.08, height: totalDialDiameter * 1.08)
                        .shadow(color: Color.black.opacity(0.6), radius: 8, x: 3, y: 3)
                    
                    // Static beveled ring gradients with wider raised outer edge - LIGHTING STAYS FIXED
                    // Outer bevel edge - wider to appear more raised
                    Circle()
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 85/255, green: 85/255, blue: 90/255),
                                    Color(red: 45/255, green: 45/255, blue: 46/255),
                                    Color(red: 25/255, green: 25/255, blue: 26/255)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: totalDialDiameter * 0.05
                        )
                        .frame(width: totalDialDiameter , height: totalDialDiameter )
                    
                    // Inner bevel highlight - keep thin for contrast
                    Circle()
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 95/255, green: 95/255, blue: 97/255),
                                    Color(red: 40/255, green: 40/255, blue: 42/255)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: totalDialDiameter * 0.025
                        )
                        .frame(width: totalDialDiameter * 0.93, height: totalDialDiameter * 0.93)
                        .blur(radius: 1)
                    
                    // Static dial surface lighting
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 200/255, green: 60/255, blue: 65/255),
                                    Color(red: 200/255, green: 40/255, blue: 45/255),
                                    Color(red: 200/255, green: 25/255, blue: 28/255)
                                ]),
                                center: .center,
                                startRadius: 0,
                                endRadius: totalDialDiameter * 0.5
                            )
                        )
                        .frame(width: totalDialDiameter * 0.9, height: totalDialDiameter * 0.9)
                    
                    // Static center highlight
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.15),
                                    Color.clear
                                ]),
                                center: .topLeading,
                                startRadius: 5,
                                endRadius: totalDialDiameter * 0.3
                            )
                        )
                        .frame(width: totalDialDiameter * 0.94, height: totalDialDiameter * 0.94)
                    
                    // Static notch shadows
                    ForEach(0..<notchCount, id: \.self) { index in
                        Circle()
                            .fill(Color.clear)
                            .frame(width: totalDialDiameter * notchWidth, height: totalDialDiameter * notchHeight)
                            .shadow(color: Color.black.opacity(0.4), radius: 1, x: 0.5, y: 0.5)
                            .shadow(color: Color.white.opacity(0.1), radius: 1, x: -0.5, y: -0.5)
                            .offset(y: -(totalDialDiameter / 2))
                            .rotationEffect(.degrees(Double(index) * 360.0 / Double(notchCount)))
                    }
                    
                    // Static circle indicator shadow
                    Circle()
                        .fill(Color.clear)
                        .frame(width: totalDialDiameter * 0.08, height: totalDialDiameter * 0.08)
                        .shadow(color: Color.black.opacity(0.5), radius: 2, x: 1, y: 1)
                        .offset(y: -(totalDialDiameter / 2 - totalDialDiameter * 0.1))
                        .rotationEffect(.degrees(bpmToRotation(bpm)))
                }
                
                // ROTATING PHYSICAL ELEMENTS - Only the physical structure rotates
                ZStack {
                    // Rotating dial base (solid color) - moved up to be behind bevels
                    Circle()
                        .fill(Color(red: 45/255, green: 45/255, blue: 50/255))
                        .frame(width: totalDialDiameter * 0.9, height: totalDialDiameter * 0.9)
                        .opacity(0.2) // More transparent to blend better
                    
                    // Rotating beveled ring structures with wider raised outer edge - softer blending
                    // Outer rotating bevel edge - wider to match raised appearance
                    Circle()
                        .stroke(Color(red: 50/255, green: 50/255, blue: 55/255), lineWidth: totalDialDiameter * 0.045)
                        .frame(width: totalDialDiameter * 1.02, height: totalDialDiameter * 1.02)
                        .opacity(0.12)
                        .blendMode(.multiply)
                    
                    // Inner rotating bevel highlight - keep thin for contrast
                    Circle()
                        .stroke(Color(red: 60/255, green: 60/255, blue: 65/255), lineWidth: totalDialDiameter * 0.012)
                        .frame(width: totalDialDiameter * 0.98, height: totalDialDiameter * 0.98)
                        .opacity(0.08)
                        .blendMode(.multiply)
                    
                    // Rotating notches (softer appearance)
                    ForEach(0..<notchCount, id: \.self) { index in
                        Circle()
                            .fill(Color(red: 20/255, green: 20/255, blue: 25/255))
                            .frame(width: totalDialDiameter * notchWidth, height: totalDialDiameter * notchHeight)
                            .opacity(0.6) // More transparent for smoother look
                            .offset(y: -(totalDialDiameter / 2))
                            .rotationEffect(.degrees(Double(index) * 360.0 / Double(notchCount)))
                    }
                    
                    // Rotating circle indicator (more prominent)
                    Circle()
                        .fill(Color(red: 30/255, green: 30/255, blue: 35/255))
                        .frame(width: totalDialDiameter * 0.08, height: totalDialDiameter * 0.08)
                        .opacity(0.8) // Keep this more visible
                        .offset(y: -(totalDialDiameter / 2 - totalDialDiameter * 0.1))
                }
                .rotationEffect(.degrees(currentRotation)) // Only the physical elements rotate
            }
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    let center = CGPoint(x: totalDialDiameter/2, y: totalDialDiameter/2)
                    let vector = CGPoint(x: value.location.x - center.x, y: value.location.y - center.y)
                    let angle = atan2(vector.y, vector.x) * 180 / .pi
                    let normalizedAngle = angle < 0 ? angle + 360 : angle
                    
                    if lastRotation == 0 {
                        lastRotation = normalizedAngle
                        return
                    }
                    
                    let angleDifference = normalizedAngle - lastRotation
                    var adjustedDifference = angleDifference
                    
                    if adjustedDifference > 180 {
                        adjustedDifference -= 360
                    } else if adjustedDifference < -180 {
                        adjustedDifference += 360
                    }
                    
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

// MARK: - Dial View

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
        .shadow(color: Color.black.opacity(0.3), radius: 15, x: 5, y: 5)
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
