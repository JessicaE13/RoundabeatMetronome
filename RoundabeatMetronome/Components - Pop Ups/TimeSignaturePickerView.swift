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
        ScrollView {
            VStack(alignment: .leading, spacing: 25) {
                // Header with title and close button
                HStack {
                    Spacer()
                    Text("Time Signature:   \(metronome.beatsPerMeasure)/\(metronome.beatUnit)")
                        .font(.title3)
                        .fontWeight(.light)
                        .multilineTextAlignment(.leading)
                        
                    Spacer()
                    Button(action: {
                        isShowingPicker = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                            .font(.title2)
                    }
                }
                Divider ()
                    .padding(-5.0)
     
                
                // Simple Time section - Center-aligned
                VStack(alignment: .center, spacing: 15) {
                    HStack (alignment: .center, spacing: 15) {
                        Spacer()
                        timeSignatureButton(numerator: 3, denominator: 4)
                        timeSignatureButton(numerator: 4, denominator: 4)
                        timeSignatureButton(numerator: 5, denominator: 4)
                        Spacer()
                    }
                    
                    HStack(alignment: .center, spacing: 15) {
                        Spacer()
                        timeSignatureButton(numerator: 6, denominator: 8)
                        timeSignatureButton(numerator: 7, denominator: 8)
                        timeSignatureButton(numerator: 12, denominator: 8)
                        Spacer()
                    }
                }
                .padding(.bottom, 10)
                
        

                
                Divider()
                    .padding(.vertical, 10)
                
                // Custom time signature - Always visible now
                HStack {
                    Spacer()
                    Text("Custom Time Signature")
                        .font(.headline)
                        .foregroundColor(.colorPurpleBackground)
                    Spacer()
                }
                
                HStack {
                    Spacer()
                    HStack(spacing: 20) {
                        // Numerator picker
                        VStack {
                            Text("Beats")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Picker("Numerator", selection: $customNumerator) {
                                ForEach(1...32, id: \.self) { num in
                                    Text("\(num)").tag(num)
                                }
                            }
                            .pickerStyle(WheelPickerStyle())
                            .frame(width: 80, height: 100)
                            .clipped()
                        }
                        
                        Text("/")
                            .font(.title)
                            .fontWeight(.light)
                        
                        // Denominator picker
                        VStack {
                            Text("Note Value")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Picker("Denominator", selection: $customDenominator) {
                                ForEach([1, 2, 4, 8, 16, 32], id: \.self) { denom in
                                    Text("\(denom)").tag(denom)
                                }
                            }
                            .pickerStyle(WheelPickerStyle())
                            .frame(width: 80, height: 100)
                            .clipped()
                        }
                    }
                    Spacer()
                }
                
                HStack {
                    Spacer()
                    Button(action: {
                        metronome.updateTimeSignature(numerator: customNumerator, denominator: customDenominator)
                        isShowingPicker = false
                    }) {
                        Text("Apply Custom")
                            .fontWeight(.light)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 20)
                            .background(Color.colorPurpleBackground)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding(.top, 10)
                    Spacer()
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 15)
        }
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
        .frame(maxHeight: UIScreen.main.bounds.height * 0.8)
    }
    
    // Helper function to create consistent time signature buttons
    private func timeSignatureButton(numerator: Int, denominator: Int) -> some View {
        Button(action: {
            metronome.updateTimeSignature(numerator: numerator, denominator: denominator)
            isShowingPicker = false
        }) {
            VStack(spacing: 3) {
                Text("\(numerator)/\(denominator)")
                    .font(.system(size: 16, weight: .light))
            }
            .frame(width: 75, height: 40)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        numerator == metronome.beatsPerMeasure &&
                        denominator == metronome.beatUnit ? Color.colorPurpleBackground : Color.gray.opacity(0.1)
                    )
            )
            .foregroundColor(
                numerator == metronome.beatsPerMeasure &&
                denominator == metronome.beatUnit ? .white : .primary
            )
        }
    }
}


// MARK: - Preview Provider
struct TimeSignaturePickerView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a sample MetronomeEngine for preview
        let sampleMetronome = MetronomeEngine()
        
        // Use constant binding for isShowingPicker in preview
        TimeSignaturePickerView(
            metronome: sampleMetronome,
            isShowingPicker: .constant(true)
        )
    }
}
