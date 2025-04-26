import SwiftUI

// MARK: - BPM Display Component with Gestures

struct BPMView: View {
    
    @ObservedObject var metronome: MetronomeEngine
    @Binding var isShowingKeypad: Bool
    @Binding var showTimeSignaturePicker: Bool
    @State private var dragOffset: CGFloat = 0
    @State private var previousTempo: Double = 120
    @State private var glowIntensity: Double = 0.6 // For animating glow effect
    
    // Animation for the glow effect
    let glowAnimation = Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)
    
    var body: some View {
        
        ZStack {
            HStack {
                VStack {
                    
  // MARK: - Time and Rhythm containers
                    
                    VStack(spacing: 9) {
                        
  // MARK: - First rectangle - TIME
                        ZStack {
                            // Enhanced glow effect with multiple layers
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(LinearGradient(
                                    gradient: Gradient(colors: [Color.white.opacity(0.9), Color.white.opacity(0.6)]),
                                    startPoint: .top,
                                    endPoint: .bottomTrailing)
                                )
                                .frame(width: 75, height: 58)
                                .shadow(color: Color.white.opacity(glowIntensity), radius: 6, x: 0, y: 0)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(Color.white.opacity(0.8), lineWidth: 1.0)
                                        .shadow(color: Color.white.opacity(0.6), radius: 4, x: 0, y: 0)
                                        .blur(radius: 0.9)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(Color.white.opacity(0.09))
                                )
                                .overlay(
                                    // Inner glow effect
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(Color.white.opacity(0.5), lineWidth: 1.5)
                                        .blur(radius: 2)
                                        .padding(1)
                                )
                                .overlay(
                                    // Highlight edge for top reflection
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(
                                            LinearGradient(
                                                gradient: Gradient(colors: [Color.white.opacity(1.0), Color.white.opacity(0)]),
                                                startPoint: .topLeading,
                                                endPoint: .center
                                            ),
                                            lineWidth: 1.5
                                        )
                                        .padding(0.5)
                                        .blendMode(.screen)
                                )
                                // Add a pulsing outer glow
                                .background(
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(Color.clear)
                                        .shadow(color: Color.white.opacity(glowIntensity * 0.3), radius: 8, x: 0, y: 0)
                                        .shadow(color: Color.white.opacity(glowIntensity * 0.2), radius: 12, x: 0, y: 0)
                                )
                            // Time Signature Button - centered
                            VStack(spacing: 5) {
                                Text("TIME")
                                    .font(.system(size: 8, weight: .regular, design: .default))
                                    .foregroundColor(Color("colorDial").opacity(0.6))
                                    .lineLimit(nil)
                                
                                Button(action: {
                                    showTimeSignaturePicker = true
                                }) {
                                    Text("\(metronome.beatsPerMeasure) / \(metronome.beatUnit)")
                                        .font(.system(size: 14, weight: .bold, design: .default))
                                        .animation(.easeOut(duration: 0.2), value: metronome.beatsPerMeasure)
                                        .foregroundColor(Color.black)
                                        .animation(.easeOut(duration: 0.2), value: metronome.beatUnit)
                                        .frame(minWidth: 75)
                                        .shadow(color: Color.white.opacity(0.3), radius: 1, x: 0, y: 0)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            .frame(width: 75, height: 58) // Match the container size
                        }
                        
    // MARK: - Second rectangle - RHYTHM
                        ZStack {
                            // Enhanced glow effect with multiple layers
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(LinearGradient(
                                    gradient: Gradient(colors: [Color.white.opacity(0.9), Color.white.opacity(0.6)]),
                                    startPoint: .top,
                                    endPoint: .bottomTrailing)
                                )
                                .frame(width: 75, height: 58)
                                .shadow(color: Color.white.opacity(glowIntensity), radius: 6, x: 0, y: 0)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(Color.white.opacity(0.8), lineWidth: 1.0)
                                        .shadow(color: Color.white.opacity(0.6), radius: 4, x: 0, y: 0)
                                        .blur(radius: 0.9)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(Color.white.opacity(0.09))
                                )
                                .overlay(
                                    // Inner glow effect
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(Color.white.opacity(0.5), lineWidth: 1.5)
                                        .blur(radius: 2)
                                        .padding(1)
                                )
                                .overlay(
                                    // Highlight edge for top reflection
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(
                                            LinearGradient(
                                                gradient: Gradient(colors: [Color.white.opacity(1.0), Color.white.opacity(0)]),
                                                startPoint: .topLeading,
                                                endPoint: .center
                                            ),
                                            lineWidth: 1.5
                                        )
                                        .padding(0.5)
                                        .blendMode(.screen)
                                )
                                // Add a pulsing outer glow
                                .background(
                                    RoundedRectangle(cornerRadius: 5)
                                        .fill(Color.clear)
                                        .shadow(color: Color.white.opacity(glowIntensity * 0.3), radius: 8, x: 0, y: 0)
                                        .shadow(color: Color.white.opacity(glowIntensity * 0.2), radius: 12, x: 0, y: 0)
                                )
                            
                            // Rhythm Button - centered
                            VStack(spacing: 5) {
                                Text("RHYTHM")
                                    .font(.system(size: 8, weight: .regular, design: .default))
                                    .foregroundColor(Color("colorDial").opacity(0.6))
                                    .lineLimit(nil)
                                
                                Button(action: {
                                    showTimeSignaturePicker = true
                                }) {
                                    Text("\(metronome.beatsPerMeasure) / \(metronome.beatUnit)")
                                        .font(.system(size: 14, weight: .bold, design: .default))
                                        .animation(.easeOut(duration: 0.2), value: metronome.beatsPerMeasure)
                                        .foregroundColor(Color("colorDial"))
                                        .animation(.easeOut(duration: 0.2), value: metronome.beatUnit)
                                        .frame(minWidth: 75)
                                        .shadow(color: Color.white.opacity(0.4), radius: 2, x: 0, y: 0)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            .frame(width: 75, height: 58) // Match the container size
                        }
                    }
                }

   // MARK: - Middle BPM Section: Rounded Rectangle
                
                ZStack {
                    // Enhanced glow effect with multiple layers
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(LinearGradient(
                            gradient: Gradient(colors: [Color.white.opacity(0.9), Color.white.opacity(0.6)]),
                            startPoint: .top,
                            endPoint: .bottomTrailing)
                        )
                        .frame(width: 175, height: 125)
                        .shadow(color: Color.white.opacity(glowIntensity), radius: 6, x: 0, y: 0)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.white.opacity(0.8), lineWidth: 1.0)
                                .shadow(color: Color.white.opacity(0.6), radius: 4, x: 0, y: 0)
                                .blur(radius: 0.9)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .fill(Color.white.opacity(0.09))
                        )
                        .overlay(
                            // Inner glow effect
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.white.opacity(0.5), lineWidth: 1.5)
                                .blur(radius: 2)
                                .padding(1)
                        )
                        .overlay(
                            // Highlight edge for top reflection
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.white.opacity(1.0), Color.white.opacity(0)]),
                                        startPoint: .topLeading,
                                        endPoint: .center
                                    ),
                                    lineWidth: 1.5
                                )
                                .padding(0.5)
                                .blendMode(.screen)
                        )
                        // Add a pulsing outer glow
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .fill(Color.clear)
                                .shadow(color: Color.white.opacity(glowIntensity * 0.4), radius: 8, x: 0, y: 0)
                                .shadow(color: Color.white.opacity(glowIntensity * 0.3), radius: 14, x: 0, y: 0)
                        )
                    
                    // BPM Display with gestures and +/- buttons
                    VStack {
                        Text("BPM")
                            .font(.system(size: 8, weight: .regular, design: .default))
                            .foregroundColor(Color("colorDial").opacity(0.6))
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
                                    .foregroundColor(Color("colorDial").opacity(0.9))
                                    .frame(width: 40, height: 60) // Larger frame for touch target
                                    .contentShape(Rectangle()) // Make entire area tappable
                                    .shadow(color: Color.white.opacity(0.3), radius: 2, x: 0, y: 0)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .frame(width: 25) // Keep visual width the same
                            
                            // BPM Display in a fixed-width container
                            Text("\(Int(metronome.tempo))")
                                .font(.system(size: 45, weight: .bold, design: .default))
                                .contentTransition(.identity) // Remove transition animation
                                .foregroundColor(Color("colorDial"))
                                .shadow(color: Color.white.opacity(0.5), radius: 3, x: 0, y: 0)
                                .multilineTextAlignment(.center)
                                .animation(.easeOut(duration: 0.2), value: Int(metronome.tempo)) // Reduced animation speed
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
                                    .foregroundColor(Color("colorDial").opacity(0.9))
                                    .frame(width: 40, height: 60) // Larger frame for touch target
                                    .contentShape(Rectangle()) // Make entire area tappable
                                    .shadow(color: Color.white.opacity(0.3), radius: 2, x: 0, y: 0)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .frame(width: 25) // Keep visual width the same
                        }
                        .frame(width: 150) // Fixed total width for the container
                        
                        Text("ALLEGRO")
                            .font(.system(size: 8, weight: .regular, design: .default))
                            .foregroundColor(Color("colorDial").opacity(0.6))
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
                        // Enhanced glow effect with multiple layers
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(LinearGradient(
                                gradient: Gradient(colors: [Color.white.opacity(0.9), Color.white.opacity(0.6)]),
                                startPoint: .top,
                                endPoint: .bottomTrailing)
                            )
                            .frame(width: 75, height: 125)
                            .shadow(color: Color.white.opacity(glowIntensity), radius: 6, x: 0, y: 0)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color.white.opacity(0.8), lineWidth: 1.0)
                                    .shadow(color: Color.white.opacity(0.6), radius: 4, x: 0, y: 0)
                                    .blur(radius: 0.9)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(Color.white.opacity(0.09))
                            )
                            .overlay(
                                // Inner glow effect
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.white.opacity(0.5), lineWidth: 1.5)
                                    .blur(radius: 2)
                                    .padding(1)
                            )
                            .overlay(
                                // Highlight edge for top reflection
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.white.opacity(1.0), Color.white.opacity(0)]),
                                            startPoint: .topLeading,
                                            endPoint: .center
                                        ),
                                        lineWidth: 1.5
                                    )
                                    .padding(0.5)
                                    .blendMode(.screen)
                            )
                            // Add a pulsing outer glow
                            .background(
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(Color.clear)
                                    .shadow(color: Color.white.opacity(glowIntensity * 0.3), radius: 8, x: 0, y: 0)
                                    .shadow(color: Color.white.opacity(glowIntensity * 0.2), radius: 12, x: 0, y: 0)
                            )
                        
                        // Tap Button
                        ZStack {
                            Image(systemName: "lock.fill")
                                .foregroundColor(Color("colorDial").opacity(0.4))
                                .padding(.bottom, 75.0)
                                .shadow(color: Color.white.opacity(0.3), radius: 2, x: 0, y: 0)
                            
                            Text("TAP")
                                .font(.headline)
                                .foregroundColor(Color("colorDial"))
                                .fontWeight(.bold)
                                .shadow(color: Color.white.opacity(0.4), radius: 2, x: 0, y: 0)
                                .lineLimit(nil)
                        }
                    }
                }
            }
        }
        .onAppear {
            // Start the glow animation when view appears
            withAnimation(glowAnimation) {
                glowIntensity = 0.8
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
