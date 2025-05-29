import SwiftUI

// MARK: - BPM Display Component with Gestures

struct BPMViewOld: View {
    
    @ObservedObject var metronome: MetronomeEngine
    @Binding var isShowingKeypad: Bool
    @Binding var showTimeSignaturePicker: Bool
    @State private var dragOffset: CGFloat = 0
    @State private var previousTempo: Double = 120
    @State private var showSettings = false
    @State private var showDebugOutlines = false // Toggle this to show/hide red debug outlines
    
    let glowAnimation = Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)
    let tempoRanges: [TempoRange] = [
        TempoRange(name: "Larghissimo", minBPM: 20, maxBPM: 24),
        TempoRange(name: "Grave", minBPM: 25, maxBPM: 40),
        TempoRange(name: "Largo", minBPM: 41, maxBPM: 60),
        TempoRange(name: "Larghetto", minBPM: 61, maxBPM: 66),
        TempoRange(name: "Adagio", minBPM: 67, maxBPM: 72),
        TempoRange(name: "Adagietto", minBPM: 73, maxBPM: 76),
        TempoRange(name: "Andante", minBPM: 77, maxBPM: 80),
        TempoRange(name: "Andantino", minBPM: 81, maxBPM: 92),
        TempoRange(name: "Andante Moderato", minBPM: 93, maxBPM: 108),
        TempoRange(name: "Moderato", minBPM: 109, maxBPM: 112),
        TempoRange(name: "Allegretto", minBPM: 113, maxBPM: 120),
        TempoRange(name: "Allegro", minBPM: 121, maxBPM: 168),
        TempoRange(name: "Vivace", minBPM: 169, maxBPM: 172),
        TempoRange(name: "Vivacissimo", minBPM: 173, maxBPM: 176),
        TempoRange(name: "Presto", minBPM: 177, maxBPM: 200),
        TempoRange(name: "Prestissimo", minBPM: 201, maxBPM: 400)
    ]     // Tempo ranges in order of speed
    
    private func getCurrentTempoRange() -> TempoRange {
        let currentTempo = Int(metronome.tempo)
        return tempoRanges.first { range in
            currentTempo >= range.minBPM && currentTempo <= range.maxBPM
        } ?? tempoRanges.first { $0.name == "Allegro" }!
    }
    
    var body: some View {
        ZStack {
            VStack {
                
                // MARK: - Middle BPM Section: Rounded Rectangle - Now expanded and taller
                
                ZStack {
                    
                    RoundedRectangle(cornerRadius: 50)
                        .fill(Color.black.opacity(0.9))
                    
                    RoundedRectangle(cornerRadius: 50)
                        .offset(y: 0.5)
                        .stroke(LinearGradient(
                            gradient: Gradient(colors: [Color.clear, Color.white.opacity(0.7)]),
                            startPoint: .top,
                            endPoint: .bottom)
                        )
                    
                    // MARK: - 3 Distinct Horizontal Rows
                    VStack {
                        
                        // MARK: - Row 1: Time Signature and Settings
                        HStack {
                            // Time Signature
                            
                            Text("TIME:")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(Color.white.opacity(0.6))
                            
                            Button(action: {
                                let generator = UIImpactFeedbackGenerator(style: .light)
                                generator.impactOccurred()
                                showTimeSignaturePicker = true
                            }) {
                                HStack(spacing: 2) {
                                    Text("\(metronome.beatsPerMeasure)")
                                        .font(.custom("Kanit-SemiBold", size: 16))
                                        .foregroundColor(Color.white.opacity(0.8))
                                    
                                    Text("/")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(Color.white.opacity(0.8))
                                    
                                    Text("\(metronome.beatUnit)")
                                        .font(.custom("Kanit-SemiBold", size: 16))
                                        .foregroundColor(Color.white.opacity(0.8))
                                }
                            }
                            
                            Text("   RHYTHM:")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundColor(Color.white.opacity(0.6))
                            
                            Image(systemName: "music.note")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color.white.opacity(0.8))
                  
                            Spacer()
                            
                            // Settings Icon
                            Button(action: {
                                let generator = UIImpactFeedbackGenerator(style: .light)
                                generator.impactOccurred()
                                showSettings = true
                            }) {
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(Color.white.opacity(0.7))
                            }
                        }
                        .padding(.top, 15)
                        .padding(30)
                        .frame(height: 40) // Fixed height for row 1
                        .border(showDebugOutlines ? Color.red : Color.clear, width: 2) // DEBUG: Red outline for Row 1
                        
                        Spacer()
                        
                        // MARK: - Row 2: BPM Label, Number and +/- Buttons
                        
                        HStack(spacing: 25) {
                            ZStack {
                                Image(systemName: "minus")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(Color.white.opacity(0.9))
                                    .shadow(color: Color.white.opacity(0.3), radius: 0.5, x: 0, y: 0)
                            }
                            .frame(width: 30, height: 30) // Fixed size container
                            .contentShape(Rectangle()) // Make entire area tappable
                            .onTapGesture {   // Add subtle haptic feedback matching the swipe gesture
                                let generator = UIImpactFeedbackGenerator(style: .soft)
                                generator.impactOccurred(intensity: 0.5)
                                metronome.updateTempo(to: metronome.tempo - 1) // Decrease tempo by 1
                                previousTempo = metronome.tempo
                            }
                            
                            
                            VStack {
                                Text("\(Int(metronome.tempo))")
                                    .font(.custom("Kanit-SemiBold", size: 80))
                                    .kerning(2)
                                    .foregroundColor(Color.white.opacity(0.8))
                                    .shadow(color: Color.white.opacity(0.1), radius: 0.5, x: 0, y: 0)
                                    .monospacedDigit() // Fixedwidth
                            }
                            
                            .frame(width: 155, alignment: .center) // Fixed width container with center alignment
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
                
                        .frame(height: 100) // Fixed height for row 2
                        .border(showDebugOutlines ? Color.red : Color.clear, width: 2) // DEBUG: Red outline for Row 2
                        
                        Spacer()
                        
                        // MARK: - Row 3: Horizontal Tempo Selector
                        ZStack {
                            ScrollView(.horizontal, showsIndicators: false) {
                                ScrollViewReader { proxy in
                                    HStack(spacing: 16) {
                                   
                                        Spacer()
                                            .frame(width: 75)
                                        
                                        ForEach(tempoRanges.indices, id: \.self) { index in
                                            let range = tempoRanges[index]
                                            let isSelected = getCurrentTempoRange().name == range.name
                                            
                                            VStack(spacing: 4) {
                                                Text(range.name.uppercased())
                                                    .font(.system(size: 9, weight: .medium))
                                                    .kerning(1.0)
                                                    .foregroundColor(isSelected ?
                                                                     Color.white.opacity(0.9) :
                                                                        Color.white.opacity(0.4))
                                                    .multilineTextAlignment(.center)
                                                    .lineLimit(2)
                                                    .minimumScaleFactor(0.8)
                                                
                                                Text("\(range.minBPM)-\(range.maxBPM)")
                                                    .font(.custom("Kanit-Regular",size: 8))
                                                    .foregroundColor(isSelected ?
                                                                     Color.white.opacity(0.7) :
                                                                        Color.white.opacity(0.3))
                                            }
                                            .frame(minWidth: 65)
                                            .padding(.vertical, 10)
                                            .padding(.horizontal, 12)
                                            .background(
                                                RoundedRectangle(cornerRadius: 15)
                                                    .fill(isSelected ?
                                                          Color.white.opacity(0.1) :
                                                            Color.clear)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 15)
                                                            .stroke(isSelected ?
                                                                    Color.white.opacity(0.2) :
                                                                        Color.clear, lineWidth: 1)
                                                    )
                                            )
                                            .contentShape(Rectangle())
                                            .onTapGesture {
                                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                                generator.impactOccurred()
                                                metronome.updateTempo(to: Double(range.midBPM))
                                                previousTempo = metronome.tempo
                                            }
                                            .id(index)
                                        }
                                        
                                        Spacer()
                                            .frame(width: 75)
                                    }
                                    .padding(.horizontal, 50)
                                    .onAppear {
                                        // Scroll to current tempo range on appear
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                            if let currentIndex = tempoRanges.firstIndex(where: { $0.name == getCurrentTempoRange().name }) {
                                                withAnimation(.easeInOut(duration: 0.5)) {
                                                    proxy.scrollTo(currentIndex, anchor: .center)
                                                }
                                            }
                                        }
                                    }
                                    .onChange(of: metronome.tempo) { oldValue, newValue in
                                        // Auto-scroll to current tempo range when tempo changes with smoother animation
                                        if let currentIndex = tempoRanges.firstIndex(where: { $0.name == getCurrentTempoRange().name }) {
                                            withAnimation(.easeInOut(duration: 0.6)) {
                                                proxy.scrollTo(currentIndex, anchor: .center)
                                            }
                                        }
                                    }
                                }
                            }
                            .scrollBounceBehavior(.basedOnSize) // Smoother scroll behavior
                        }
                        .frame(height: 50) // Increased height for row 3 (was 70)
                        .border(showDebugOutlines ? Color.red : Color.clear, width: 2) // DEBUG: Red outline for Row 3
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 50)) // Clip the content first
                    
                    // Black inner outline - 3px wide (drawn on top of clipped content)
                    RoundedRectangle(cornerRadius: 50)
                        .stroke(Color.black, lineWidth: 3)
                        .padding(1.5) // Offset inward by half the stroke width to keep it inside
                        .allowsHitTesting(false) // Allow touches to pass through the outline
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
                            dragOffset = 0  // Reset drag offset
                            previousTempo = metronome.tempo   // Store the current tempo for next drag
                            let generator = UIImpactFeedbackGenerator(style: .soft)
                            generator.impactOccurred(intensity: 0.5)
                        }
                )
            }
            .frame(height: UIScreen.main.bounds.height / 3.5) // Made taller (was 3.8)
            .padding(.horizontal, 30)
            .padding(.top, 40)
        }

        .sheet(isPresented: $showSettings) {
            SettingsView(metronome: metronome)
        }
    }
}

#Preview {
    ZStack {
        BackgroundView()
        
        BPMViewOld(
            metronome: MetronomeEngine(),
            isShowingKeypad: .constant(false),
            showTimeSignaturePicker: .constant(false)
        )
    }
}
