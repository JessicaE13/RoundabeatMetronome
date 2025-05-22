//
//  NumberPadView.swift
//  RoundabeatMetronome
//
//  Created by Jessica Estes on 4/14/25.
//

import SwiftUI


// MARK: - Number Pad Component
struct NumberPadView: View {
    @Binding var isShowingKeypad: Bool
    @State private var inputValue: String = ""
    @State private var isFirstInput: Bool = true  // Track if this is the first input
    let currentTempo: Double
    let onSubmit: (Double) -> Void
    
    init(isShowingKeypad: Binding<Bool>, currentTempo: Double, onSubmit: @escaping (Double) -> Void) {
        self._isShowingKeypad = isShowingKeypad
        self.currentTempo = currentTempo
        self.onSubmit = onSubmit
        self._inputValue = State(initialValue: "\(Int(currentTempo))")
    }
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Spacer()
                Text("Enter BPM")
                    .font(.headline)
                    .fontWeight(.light)
                
                Spacer()
                Button(action: {
                    isShowingKeypad = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .font(.title2)
                }
            }
            .padding(.bottom, 10)
            
            TextField("", text: $inputValue)
                .font(.system(size: 40, weight: .light, design: .rounded))
                .multilineTextAlignment(.center)
                .keyboardType(.numberPad)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            
            // Custom number pad
            VStack(spacing: 15) {
                HStack(spacing: 20) {
                    numberButton(number: "1")
                    numberButton(number: "2")
                    numberButton(number: "3")
                }
                
                HStack(spacing: 20) {
                    numberButton(number: "4")
                    numberButton(number: "5")
                    numberButton(number: "6")
                }
                
                HStack(spacing: 20) {
                    numberButton(number: "7")
                    numberButton(number: "8")
                    numberButton(number: "9")
                }
                
                HStack(spacing: 20) {
                    // Clear button
                    Button(action: {
                        inputValue = ""
                        isFirstInput = true
                    }) {
                        Text("Clear")
                            .font(.system(size: 22, weight: .light))
                            .fontWeight(.light)
                            .foregroundColor(.white)
                            .frame(width: 80, height: 60)
                            .background(Color.gray)
                            .cornerRadius(10)
                    }
                    
                    numberButton(number: "0")
                    
                    // Delete button
                    Button(action: {
                        if !inputValue.isEmpty {
                            inputValue.removeLast()
                            if inputValue.isEmpty {
                                isFirstInput = true
                            }
                        }
                    }) {
                        Image(systemName: "delete.left")
                            .font(.system(size: 22, weight: .light))
                            .foregroundColor(.white)
                            .frame(width: 80, height: 60)
                            .background(Color.gray)
                            .cornerRadius(10)
                    }
                }
            }
            
            Button(action: {
                submitValue()
            }) {
                Text("Set Tempo")
                    .font(.system(size: 22, weight: .light))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.colorPurpleBackground)
                    .cornerRadius(10)
            }
            .padding(.top, 10)
        }
        .padding(20)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
        .frame(maxWidth: 300)
    }
    
    private func numberButton(number: String) -> some View {
        Button(action: {
            // Override existing text if this is the first input
            if isFirstInput {
                inputValue = number
                isFirstInput = false
            } else {
                // Otherwise append, but don't allow input to exceed 3 digits
                if inputValue.count < 3 {
                    inputValue += number
                }
            }
            
            // Add haptic feedback
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }) {
            Text(number)
                .font(.system(size: 28, weight: .light))
                .foregroundColor(.white)
                .frame(width: 80, height: 60)
                .background(Color.colorPurpleBackground)
                .cornerRadius(10)
        }
    }
    
    private func submitValue() {
        guard let tempo = Double(inputValue), tempo >= 40, tempo <= 240 else {
            // Invalid input, reset to current tempo
            inputValue = "\(Int(currentTempo))"
            isFirstInput = true
            return
        }
        
        // Add haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        onSubmit(tempo)
        isShowingKeypad = false
    }
}


#Preview {
    struct PreviewWrapper: View {
        @State private var isShowingKeypad = true
        
        var body: some View {
            NumberPadView(
                isShowingKeypad: $isShowingKeypad,
                currentTempo: 120.0,
                onSubmit: { newTempo in
                    print("New tempo: \(newTempo)")
                }
            )
        }
    }
    
    return PreviewWrapper()
}
