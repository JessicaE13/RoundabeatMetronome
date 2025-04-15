//
//  BPMDisplayView.swift
//  RoundabeatMetronome
//
//  Created by Jessica Estes on 4/14/25.
//

import SwiftUI

// MARK: - BPM Display Component with Gestures
struct BPMDisplayView: View {
    @ObservedObject var metronome: MetronomeEngine
    @Binding var isShowingKeypad: Bool
    @State private var dragOffset: CGFloat = 0
    @State private var previousTempo: Double = 120
    
    var body: some View {
        VStack(spacing: 5) {
            Text("\(Int(metronome.tempo))")
                .font(.system(size: 72, weight: .bold, design: .default))
                .contentTransition(.numericText())
                .animation(.spring(response: 0.3), value: Int(metronome.tempo))
                // Make the BPM text tappable to show keypad
                .onTapGesture {
                    // Add haptic feedback
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                    
                    isShowingKeypad = true
                }
                // Add vertical swipe gesture
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            dragOffset = value.translation.height
                            
                            // Calculate tempo change based on drag distance
                            // Negative offset (swipe up) increases tempo
                            let tempoChange = -dragOffset * 0.2
                            let newTempo = previousTempo + tempoChange
                            
                            // Update tempo with clamping
                            metronome.updateTempo(to: newTempo)
                        }
                        .onEnded { _ in
                            // Reset drag offset
                            dragOffset = 0
                            // Store the current tempo for next drag
                            previousTempo = metronome.tempo
                            
                            // Add haptic feedback
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()
                        }
                )
            
            Text("BPM")
                .font(.headline)
                .foregroundColor(.gray)
        }
    }
}


// MARK: - Preview Provider
struct BPMDisplayView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a sample MetronomeEngine for preview
        let sampleMetronome = MetronomeEngine()
        
        // Use constant binding for isShowingPicker in preview
        BPMDisplayView(
            metronome: sampleMetronome,
            isShowingKeypad: .constant(true)
        )
    }
}
