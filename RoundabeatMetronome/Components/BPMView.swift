//
//  BPMView.swift
//  RoundabeatMetronome
//
//  Created by Jessica Estes on 4/21/25.
//

import SwiftUI


// Custom shape for rounded corners
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// Extension to apply corner radius to specific corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

// MARK: - BPM Display Component with Gestures
struct BPMView: View {
    @ObservedObject var metronome: MetronomeEngine
    @Binding var isShowingKeypad: Bool
    @Binding var showTimeSignaturePicker: Bool
    @State private var dragOffset: CGFloat = 0
    @State private var previousTempo: Double = 120
    
    var body: some View {
        
        
        ZStack {
            
            RoundedRectangle(cornerRadius: 5)
           
                .foregroundStyle(Color.gray.opacity(0.25))
                .frame(width: .infinity, height: 150)
               
            
            HStack {
                VStack {
                    ZStack {
                        VStack{
                            RoundedRectangle(cornerRadius: 5)
                                .fill(.white.opacity(0.3))
                                .frame(width: 85, height: 125)
                        }
                        VStack (spacing: 20){
                            // Time Signature Button
                            VStack(spacing: 5) {
                                Text("TIME")
                                    .font(.system(size: 9, weight: .regular, design: .default))
                                    .foregroundColor(.gray.opacity(0.75))
                                    .lineLimit(nil)
                                
                                Button(action: {
                                    showTimeSignaturePicker = true
                                }) {
                                    Text("\(metronome.beatsPerMeasure) / \(metronome.beatUnit)")
                                        .font(.system(size: 14, weight: .bold, design: .default))
                                        .animation(.spring(), value: metronome.beatsPerMeasure)
                                        .foregroundColor(Color.black)
                                        .animation(.spring(), value: metronome.beatUnit)
                                        .frame(minWidth: 90)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            
                            
                            // Time Signature Button
                            VStack(spacing: 5) {
                                Text("RHYTHM")
                                    .font(.system(size: 9, weight: .regular, design: .default))
                                    .foregroundColor(.gray.opacity(0.75))
                                    .lineLimit(nil)
                                
                                Button(action: {
                                    showTimeSignaturePicker = true
                                }) {
                                    Text("\(metronome.beatsPerMeasure) / \(metronome.beatUnit)")
                                        .font(.system(size: 14, weight: .bold, design: .default))
                                        .animation(.spring(), value: metronome.beatsPerMeasure)
                                        .foregroundColor(Color.black)
                                        .animation(.spring(), value: metronome.beatUnit)
                                        .frame(minWidth: 90)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }
                
                
                ZStack {
                    
                    
                    RoundedRectangle(cornerRadius: 5)
                        .fill(.white.opacity(0.3))
                        .frame(width: 175, height: 125)
                    
                    // BPM Display with gestures
                    VStack {
                        
                        Text("BPM")
                            .font(.caption2)
                            .fontWeight(.regular)
                            .foregroundColor(.gray.opacity(0.75))
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
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)
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
                            .fill(.white.opacity(0.3))
                            .frame(width: 85, height: 125)
                        
                        // Tap Button
                        ZStack {
                            Image(systemName: "lock.fill")
                                .foregroundColor(Color.gray)
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
    BPMView(
        metronome: MetronomeEngine(),
        isShowingKeypad: .constant(false),
        showTimeSignaturePicker: .constant(false)
    )
}
