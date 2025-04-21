//
//  BPMView.swift
//  RoundabeatMetronome
//
//  Created by Jessica Estes on 4/21/25.
//

import SwiftUI

// MARK: - BPM Display Component with Gestures
struct BPMView: View {
    @ObservedObject var metronome: MetronomeEngine
    @Binding var isShowingKeypad: Bool
    @Binding var showTimeSignaturePicker: Bool
    @State private var dragOffset: CGFloat = 0
    @State private var previousTempo: Double = 120
    
    var body: some View {
        
        HStack(spacing: 30) {
            // BPM Display with gestures
            VStack(spacing: 5) {
                Text("B P M")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(.gray)
                    .lineLimit(nil)
                
                Text("\(Int(metronome.tempo))")
                    .font(.system(size: 36, weight: .bold, design: .default))
                    .contentTransition(.numericText())
                    .fontWeight(.regular)
                    .foregroundColor(Color.white)
                    .animation(.spring(response: 0.3), value: Int(metronome.tempo))
                    .frame(minWidth: 90)
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
            }
            
            
            // Divider for visual separation
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 1, height: 70)
            
            // Time Signature Button
            VStack(spacing: 5) {
                Text("T I M E")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(.gray)
                    .lineLimit(nil)
                
                Button(action: {
                    showTimeSignaturePicker = true
                }) {
                    Text("\(metronome.beatsPerMeasure)/\(metronome.beatUnit)")
                        .font(.system(size: 36, weight: .bold, design: .default))
                        .animation(.spring(), value: metronome.beatsPerMeasure)
                        .fontWeight(.regular)
                        .foregroundColor(Color.white)
                        .animation(.spring(), value: metronome.beatUnit)
                        .frame(minWidth: 90)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(20) // Increased padding inside the rounded rectangle
        .frame(width: 280, height: 95)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color("colorDial"))
                .frame(width: 300, height: 175)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.black), lineWidth: 2)
                .frame(width: 300, height: 175)
        )

    }
}


#Preview {

    BPMView(
        metronome: MetronomeEngine(),
        isShowingKeypad: .constant(false),
        showTimeSignaturePicker: .constant(false)
    )
}
