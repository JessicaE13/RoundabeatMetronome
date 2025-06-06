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
            HStack(spacing: AdaptiveSizing.current.spacing(16)) {
                // Time Signature Section
                Button(action: {
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    showTimeSignaturePicker = true
                }) {
                    HStack(spacing: AdaptiveSizing.current.spacing(2)) {
                        Text("TIME  ")
                            .adaptiveFont(.subheadline, weight: .medium)
                            .kerning(AdaptiveSizing.current.spacing(1.2))
                            .foregroundColor(Color.white.opacity(0.6))
                        
                        Text("\(metronome.beatsPerMeasure)")
                            .adaptiveFont(.subheadline, weight: .medium)
                            .kerning(AdaptiveSizing.current.spacing(0.8))
                            .glowingAccent(size: AdaptiveSizing.current.size(24), intensity: 0.6)
                        
                        Text("/")
                            .adaptiveFont(.subheadline, weight: .medium)
                            .kerning(AdaptiveSizing.current.spacing(0.8))
                            .glowingAccent(size: AdaptiveSizing.current.size(24), intensity: 0.6)
                        
                        Text("\(metronome.beatUnit)")
                            .adaptiveFont(.subheadline, weight: .medium)
                            .kerning(AdaptiveSizing.current.spacing(0.8))
                            .glowingAccent(size: AdaptiveSizing.current.size(24), intensity: 0.6)
                    }
                    .frame(maxWidth: .infinity, minHeight: buttonHeight())
                    .background(
                        RoundedRectangle(cornerRadius: AdaptiveSizing.current.cornerRadius(12))
                            .fill(Color.black.opacity(0.6))
                            .overlay(
                                RoundedRectangle(cornerRadius: AdaptiveSizing.current.cornerRadius(12))
                                    .stroke(Color.white.opacity(0.25), lineWidth: AdaptiveSizing.current.lineWidth(1))
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
                    HStack(spacing: AdaptiveSizing.current.spacing(6)) {
                        Text(subdivisionLabelText())
                            .adaptiveFont(.subheadline, weight: .medium)
                            .kerning(AdaptiveSizing.current.spacing(1.2))
                            .foregroundColor(Color.white.opacity(0.6))
                        
                        // Display the current subdivision symbol
                        Text(getSubdivisionSymbol())
                            .adaptiveFont(.subheadline, weight: .medium)
                            .glowingAccent(size: AdaptiveSizing.current.size(24), intensity: 0.6)
                    }
                    .frame(maxWidth: .infinity, minHeight: buttonHeight())
                    .background(
                        RoundedRectangle(cornerRadius: AdaptiveSizing.current.cornerRadius(12))
                            .fill(Color.black.opacity(0.6))
                            .overlay(
                                RoundedRectangle(cornerRadius: AdaptiveSizing.current.cornerRadius(12))
                                    .stroke(Color.white.opacity(0.25), lineWidth: AdaptiveSizing.current.lineWidth(1))
                            )
                    )
                }
                .contentShape(Rectangle())
                
                // Tap Tempo Section
                Button(action: {
                    calculateTapTempo()
                }) {
                    HStack(spacing: AdaptiveSizing.current.spacing(6)) {
                        Text("TAP")
                            .adaptiveFont(.subheadline, weight: .medium)
                            .kerning(AdaptiveSizing.current.spacing(1.0))
                            .foregroundColor(Color.white.opacity(0.6))
                        
                        Image(systemName: "hand.tap")
                            .adaptiveFont(.subheadline, weight: .medium)
                            .glowingAccent(size: AdaptiveSizing.current.size(24), intensity: 0.6)
                    }
                    .frame(maxWidth: .infinity, minHeight: buttonHeight())
                    .background(
                        RoundedRectangle(cornerRadius: AdaptiveSizing.current.cornerRadius(12))
                            .fill(Color.black.opacity(0.6))
                            .overlay(
                                RoundedRectangle(cornerRadius: AdaptiveSizing.current.cornerRadius(12))
                                    .stroke(Color.white.opacity(0.25), lineWidth: AdaptiveSizing.current.lineWidth(1))
                            )
                    )
                }
                .contentShape(Rectangle())
            }
            .adaptivePadding(.horizontal, 8)
        }
    }
    
    // Device-specific button height
    private func buttonHeight() -> CGFloat {
        switch DeviceType.current {
        case .iPhoneSmall:
            return AdaptiveSizing.current.size(34)  // Slightly shorter for small iPhones
        default:
            return AdaptiveSizing.current.size(38)  // Standard height
        }
    }
    
    // Device-specific subdivision label text
    private func subdivisionLabelText() -> String {
        switch DeviceType.current {
        case .iPhoneSmall:
            return "SUB"  // Shorter text for small devices
        default:
            return "SUB DIV."  // Full text for larger devices
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
            return "♪×3"   // Eighth note triplet
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
