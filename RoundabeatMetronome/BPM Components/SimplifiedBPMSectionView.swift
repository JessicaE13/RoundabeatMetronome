//
//  SimplifiedBPMSectionView.swift
//  RoundabeatMetronome
//
//  Created by Jessica Estes on 5/28/25.
//

import SwiftUI

struct SimplifiedBPMSectionView: View {
    @ObservedObject var metronome: MetronomeEngine
    @Binding var isShowingKeypad: Bool
    @Binding var previousTempo: Double
    @State private var containerScale: CGFloat = 1.0
    @State private var pulseAnimation: Bool = false
    @State private var dragOffset: CGFloat = 0
    

    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Row 1: Tempo Selector (Musical Terms) - Separate section
            VStack(spacing: 0) {
                TempoSelectorView(
                    metronome: metronome,
                    previousTempo: $previousTempo
                )
            }
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(red: 15/255, green: 15/255, blue: 16/255))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.08),
                                        Color.white.opacity(0.04)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                lineWidth: 1
                            )
                    )
            )
            
            // MARK: - Row 2: Main BPM Display with Controls - Separate flat section
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    // Minus Button
                    ZStack {
                        Image(systemName: "chevron.backward")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color.white.opacity(0.9))
                            .shadow(color: Color.white.opacity(0.3), radius: 0.5, x: 0, y: 0)
                    }
                    .frame(width: 30, height: 30)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        let generator = UIImpactFeedbackGenerator(style: .soft)
                        generator.impactOccurred(intensity: 0.5)
                        metronome.updateTempo(to: metronome.tempo - 1)
                        previousTempo = metronome.tempo
                    }
                    
                    // BPM Number Display
                    VStack {
                        Text("\(Int(metronome.tempo))")
                            .font(.custom("Kanit-SemiBold", size: 90))
                            .kerning(2)
                            .padding(.bottom, -20)
                            .padding(.top, -30)
                            .foregroundColor(Color.white.opacity(0.8))
                            .shadow(color: Color.white.opacity(0.1), radius: 0.5, x: 0, y: 0)
                            .monospacedDigit()
                        
                        Text("BEATS PER MINUTE (BPM)")
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .foregroundColor(Color.white.opacity(0.6))
                            .padding(.bottom, 4)
                            .tracking(1)
                    }
                    .frame(width: 200, alignment: .center)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                        isShowingKeypad = true
                    }
                    
                    // Plus Button
                    ZStack {
                        Image(systemName: "chevron.forward")
                            .font(.system(size: 18, weight: .bold, design: .monospaced))
                            .foregroundColor(Color.white.opacity(0.9))
                            .shadow(color: Color.white.opacity(0.3), radius: 0.5, x: 0, y: 0)
                    }
                    .frame(width: 30, height: 30)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        let generator = UIImpactFeedbackGenerator(style: .soft)
                        generator.impactOccurred(intensity: 0.5)
                        metronome.updateTempo(to: metronome.tempo + 1)
                        previousTempo = metronome.tempo
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 16)
                .scaleEffect(pulseAnimation ? 1.02 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: pulseAnimation)
            }
//            .background(
//                // Flatter, more recessed appearance for BPM section
//                RoundedRectangle(cornerRadius: 24)
//                    .fill(Color(red: 8/255, green: 8/255, blue: 9/255))
//                    .overlay(
//                        // Inner shadow effect for recessed look
//                        RoundedRectangle(cornerRadius: 24)
//                            .stroke(
//                                LinearGradient(
//                                    colors: [
//                                        Color.black.opacity(0.6),
//                                        Color.white.opacity(0.03)
//                                    ],
//                                    startPoint: .topLeading,
//                                    endPoint: .bottomTrailing
//                                ),
//                                lineWidth: 1
//                            )
//                    )
//                    .overlay(
//                        // Subtle inner highlight
//                        RoundedRectangle(cornerRadius: 24)
//                            .inset(by: 1)
//                            .stroke(
//                                LinearGradient(
//                                    colors: [
//                                        Color.white.opacity(0.02),
//                                        Color.clear
//                                    ],
//                                    startPoint: .top,
//                                    endPoint: .bottom
//                                ),
//                                lineWidth: 0.5
//                            )
//                    )
//            )
            .scaleEffect(containerScale)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        dragOffset = value.translation.height
                        let tempoChange = -dragOffset * 0.2
                        let newTempo = previousTempo + tempoChange
                        let oldTempoInt = Int(metronome.tempo)
                        
                        // Enhanced visual feedback during drag
                        withAnimation(.easeOut(duration: 0.1)) {
                            containerScale = 1.02
                        }
                        
                        metronome.updateTempo(to: newTempo)
                        
                        // If the integer value of the tempo changed, provide haptic feedback and visual pulse
                        if Int(metronome.tempo) != oldTempoInt {
                            let generator = UIImpactFeedbackGenerator(style: .soft)
                            generator.impactOccurred(intensity: 0.5)
                            
                            // Trigger pulse animation
                            withAnimation(.easeInOut(duration: 0.1)) {
                                pulseAnimation = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation(.easeInOut(duration: 0.1)) {
                                    pulseAnimation = false
                                }
                            }
                        }
                    }
                    .onEnded { _ in
                        dragOffset = 0
                        previousTempo = metronome.tempo
                        
                        // Reset scale with smooth animation
                        withAnimation(.easeOut(duration: 0.2)) {
                            containerScale = 1.0
                        }
                        
                        let generator = UIImpactFeedbackGenerator(style: .soft)
                        generator.impactOccurred(intensity: 0.5)
                    }
            )
        }
        .onReceive(NotificationCenter.default.publisher(for: .init("MetronomeBeat"))) { _ in
            // Subtle beat indication with enhanced animation
            withAnimation(.easeInOut(duration: 0.05)) {
                pulseAnimation = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                withAnimation(.easeInOut(duration: 0.05)) {
                    pulseAnimation = false
                }
            }
        }
    }

}

#Preview {
    ZStack {
        BackgroundView()
        SimplifiedBPMSectionView(
            metronome: MetronomeEngine(),
            isShowingKeypad: .constant(false),
            previousTempo: .constant(120)
        )
        .padding()
    }
}
