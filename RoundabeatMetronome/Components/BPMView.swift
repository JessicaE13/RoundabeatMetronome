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
            VStack(spacing: 12) {
                
        
                // MARK: - Middle BPM Section: Rounded Rectangle - Now expanded
                
                ZStack {
                    // Enhanced glow effect with multiple layers
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(LinearGradient(
                            gradient: Gradient(colors: [Color.white.opacity(0.9), Color.white.opacity(0.6)]),
                            startPoint: .top,
                            endPoint: .bottomTrailing)
                        )
                       
                        .shadow(color: Color.white.opacity(glowIntensity), radius: 6, x: 0, y: 0)
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.white.opacity(0.8), lineWidth: 1.0)
                                .shadow(color: Color.white.opacity(0.6), radius: 4, x: 0, y: 0)
                                .blur(radius: 0.9)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color.black.opacity(0.9))
                        )
                        .overlay(
                            // Inner glow effect
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.white.opacity(0.5), lineWidth: 1.5)
                                .blur(radius: 2)
                                .padding(1)
                        )
                        .overlay(
                            // Highlight edge for top reflection
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.white.opacity(1.0), Color.white.opacity(1.0)]),
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
                            .font(.system(size: 10, weight: .heavy, design: .default)) // Slightly larger
                            .foregroundColor(Color.white.opacity(0.6))
                            .lineLimit(nil)
                            .padding(.top, 5)
                        
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
                                    .font(.system(size: 18)) // Larger
                                    .foregroundColor(Color.white.opacity(0.9))
                                   
                                    .contentShape(Rectangle()) // Make entire area tappable
                                    .shadow(color: Color.white.opacity(0.3), radius: 0.5, x: 0, y: 0)
                            }
                            .buttonStyle(PlainButtonStyle())
                          
                            
                            // BPM Display in a fixed-width container
                            Text("\(Int(metronome.tempo))")
                                .font(.system(size: 65, weight: .bold, design: .default)) // Larger font
                                .contentTransition(.identity) // Remove transition animation
                                .foregroundColor(Color.white.opacity(0.9))
                                .shadow(color: Color.white.opacity(0.3), radius: 0.5, x: 0, y: 0)
                                .multilineTextAlignment(.center)
                                .animation(.easeOut(duration: 0.2), value: Int(metronome.tempo)) // Reduced animation speed
                               
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
                                    .font(.system(size: 18)) // Larger
                                    .foregroundColor(Color.white.opacity(0.9))
                                    .contentShape(Rectangle()) // Make entire area tappable
                                    .shadow(color: Color.white.opacity(0.3), radius: 0.5, x: 0, y: 0)
                            }
                            .buttonStyle(PlainButtonStyle())
                          
                        }
                       
                        
                        Text("ALLEGRO")
                            .font(.system(size: 10, weight: .heavy, design: .default)) // Slightly larger
                            .foregroundColor(Color.white.opacity(0.6))
                            .lineLimit(nil)
                            .padding(.bottom, 5)
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
            }
            .frame(height: UIScreen.main.bounds.height / 3.8)
            .padding(.horizontal, 30)
            .padding(.top, 50)
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

