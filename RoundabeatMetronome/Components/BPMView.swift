
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
        
        ZStack {
            RoundedRectangle(cornerRadius: 7)
                .fill(.shadow(.inner(color: .black, radius: 3, y: 2)))
                .foregroundStyle(Color.black.opacity(0.25))
                .frame(width: 370, height: 155)
                
            
            HStack {
                VStack {
                    // Time and Rhythm containers
                    VStack(spacing: 9) {
                        // First rectangle - TIME
                        ZStack {
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(LinearGradient(
                                    gradient: Gradient(colors: [Color.white.opacity(0.8), Color.white.opacity(0.7)]),
                                    startPoint: .top,
                                    endPoint: .bottomTrailing)
                                )
                                .frame(width: 75, height: 58)
                                .shadow(color: Color.white.opacity(0.7), radius: 4, x: 0, y: 0)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(Color.white.opacity(0.8), lineWidth: 0.8)
                                        .shadow(color: Color.white.opacity(0.6), radius: 2, x: 0, y: 0)
                                )
                            
                            // Time Signature Button - centered
                            VStack(spacing: 5) {
                                Text("TIME")
                                    .font(.system(size: 9, weight: .regular, design: .default))
                                    .foregroundColor(.black.opacity(0.9))
                                    .lineLimit(nil)
                                
                                Button(action: {
                                    showTimeSignaturePicker = true
                                }) {
                                    Text("\(metronome.beatsPerMeasure) / \(metronome.beatUnit)")
                                        .font(.system(size: 14, weight: .bold, design: .default))
                                        .animation(.spring(), value: metronome.beatsPerMeasure)
                                        .foregroundColor(Color.white)
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
                                    gradient: Gradient(colors: [Color.white.opacity(0.8), Color.white.opacity(0.7)]),
                                    startPoint: .top,
                                    endPoint: .bottomTrailing)
                                )
                                .frame(width: 75, height: 58)
                                .shadow(color: Color.white.opacity(0.7), radius: 4, x: 0, y: 0)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(Color.white.opacity(0.8), lineWidth: 0.8)
                                        .shadow(color: Color.white.opacity(0.6), radius: 2, x: 0, y: 0)
                                )
                            
                            // Rhythm Button - centered
                            VStack(spacing: 5) {
                                Text("RHYTHM")
                                    .font(.system(size: 9, weight: .regular, design: .default))
                                    .foregroundColor(.black.opacity(0.9))
                                    .lineLimit(nil)
                                
                                Button(action: {
                                    showTimeSignaturePicker = true
                                }) {
                                    Text("\(metronome.beatsPerMeasure) / \(metronome.beatUnit)")
                                        .font(.system(size: 14, weight: .bold, design: .default))
                                        .animation(.spring(), value: metronome.beatsPerMeasure)
                                        .foregroundColor(Color.white)
                                        .animation(.spring(), value: metronome.beatUnit)
                                        .frame(minWidth: 75)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            .frame(width: 75, height: 58) // Match the container size
                        }
                    }
                }
                
                
                ZStack {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(LinearGradient(
                            gradient: Gradient(colors: [Color.white.opacity(0.8), Color.white.opacity(0.7)]),
                            startPoint: .top,
                            endPoint: .bottomTrailing)
                        )
                        .frame(width: 175, height: 125)
                        .shadow(color: Color.white.opacity(0.7), radius: 4, x: 0, y: 0)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.white.opacity(0.8), lineWidth: 0.8)
                                .shadow(color: Color.white.opacity(0.6), radius: 2, x: 0, y: 0)
                        )
                    
                    // BPM Display with gestures
                    VStack {
                        
                        Text("BPM")
                            .font(.system(size: 9, weight: .regular, design: .default))
                            .foregroundColor(.black.opacity(0.9))
                            .lineLimit(nil)
                        
                        Text("\(Int(metronome.tempo))")
                            .font(.system(size: 50, weight: .bold, design: .default))
                            .contentTransition(.numericText())
                            .foregroundColor(Color.white)
                            .animation(.spring(response: 0.3), value: Int(metronome.tempo))
                            .frame(minWidth: 50)
                        // Make the BPM text tappable to show keypad
                            .onTapGesture {
                                // Add haptic feedback
                                let generator = UIImpactFeedbackGenerator(style: .light)
                                generator.impactOccurred()
                                isShowingKeypad = true
                            }
                        
                        Text("Allegro")
                            .font(.system(size: 9, weight: .regular, design: .default))
                            .foregroundColor(.black.opacity(0.9))
                            .lineLimit(nil)
                        
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
                }
                
                VStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(LinearGradient(
                                gradient: Gradient(colors: [Color.white.opacity(0.99), Color.white.opacity(0.8)]),
                                startPoint: .top,
                                endPoint: .bottomTrailing)
                            )
                            .frame(width: 75, height: 125)
                            .shadow(color: Color.white.opacity(0.7), radius: 4, x: 0, y: 0)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color.white.opacity(1.0), lineWidth: 0.8)
                                    .shadow(color: Color.white.opacity(0.6), radius: 2, x: 0, y: 0)
                            )
                        
                        // Tap Button
                        ZStack {
                            Image(systemName: "lock.fill")
                                .foregroundColor(Color.black.opacity(0.4))
                                .padding(.bottom, 75.0)
                            
                            Text("TAP")
                                .font(.headline)
                                .foregroundColor(Color.white)
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
