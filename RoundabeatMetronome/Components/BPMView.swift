import SwiftUI

// MARK: - BPM Display Component with Gestures

struct BPMView: View {
    
    @ObservedObject var metronome: MetronomeEngine
    @Binding var isShowingKeypad: Bool
    @Binding var showTimeSignaturePicker: Bool
    @State private var dragOffset: CGFloat = 0
    @State private var previousTempo: Double = 120
    
    var body: some View {
        
        ZStack {
            HStack {
                VStack {
                    // Time and Rhythm containers
                    VStack(spacing: 9) {
                        // First rectangle - TIME
                        ZStack {
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(LinearGradient(
                                    gradient: Gradient(colors: [Color.white.opacity(0.4), Color.white.opacity(0.3)]),
                                    startPoint: .top,
                                    endPoint: .bottomTrailing)
                                )
                                .frame(width: 75, height: 58)
                                .shadow(color: Color.white.opacity(0.2), radius: 1, x: 0, y: 0)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(Color.white.opacity(0.4), lineWidth: 0.5)
                                        .shadow(color: Color.white.opacity(0.1), radius: 0.5, x: 0, y: 0)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(Color.white.opacity(0.05))
                                )
                            // Time Signature Button - centered
                            VStack(spacing: 5) {
                                Text("TIME")
                                    .font(.system(size: 8, weight: .regular, design: .default))
                                    .foregroundColor(Color("colorDial").opacity(0.5))
                                    .lineLimit(nil)
                                
                                Button(action: {
                                    showTimeSignaturePicker = true
                                }) {
                                    Text("\(metronome.beatsPerMeasure) / \(metronome.beatUnit)")
                                        .font(.system(size: 14, weight: .bold, design: .default))
                                        .animation(.spring(), value: metronome.beatsPerMeasure)
                                        .foregroundColor(Color.black)
                                        .animation(.spring(), value: metronome.beatUnit)
                                        .frame(minWidth: 75)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            .frame(width: 75, height: 58) // Match the container size
                        }
                        
                        // Second rectangle - RHYTHM
                        ZStack {
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(LinearGradient(
                                    gradient: Gradient(colors: [Color.white.opacity(0.4), Color.white.opacity(0.3)]),
                                    startPoint: .top,
                                    endPoint: .bottomTrailing)
                                )
                                .frame(width: 75, height: 58)
                                .shadow(color: Color.white.opacity(0.2), radius: 1, x: 0, y: 0)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(Color.white.opacity(0.4), lineWidth: 0.5)
                                        .shadow(color: Color.white.opacity(0.1), radius: 0.5, x: 0, y: 0)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(Color.white.opacity(0.05))
                                )
                            
                            // Rhythm Button - centered
                            VStack(spacing: 5) {
                                Text("RHYTHM")
                                    .font(.system(size: 8, weight: .regular, design: .default))
                                    .foregroundColor(Color("colorDial").opacity(0.5))
                                    .lineLimit(nil)
                                
                                Button(action: {
                                    showTimeSignaturePicker = true
                                }) {
                                    Text("\(metronome.beatsPerMeasure) / \(metronome.beatUnit)")
                                        .font(.system(size: 14, weight: .bold, design: .default))
                                        .animation(.spring(), value: metronome.beatsPerMeasure)
                                        .foregroundColor(Color("colorDial"))
                                        .animation(.spring(), value: metronome.beatUnit)
                                        .frame(minWidth: 75)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            .frame(width: 75, height: 58) // Match the container size
                        }
                    }
                }
                
                
                // In the middle BPM section, we'll modify the existing ZStack to include the + and - buttons
                ZStack {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(LinearGradient(
                            gradient: Gradient(colors: [Color.white.opacity(0.4), Color.white.opacity(0.3)]),
                            startPoint: .top,
                            endPoint: .bottomTrailing)
                        )
                        .frame(width: 175, height: 125)
                        .shadow(color: Color.white.opacity(0.2), radius: 1, x: 0, y: 0)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.white.opacity(0.4), lineWidth: 0.5)
                                .shadow(color: Color.white.opacity(0.1), radius: 0.5, x: 0, y: 0)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .fill(Color.white.opacity(0.05))
                        )
                    
                    // BPM Display with gestures and +/- buttons
                    VStack {
                        Text("BPM")
                            .font(.system(size: 8, weight: .regular, design: .default))
                            .foregroundColor(Color("colorDial").opacity(0.5))
                            .lineLimit(nil)
                        
                        // Inside the HStack where the BPM display is shown
                        HStack {
                            // Decrease (-) Button with expanded tap area
                            Button(action: {
                                // Add subtle haptic feedback matching the swipe gesture
                                let generator = UIImpactFeedbackGenerator(style: .soft)
                                generator.impactOccurred(intensity: 0.5)
                                
                                // Decrease tempo by 1
                                metronome.updateTempo(to: metronome.tempo - 1)
                                previousTempo = metronome.tempo
                            }) {
                                Image(systemName: "minus")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color("colorDial").opacity(0.8))
                                    .frame(width: 40, height: 60) // Larger frame for touch target
                                    .contentShape(Rectangle()) // Make entire area tappable
                            }
                            .buttonStyle(PlainButtonStyle())
                            .frame(width: 25) // Keep visual width the same
                            
                            // BPM Display in a fixed-width container
                            Text("\(Int(metronome.tempo))")
                                .font(.system(size: 45, weight: .bold, design: .default))
                                .contentTransition(.numericText())
                                .foregroundColor(Color("colorDial"))
                                .multilineTextAlignment(.center)
                                .animation(.spring(response: 0.3), value: Int(metronome.tempo))
                                .frame(width: 90, alignment: .center) // Fixed width with center alignment
                                // Make the BPM text tappable to show keypad
                                .onTapGesture {
                                    // Add haptic feedback
                                    let generator = UIImpactFeedbackGenerator(style: .light)
                                    generator.impactOccurred()
                                    isShowingKeypad = true
                                }
                            
                            // Increase (+) Button with expanded tap area
                            Button(action: {
                                // Add subtle haptic feedback matching the swipe gesture
                                let generator = UIImpactFeedbackGenerator(style: .soft)
                                generator.impactOccurred(intensity: 0.5)
                                
                                // Increase tempo by 1
                                metronome.updateTempo(to: metronome.tempo + 1)
                                previousTempo = metronome.tempo
                            }) {
                                Image(systemName: "plus")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color("colorDial").opacity(0.8))
                                    .frame(width: 40, height: 60) // Larger frame for touch target
                                    .contentShape(Rectangle()) // Make entire area tappable
                            }
                            .buttonStyle(PlainButtonStyle())
                            .frame(width: 25) // Keep visual width the same
                        }
                        .frame(width: 150) // Fixed total width for the container
                        
                        Text("ALLEGRO")
                            .font(.system(size: 8, weight: .regular, design: .default))
                            .foregroundColor(Color("colorDial").opacity(0.5))
                            .lineLimit(nil)
                    }
                }
                // Apply the drag gesture to the entire BPM section
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            dragOffset = value.translation.height
                            
                            // Calculate tempo change based on drag distance
                            // Negative offset (swipe up) increases tempo
                            let tempoChange = -dragOffset * 0.2
                            let newTempo = previousTempo + tempoChange
                            
                            // Track previous value to detect changes
                            let oldTempoInt = Int(metronome.tempo)
                            
                            // Update tempo with clamping
                            metronome.updateTempo(to: newTempo)
                            
                            // If the integer value of the tempo changed, provide haptic feedback
                            if Int(metronome.tempo) != oldTempoInt {
                                // Subtle haptic feedback for each BPM change
                                let generator = UIImpactFeedbackGenerator(style: .soft)
                                generator.impactOccurred(intensity: 0.5)
                            }
                        }
                        .onEnded { _ in
                            // Reset drag offset
                            dragOffset = 0
                            // Store the current tempo for next drag
                            previousTempo = metronome.tempo
                            
                            // Add subtle haptic feedback matching the swipe gesture
                            let generator = UIImpactFeedbackGenerator(style: .soft)
                            generator.impactOccurred(intensity: 0.5)
                        }
                )
                
                VStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(LinearGradient(
                                gradient: Gradient(colors: [Color.white.opacity(0.4), Color.white.opacity(0.3)]),
                                startPoint: .top,
                                endPoint: .bottomTrailing)
                            )
                            .frame(width: 75, height: 125)
                            .shadow(color: Color.white.opacity(0.2), radius: 1, x: 0, y: 0)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color.white.opacity(0.4), lineWidth: 0.5)
                                    .shadow(color: Color.white.opacity(0.1), radius: 0.5, x: 0, y: 0)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(Color.white.opacity(0.05))
                            )
                        
                        // Tap Button
                        ZStack {
                            Image(systemName: "lock.fill")
                                .foregroundColor(Color("colorDial").opacity(0.4))
                                .padding(.bottom, 75.0)
                            
                            Text("TAP")
                                .font(.headline)
                                .foregroundColor(Color("colorDial"))
                                .fontWeight(.bold)
                                .lineLimit(nil)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ZStack {
        // Add the background gradient
        LinearGradient(
            gradient: Gradient(colors: [
                AppTheme.backgroundColor.opacity(0.90),
                AppTheme.backgroundColor.opacity(0.95)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        
        // Add the BPMView on top
        BPMView(
            metronome: MetronomeEngine(),
            isShowingKeypad: .constant(false),
            showTimeSignaturePicker: .constant(false)
        )
    }
}
