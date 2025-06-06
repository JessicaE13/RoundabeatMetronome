import SwiftUI

struct TimeSignatureView: View {
    @ObservedObject var metronome: MetronomeEngine
    @Binding var showTimeSignaturePicker: Bool
    @Binding var showSettings: Bool
    @Binding var showSubdivisionPicker: Bool
    
    // Tap tempo state
    @State private var lastTapTime: Date?
    @State private var tapTempoBuffer: [TimeInterval] = []
    
    var body: some View {
        ZStack {
            // Single horizontal row containing all three buttons
            HStack(spacing: 16) {
                // Time Signature Section
                Button(action: {
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    showTimeSignaturePicker = true
                }) {
                    HStack(spacing: 2) {
                        Text("TIME  ")
                            .font(.system(.subheadline, weight: .medium))
                            .kerning(1.2)
                            .foregroundColor(Color.white.opacity(0.6))
                        
                        Text("\(metronome.beatsPerMeasure)")
                            .font(.custom("Kanit-Regular", size: 14))
                            .kerning(0.8)
                            .glowingAccent(size: 24, intensity: 0.6)
                        
                        Text("/")
                            .font(.custom("Kanit-Regular", size: 14))
                            .kerning(0.8)
                            .glowingAccent(size: 24, intensity: 0.6)
                        
                        Text("\(metronome.beatUnit)")
                            .font(.custom("Kanit-Regular", size:  14))
                            .kerning(0.8)
                            .glowingAccent(size: 24, intensity: 0.6)
                    }
                    .frame(maxWidth: .infinity, minHeight: 38)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.black.opacity(0.6))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.25), lineWidth: 1)
                            )
                    )
                }
                .contentShape(Rectangle())
                
                // Subdivision Section - Updated to work properly
                Button(action: {
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    showSubdivisionPicker = true
                }) {
                    HStack(spacing: 6) {
                        Text("SUB DIV.")
                            .font(.system(.subheadline, weight: .medium))
                            .kerning(1.2)
                            .foregroundColor(Color.white.opacity(0.6))
                        
                        // Display the current subdivision symbol
                        Text(getSubdivisionSymbol())
                            .font(.system(.headline, weight: .medium))
                            .glowingAccent(size:  24, intensity: 0.6)
                    }
                    .frame(maxWidth: .infinity, minHeight: 38)
                    .background(
                        RoundedRectangle(cornerRadius:  12)
                            .fill(Color.black.opacity(0.6))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.25), lineWidth: 1)
                            )
                    )
                }
                .contentShape(Rectangle())
                
                // Tap Tempo Section
                Button(action: {
                    calculateTapTempo()
                }) {
                    HStack(spacing: 6) {
                        Text("TAP")
                            .font(.system(.subheadline, weight: .medium))
                            .kerning(1.0)
                            .foregroundColor(Color.white.opacity(0.6))
                        
                        Image(systemName: "hand.tap")
                            .font(.system(.subheadline, weight: .medium))
                            .glowingAccent(size: 24, intensity: 0.6)
                    }
                    .frame(maxWidth: .infinity, minHeight: 38)
                    .background(
                        RoundedRectangle(cornerRadius:  12)
                            .fill(Color.black.opacity(0.6))
                            .overlay(
                                RoundedRectangle(cornerRadius:  12)
                                    .stroke(Color.white.opacity(0.25), lineWidth: 1)
                            )
                    )
                }
                .contentShape(Rectangle())
            }
            .padding(.horizontal,  8)
        }
    }
    
    // Helper function to get the current subdivision symbol
    private func getSubdivisionSymbol() -> String {
        switch metronome.subdivisionMultiplier {
        case 1.0:
            return "♩"     // Quarter note
        case 1.5:
            return "♪."    // Dotted eighth
        case 2.0:
            return "♫"     // Eighth note
        case 3.0:
            return "♫♫♫"   // Eighth note triplet
        case 4.0:
            return "♬"     // Sixteenth note
        default:
            return "♩"     // Default to quarter note
        }
    }
    
    // Tap tempo calculation function
    private func calculateTapTempo() {
        let now = Date()
        
        // Add haptic feedback for tap
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        if let lastTap = lastTapTime {
            // Calculate time difference
            let timeDiff = now.timeIntervalSince(lastTap)
            
            // Only use reasonable tap intervals (between 40 and 240 BPM)
            if timeDiff > 0.25 && timeDiff < 1.5 {
                // Add to buffer
                tapTempoBuffer.append(timeDiff)
                
                // Keep only the last 4 taps for accuracy
                if tapTempoBuffer.count > 4 {
                    tapTempoBuffer.removeFirst()
                }
                
                // Calculate average from buffer (need at least 2 taps)
                if tapTempoBuffer.count >= 2 {
                    let averageInterval = tapTempoBuffer.reduce(0, +) / Double(tapTempoBuffer.count)
                    let calculatedTempo = min(240, max(40, 60.0 / averageInterval))
                    
                    // Round to nearest integer
                    let roundedTempo = round(calculatedTempo)
                    
                    // Update metronome tempo
                    metronome.updateTempo(to: roundedTempo)
                }
            } else {
                // If tap is too fast or too slow, reset buffer
                tapTempoBuffer.removeAll()
            }
            
            // If tap is way too fast, reset everything
            if timeDiff < 0.25 {
                tapTempoBuffer.removeAll()
            }
        }
        
        // Update last tap time
        lastTapTime = now
    }
}

#Preview {
    ZStack {
        BackgroundView()
        TimeSignatureView(
            metronome: MetronomeEngine(),
            showTimeSignaturePicker: .constant(false),
            showSettings: .constant(false),
            showSubdivisionPicker: .constant(false)
        )
    }
}
