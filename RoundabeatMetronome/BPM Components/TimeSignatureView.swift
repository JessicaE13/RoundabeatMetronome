import SwiftUI

struct TimeSignatureView: View {
    @ObservedObject var metronome: MetronomeEngine
    @Binding var showTimeSignaturePicker: Bool
    @Binding var showSettings: Bool
    
    // Tap tempo state
    @State private var lastTapTime: Date?
    @State private var tapTempoBuffer: [TimeInterval] = []
    @State private var tapCount: Int = 0
    
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
                        Text("TIME")
                            .font(.system(size: 8, weight: .medium))
                            .kerning(1.2)
                            .foregroundColor(Color.white.opacity(0.4))
                        
                        Text("\(metronome.beatsPerMeasure)")
                            .font(.custom("Kanit-Regular", size: 14))
                            .kerning(0.8)
                            .foregroundColor(Color.white.opacity(0.9))
                        
                        Text("/")
                            .font(.custom("Kanit-Regular", size: 14))
                            .kerning(0.8)
                            .foregroundColor(Color.white.opacity(0.7))
                        
                        Text("\(metronome.beatUnit)")
                            .font(.custom("Kanit-Regular", size: 14))
                            .kerning(0.8)
                            .foregroundColor(Color.white.opacity(0.9))
                    }
                    .frame(maxWidth: .infinity, minHeight: 38)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.black.opacity(0.4))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
                            )
                    )
                }
                .contentShape(Rectangle())
                
                // Rhythm Section
                Button(action: {
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    // Add rhythm selection logic here
                }) {
                    HStack(spacing: 6) {
                        Text("RHYTHM")
                            .font(.system(size: 8, weight: .medium))
                            .kerning(1.2)
                            .foregroundColor(Color.white.opacity(0.4))
                        
                        Image(systemName: "music.note")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color.white.opacity(0.9))
                    }
                    .frame(maxWidth: .infinity, minHeight: 38)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.black.opacity(0.4))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
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
                            .font(.system(size: 8, weight: .medium))
                            .kerning(1.2)
                            .foregroundColor(Color.white.opacity(0.4))
                        
                        // Show tap count or tempo icon
                        if tapCount > 0 {
                            Text("\(tapCount)")
                                .font(.custom("Kanit-Regular", size: 14))
                                .kerning(0.8)
                                .foregroundColor(Color.white.opacity(0.9))
                                .transition(.scale.combined(with: .opacity))
                        } else {
                            Image(systemName: "hand.tap")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color.white.opacity(0.9))
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 38)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(tapCount > 0 ? Color.white.opacity(0.15) : Color.black.opacity(0.4))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(tapCount > 0 ? Color.white.opacity(0.25) : Color.white.opacity(0.15), lineWidth: 1)
                            )
                    )
                    .scaleEffect(tapCount > 0 ? 1.02 : 1.0)
                    .animation(.easeInOut(duration: 0.1), value: tapCount)
                }
                .contentShape(Rectangle())
            }
            .padding(.horizontal, 8) // Match the padding from BPMView
        }
        .onReceive(Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()) { _ in
            // Reset tap count after 3 seconds of inactivity
            if let lastTap = lastTapTime, Date().timeIntervalSince(lastTap) > 3.0 {
                withAnimation(.easeOut(duration: 0.3)) {
                    tapCount = 0
                }
                tapTempoBuffer.removeAll()
                lastTapTime = nil
            }
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
                
                // Increment tap count with animation
                withAnimation(.easeInOut(duration: 0.15)) {
                    tapCount += 1
                }
                
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
                // If tap is too fast or too slow, reset buffer but keep visual feedback
                tapTempoBuffer.removeAll()
                withAnimation(.easeInOut(duration: 0.15)) {
                    tapCount = 1 // Reset to 1 since this is the first valid tap
                }
            }
            
            // If tap is way too fast, reset everything
            if timeDiff < 0.25 {
                tapTempoBuffer.removeAll()
                withAnimation(.easeOut(duration: 0.3)) {
                    tapCount = 0
                }
            }
        } else {
            // First tap
            withAnimation(.easeInOut(duration: 0.15)) {
                tapCount = 1
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
            showSettings: .constant(false)
        )
    }
}
