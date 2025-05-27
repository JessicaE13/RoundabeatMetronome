//
//  TimeSignaturePickerView.swift
//  RoundabeatMetronome
//
//  Created by Jessica Estes on 4/14/25.
//

import SwiftUI

// MARK: - Time Signature Picker View
struct TimeSignaturePickerView: View {
    @ObservedObject var metronome: MetronomeEngine
    @Binding var isShowingPicker: Bool
    
    // For custom time signature input
    @State private var customNumerator = 4
    @State private var customDenominator = 4
    
    var body: some View {
        ZStack {
            // Base shape with black fill matching NumberPadView
            RoundedRectangle(cornerRadius: 35)
                .fill(Color.black.opacity(0.8))
            
            // Outer stroke with gradient matching NumberPadView
            RoundedRectangle(cornerRadius: 35)
                .inset(by: 0.5)
                .stroke(LinearGradient(
                    gradient: Gradient(colors: [Color.white.opacity(0.2), Color.white.opacity(0.15)]),
                    startPoint: .top,
                    endPoint: .bottomTrailing)
                )
            
            ScrollView {
                VStack(spacing: 25) {
                    headerView
                    currentTimeSignatureDisplay
                    presetButtonsSection
                    customTimeSignatureSection
                }
                .padding(30)
            }
        }
        .frame(maxWidth: 380, maxHeight: UIScreen.main.bounds.height * 0.8)
        .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
    }
    
    private var headerView: some View {
        HStack {
            Spacer()
            Text("TIME SIGNATURE")
                .font(.system(size: 12))
                .kerning(1.5)
                .foregroundColor(Color.white.opacity(0.4))
            Spacer()
            Button(action: {
                if #available(iOS 10.0, *) {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
                isShowingPicker = false
            }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(Color.white.opacity(0.6))
                    .font(.system(size: 20, weight: .medium))
            }
        }
    }
    
    private var currentTimeSignatureDisplay: some View {
        VStack(spacing: 8) {
            Text("\(metronome.beatsPerMeasure)/\(metronome.beatUnit)")
                .font(.custom("Kanit-SemiBold", size: 48))
                .kerning(2)
                .foregroundColor(Color.white.opacity(0.8))
                .shadow(color: Color.white.opacity(0.1), radius: 0.5, x: 0, y: 0)
                .monospacedDigit()
                .frame(height: 60)
                .frame(minWidth: 200)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.black.opacity(0.4))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                        )
                )
        }
    }
    
    private var presetButtonsSection: some View {
        VStack(spacing: 20) {
            Text("PRESETS")
                .font(.system(size: 10))
                .kerning(1.2)
                .foregroundColor(Color.white.opacity(0.4))
            
            VStack(spacing: 15) {
                HStack(spacing: 15) {
                    timeSignatureButton(numerator: 3, denominator: 4)
                    timeSignatureButton(numerator: 4, denominator: 4)
                    timeSignatureButton(numerator: 5, denominator: 4)
                }
                
                HStack(spacing: 15) {
                    timeSignatureButton(numerator: 6, denominator: 8)
                    timeSignatureButton(numerator: 7, denominator: 8)
                    timeSignatureButton(numerator: 12, denominator: 8)
                }
            }
        }
    }
    
    private var customTimeSignatureSection: some View {
        VStack(spacing: 20) {
            // Divider line
            Rectangle()
                .fill(Color.white.opacity(0.15))
                .frame(height: 1)
                .padding(.horizontal, 20)
            
            Text("CUSTOM")
                .font(.system(size: 10))
                .kerning(1.2)
                .foregroundColor(Color.white.opacity(0.4))
            
            HStack(spacing: 30) {
                // Numerator picker
                VStack(spacing: 8) {
                    Text("BEATS")
                        .font(.system(size: 10))
                        .kerning(1)
                        .foregroundColor(Color.white.opacity(0.4))
                    
                    Picker("Numerator", selection: $customNumerator) {
                        ForEach(1...32, id: \.self) { num in
                            Text("\(num)")
                                .font(.custom("Kanit-Medium", size: 18))
                                .foregroundColor(Color.white.opacity(0.8))
                                .tag(num)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(width: 80, height: 120)
                    .clipped()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.black.opacity(0.4))
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
                            )
                    )
                }
                
                Text("/")
                    .font(.custom("Kanit-Light", size: 32))
                    .foregroundColor(Color.white.opacity(0.6))
                
                // Denominator picker
                VStack(spacing: 8) {
                    Text("NOTE VALUE")
                        .font(.system(size: 10))
                        .kerning(1)
                        .foregroundColor(Color.white.opacity(0.4))
                    
                    Picker("Denominator", selection: $customDenominator) {
                        ForEach([1, 2, 4, 8, 16, 32], id: \.self) { denom in
                            Text("\(denom)")
                                .font(.custom("Kanit-Medium", size: 18))
                                .foregroundColor(Color.white.opacity(0.8))
                                .tag(denom)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(width: 80, height: 120)
                    .clipped()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.black.opacity(0.4))
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
                            )
                    )
                }
            }
            
            Button(action: {
                if #available(iOS 10.0, *) {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }
                metronome.updateTimeSignature(numerator: customNumerator, denominator: customDenominator)
                isShowingPicker = false
            }) {
                Text("APPLY CUSTOM")
                    .font(.custom("Kanit-SemiBold", size: 16))
                    .kerning(1)
                    .foregroundColor(Color.white.opacity(0.9))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.white.opacity(0.15))
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(LinearGradient(
                                        gradient: Gradient(colors: [Color.white.opacity(0.3), Color.white.opacity(0.1)]),
                                        startPoint: .top,
                                        endPoint: .bottom), lineWidth: 1)
                            )
                    )
            }
        }
    }
    
    // Helper function to create consistent time signature buttons
    private func timeSignatureButton(numerator: Int, denominator: Int) -> some View {
        let isSelected = numerator == metronome.beatsPerMeasure && denominator == metronome.beatUnit
        
        return Button(action: {
            if #available(iOS 10.0, *) {
                UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: 0.5)
            }
            metronome.updateTimeSignature(numerator: numerator, denominator: denominator)
            isShowingPicker = false
        }) {
            Text("\(numerator)/\(denominator)")
                .font(.custom("Kanit-Medium", size: 18))
                .foregroundColor(isSelected ? Color.white.opacity(0.9) : Color.white.opacity(0.7))
                .shadow(color: Color.white.opacity(0.1), radius: 0.5, x: 0, y: 0)
        }
        .frame(width: 85, height: 50)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(isSelected ? Color.white.opacity(0.25) : Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(
                            isSelected ?
                            LinearGradient(
                                gradient: Gradient(colors: [Color.white.opacity(0.4), Color.white.opacity(0.2)]),
                                startPoint: .top,
                                endPoint: .bottom
                            ) :
                            LinearGradient(
                                gradient: Gradient(colors: [Color.white.opacity(0.2), Color.white.opacity(0.1)]),
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 1
                        )
                )
        )
    }
}

// MARK: - Preview Provider
struct TimeSignaturePickerView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            BackgroundView()
            
            // Create a sample MetronomeEngine for preview
            let sampleMetronome = MetronomeEngine()
            
            // Use constant binding for isShowingPicker in preview
            TimeSignaturePickerView(
                metronome: sampleMetronome,
                isShowingPicker: .constant(true)
            )
        }
    }
}
