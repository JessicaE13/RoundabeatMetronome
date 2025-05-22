import SwiftUI

// MARK: - BPM Display Component with Gestures

struct BPMView: View {
    
    @ObservedObject var metronome: MetronomeEngine
    @Binding var isShowingKeypad: Bool
    @Binding var showTimeSignaturePicker: Bool
    @State private var dragOffset: CGFloat = 0
    @State private var previousTempo: Double = 120
    @State private var glowIntensity: Double = 0.06 // For animating glow effect
    
    // Animation for the glow effect
    let glowAnimation = Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)
    
    var body: some View {
        
        ZStack {
            VStack(spacing: 12) {
                
                
                // MARK: - Middle BPM Section: Rounded Rectangle - Now expanded
                 
                 ZStack {
                     // Base shape with black fill
                     RoundedRectangle(cornerRadius: 25)
                         .fill(Color.black.opacity(0.9))
                     
                   
                     // Outer stroke with proper sizing
                     RoundedRectangle(cornerRadius: 25)
                         .inset(by: 0.5) // Slight inset to keep stroke within bounds
                         .stroke(LinearGradient(
                             gradient: Gradient(colors: [Color.white.opacity(0.2), Color.white.opacity(0.15)]),
                             startPoint: .top,
                             endPoint: .bottomTrailing)
                         )
                         .shadow(color: Color.white.opacity(glowIntensity), radius: 6, x: 0, y: 0)
                     
                    
                    
                    // BPM Display with gestures and +/- buttons
                    VStack {
                        Text("BPM")
                            .font(.custom("SairaSemiCondensed-Regular",size: 10)) // Slightly larger
                            .kerning(1.5)
                            .foregroundColor(Color.white.opacity(0.4))
                            .lineLimit(nil)
                          
                        
                        // Inside the HStack where the BPM display is shown
                        HStack(spacing: 15) { // Increased spacing between elements
                            // Decrease (-) Button with fixed width container
                            ZStack {
                                Image(systemName: "minus")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(Color.white.opacity(0.9))
                                    .shadow(color: Color.white.opacity(0.3), radius: 0.5, x: 0, y: 0)
                            }
                            .frame(width: 30, height: 30) // Fixed size container
                            .contentShape(Rectangle()) // Make entire area tappable
                            .onTapGesture {
                                // Add subtle haptic feedback matching the swipe gesture
                                let generator = UIImpactFeedbackGenerator(style: .soft)
                                generator.impactOccurred(intensity: 0.5)
                                
                                // Decrease tempo by 1
                                metronome.updateTempo(to: metronome.tempo - 1)
                                previousTempo = metronome.tempo
                            }
                            
                            // BPM Display with fixed-width for 2-3 digits
                            ZStack {
                                // Create a fixed-width container that can accommodate up to 3 digits
                                HStack(spacing: 0) {
                               
                                    // Use format that shows only needed digits but maintains positioning
                                    Text("\(Int(metronome.tempo))")
                                        .font(.custom("MuseoModerno-VariableFont_wght", size: 75))
                                        .foregroundColor(Color.white.opacity(0.8))
                                        .shadow(color: Color.white.opacity(0.1), radius: 0.5, x: 0, y: 0)
                                        .monospacedDigit() // Ensures all digits have equal width
                                        .fixedSize() // Use only the space needed
                                    
                               
                                }
                                .frame(width: 150, alignment: .center) // Fixed width container with center alignment
                            }
                            .contentShape(Rectangle()) // Make entire area tappable
                            .onTapGesture {
                                // Add haptic feedback
                                let generator = UIImpactFeedbackGenerator(style: .light)
                                generator.impactOccurred()
                                isShowingKeypad = true
                            }
                            
                            ZStack {
                                Image(systemName: "plus")
                                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                                   
                                    .foregroundColor(Color.white.opacity(0.9))
                                    .shadow(color: Color.white.opacity(0.3), radius: 0.5, x: 0, y: 0)
                            }
                            .frame(width: 30, height: 30)
                            .contentShape(Rectangle()) // Make entire area tappable
                            .onTapGesture {
                                let generator = UIImpactFeedbackGenerator(style: .soft)
                                generator.impactOccurred(intensity: 0.5)
                                
                                // Increase tempo by 1
                                metronome.updateTempo(to: metronome.tempo + 1)
                                previousTempo = metronome.tempo
                            }
                        }
                        
                        Text("ALLEGRO")
                            .font(.custom("SairaSemiCondensed-Regular",size: 10)) //
                            .kerning(1.5)
                            .foregroundColor(Color.white.opacity(0.4))
                            .lineLimit(nil)
                    }
                }
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            dragOffset = value.translation.height
                            let tempoChange = -dragOffset * 0.2
                            let newTempo = previousTempo + tempoChange
                            let oldTempoInt = Int(metronome.tempo)
                            
                            metronome.updateTempo(to: newTempo)
                            
                            // If the integer value of the tempo changed, provide haptic feedback
                            if Int(metronome.tempo) != oldTempoInt {
                                let generator = UIImpactFeedbackGenerator(style: .soft)
                                generator.impactOccurred(intensity: 0.5)
                            }
                        }
                        .onEnded { _ in
                            // Reset drag offset
                            dragOffset = 0
                            // Store the current tempo for next drag
                            previousTempo = metronome.tempo
                            
                            let generator = UIImpactFeedbackGenerator(style: .soft)
                            generator.impactOccurred(intensity: 0.5)
                        }
                )
            }
            .frame(height: UIScreen.main.bounds.height / 3.8)
            .padding(.horizontal, 30)
            .padding(.top, 40)
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
BackgroundView()
        
        // Add the BPMView on top
        BPMView(
            metronome: MetronomeEngine(),
            isShowingKeypad: .constant(false),
            showTimeSignaturePicker: .constant(false)
        )
    }
}
