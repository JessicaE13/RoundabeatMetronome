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
                .foregroundStyle(Color.white.opacity(0.1)) // Using the built-in blur material
                .frame(width: 385, height: 155)  // Using maxWidth instead of width
              // .background(.regularMaterial)
            //   .blur(radius: 10)
                .shadow(radius: 5)
            
            
            HStack {
                VStack {
                    ZStack {
                        VStack{
                       
                            RoundedRectangle(cornerRadius: 5)
                                .fill(LinearGradient(
                                    gradient: Gradient(colors: [Color.white.opacity(0.7), Color.white.opacity(0.6)]),
                                    startPoint: .top,
                                    endPoint: .bottomTrailing)
                                )
                                .frame(width: 85, height: 125)
                                .shadow(color: Color.white.opacity(0.4), radius: 6, x: 0, y: 0)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(Color.white.opacity(0.6), lineWidth: 0.5)
                                )
                                
                        
                            
                        }
                        VStack (spacing: 20){
                            
                            // Time Signature Button
                            VStack(spacing: 5) {
                                Text("TIME")
                                    .font(.system(size: 9, weight: .regular, design: .default))
                                    .foregroundColor(.black.opacity(0.4))
                                    .lineLimit(nil)
                                
                                Button(action: {
                                    showTimeSignaturePicker = true
                                }) {
                                    Text("\(metronome.beatsPerMeasure) / \(metronome.beatUnit)")
                                        .font(.system(size: 14, weight: .bold, design: .default))
                                        .animation(.spring(), value: metronome.beatsPerMeasure)
                                        .foregroundColor(Color.black)
                                        .animation(.spring(), value: metronome.beatUnit)
                                        .frame(minWidth: 85)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            
                            
                            // Time Signature Button
                            VStack(spacing: 5) {
                                Text("RHYTHM")
                                    .font(.system(size: 9, weight: .regular, design: .default))
                                    .foregroundColor(.black.opacity(0.4))
                                    .lineLimit(nil)
                                
                                Button(action: {
                                    showTimeSignaturePicker = true
                                }) {
                                    Text("\(metronome.beatsPerMeasure) / \(metronome.beatUnit)")
                                        .font(.system(size: 14, weight: .bold, design: .default))
                                        .animation(.spring(), value: metronome.beatsPerMeasure)
                                        .foregroundColor(Color.black)
                                        .animation(.spring(), value: metronome.beatUnit)
                                        .frame(minWidth: 85)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }
                
                
                ZStack {
                    
                    
                    RoundedRectangle(cornerRadius: 5)
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [Color.white.opacity(0.7), Color.white.opacity(0.6)]),
                            startPoint: .top,
                            endPoint: .bottomTrailing)
                        )
                        .frame(width: 175, height: 125)
                        .shadow(color: Color.white.opacity(0.4), radius: 6, x: 0, y: 0)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.white.opacity(0.6), lineWidth: 0.5)
                        )
                    // BPM Display with gestures
                    VStack {
                        
                        Text("BPM")
                            .font(.system(size: 9, weight: .regular, design: .default))
                            .foregroundColor(.black.opacity(0.4))
                            .lineLimit(nil)
                        
                        Text("\(Int(metronome.tempo))")
                            .font(.system(size: 50, weight: .bold, design: .default))
                            .contentTransition(.numericText())
                            .foregroundColor(Color.black)
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
                            .foregroundColor(.black.opacity(0.4))
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
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [Color.white.opacity(0.7), Color.white.opacity(0.6)]),
                                startPoint: .top,
                                endPoint: .bottomTrailing)
                            )
                            .frame(width: 85, height: 125)
                            .shadow(color: Color.white.opacity(0.4), radius: 6, x: 0, y: 0)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color.white.opacity(0.6), lineWidth: 0.5)
                            )
                        
                        
                        // Tap Button
                        ZStack {
                            Image(systemName: "lock.fill")
                                .foregroundColor(Color.black.opacity(0.4))
                                .padding(.bottom, 75.0)
                            
                            Text("TAP")
                                .font(.headline)
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
