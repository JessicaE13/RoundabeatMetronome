import SwiftUI

// MARK: - Individual Beat Arc (Fixed multiplier consistency)

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
    
    var body: some View {
        ZStack {
            // Drop shadow for depth
            Circle()
                .fill(Color.black)
                .frame(width: size * 0.6 * 1.05, height: size * 0.6 * 1.05)
                .offset(y: size * 0.6 * 0.04)
                .blur(radius: size * 0.6 * 0.03)

            // Outer shell with black gradient
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color(white: 0.08),
                            Color(white: 0.02)
                        ]),
                        center: .center,
                        startRadius: size * 0.6 * 0.05,
                        endRadius: size * 0.6 * 0.5
                    )
                )
                .frame(width: size * 0.6, height: size * 0.6)

            // CRISP edge ring — like a subtle plastic lip
            Circle()
                .stroke(Color(white: 0.4), lineWidth: size * 0.6 * 0.006)
                .frame(width: size * 0.6, height: size * 0.6)

            // Inner dial face with black lighting (this rotates)
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color(white: 0.05),
                                Color(white: 0.01)
                            ]),
                            center: .topLeading,
                            startRadius: size * 0.6 * 0.1,
                            endRadius: size * 0.6 * 0.8
                        )
                    )
                    .frame(width: size * 0.6 * 0.85, height: size * 0.6 * 0.85)
                    .overlay(
                        Circle()
                            .stroke(Color.black.opacity(0.15), lineWidth: size * 0.6 * 0.005)
                    )
                
                // Rotating indicator dot to show position
                Circle()
                    .fill(Color.white.opacity(0.8))
                    .frame(width: size * 0.6 * 0.04, height: size * 0.6 * 0.04)
                    .offset(y: -(size * 0.6 * 0.85 / 2 - size * 0.6 * 0.08))
            }
            .rotationEffect(.degrees(currentRotation))
            
            // Center play button (static - doesn't rotate)
            ZStack {
                // Enlarged and slightly colored play button background
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.2, green: 0.2, blue: 0.2), // subtle glow
                                Color(red: 30/255, green: 30/255, blue: 31/255)
                            ]),
                            center: .center,
                            startRadius: 0,
                            endRadius: size * 0.7 * 0.2
                        )
                    )
                    .frame(width: size * 0.7 * 0.4, height: size * 0.7 * 0.4)
                    .shadow(color: Color.white.opacity(0.1), radius: size * 0.6 * 0.03, y: size * 0.6 * 0.01)

                Circle()
                    .stroke(Color(red: 4/255, green: 4/255, blue: 4/255), lineWidth: size * 0.6 * 0.005)
                    .frame(width: size * 0.6 * 0.5, height: size * 0.6 * 0.5)

                Image(systemName: "play.fill")
                    .font(.system(size: size * 0.7 * 0.16, weight: .heavy))
                    .foregroundColor(.white)
            }
        }
        .frame(width: size * 0.7, height: size * 0.7)
        .gesture(
            DragGesture()
                .onChanged { value in
                    let center = CGPoint(x: size * 0.6/2, y: size * 0.6/2)
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
