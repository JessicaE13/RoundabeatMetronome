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
    @State private var isShowingCustom = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 25) {
                // Header with title and close button
                HStack {
                    Spacer()
                    Text("Time Signature:   \(metronome.beatsPerMeasure)/\(metronome.beatUnit)")
                        .font(.title3)
                        .fontWeight(.bold)
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
     
                
                // Simple Time section
                
                VStack(alignment: .leading, spacing: 15) {
                    
                    // Section header
                    HStack {
                        Text("Simple Time")
                            .font(.headline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(8)
                        
                        Text("Each beat divides into 2 equal parts")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    HStack(spacing: 15) {
                        // Duple row
                        Text("Duple")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 5)
                        timeSignatureButton(numerator: 2, denominator: 2)
                        timeSignatureButton(numerator: 2, denominator: 4)
                        Spacer()
                    }
                    
                    HStack(spacing: 15) {
                        // Triple row
                        Text("Triple")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 5)
                        
                        timeSignatureButton(numerator: 3, denominator: 2)
                        timeSignatureButton(numerator: 3, denominator: 4)
                        timeSignatureButton(numerator: 3, denominator: 8)
                        Spacer()
                    }
                                      
                    HStack(spacing: 15) {
                        // Quadruple row
                        Text("Quadruple")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 5)
                        timeSignatureButton(numerator: 4, denominator: 2)
                        timeSignatureButton(numerator: 4, denominator: 4)
                        timeSignatureButton(numerator: 4, denominator: 8)
                        Spacer()
                    }
                }
                .padding(.bottom, 10)
                
                // Compound Time section
                VStack(alignment: .leading, spacing: 15) {
                    // Section header
                    
                    HStack {
                        Text("Compound Time")
                            .font(.headline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.green.opacity(0.2))
                            .cornerRadius(8)
                        
                        Text("Each beat divides into 3 equal parts")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    

                    
                    HStack(spacing: 15) {
                        // Duple row
                        Text("Duple")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 5)
                        timeSignatureButton(numerator: 6, denominator: 4)
                        timeSignatureButton(numerator: 6, denominator: 8)
                        timeSignatureButton(numerator: 6, denominator: 16)
                        Spacer()
                    }

                    
                    HStack(spacing: 15) {
                        
                        // Triple row
                        Text("Triple")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 5)
                        timeSignatureButton(numerator: 9, denominator: 4)
                        timeSignatureButton(numerator: 9, denominator: 8)
                        timeSignatureButton(numerator: 9, denominator: 16)
                        Spacer()
                    }
                    

                    
                    HStack(spacing: 15) {
                        // Quadruple row
                        Text("Quadruple")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 5)
                        timeSignatureButton(numerator: 12, denominator: 4)
                        timeSignatureButton(numerator: 12, denominator: 8)
                        timeSignatureButton(numerator: 12, denominator: 16)
                        Spacer()
                    }
                }
                .padding(.bottom, 10)
                
                // Irregular Time section
                VStack(alignment: .leading, spacing: 15) {
                    
                    HStack {
                        // Section header
                        Text("Irregular Time")
                            .font(.headline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.orange.opacity(0.2))
                            .cornerRadius(8)
                        
                        Text("Uneven groupings of beats")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
   
                    
                    HStack(spacing: 15) {
                        // Quintuple row
                        Text("Quintuple")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 5)
            
                        timeSignatureButton(numerator: 5, denominator: 4)
                        timeSignatureButton(numerator: 5, denominator: 8)
                        Spacer()
                    }
                    

                    
                    HStack(spacing: 15) {
                        // Septuple row
                        Text("Septuple")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 5)
                        timeSignatureButton(numerator: 7, denominator: 4)
                        timeSignatureButton(numerator: 7, denominator: 8)
                        Spacer()
                    }
                }
                
                Divider()
                    .padding(.vertical, 10)
                
                // Custom time signature
                HStack {
                    Spacer()
                    Button(action: {
                        isShowingCustom.toggle()
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Custom Time Signature")
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 15)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    }
                    Spacer()
                }
                
                if isShowingCustom {
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
                                .fontWeight(.bold)
                            
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
                                .fontWeight(.medium)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 20)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .padding(.top, 10)
                        Spacer()
                    }
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
                    .font(.system(size: 16, weight: .semibold))
            }
            .frame(width: 75, height: 40)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        numerator == metronome.beatsPerMeasure &&
                        denominator == metronome.beatUnit ? Color.blue : Color.gray.opacity(0.1)
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
