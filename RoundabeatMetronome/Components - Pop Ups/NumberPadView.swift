import SwiftUI

struct NumberPadView: View {
    @Binding var isShowingKeypad: Bool
    @State private var inputValue: String = ""
    @State private var isFirstInput: Bool = true
    let currentTempo: Double
    let onSubmit: (Double) -> Void
    
    init(isShowingKeypad: Binding<Bool>, currentTempo: Double, onSubmit: @escaping (Double) -> Void) {
        self._isShowingKeypad = isShowingKeypad
        self.currentTempo = currentTempo
        self.onSubmit = onSubmit
        self._inputValue = State(initialValue: "\(Int(currentTempo))")
    }
    
    var body: some View {
        ZStack {
            // Base shape with black fill matching BPMView
            RoundedRectangle(cornerRadius: 50)
                .fill(Color.black.opacity(0.9))
            
            // Outer stroke with gradient matching BPMView
            RoundedRectangle(cornerRadius: 50)
                .inset(by: 0.5)
                .stroke(LinearGradient(
                    gradient: Gradient(colors: [Color.white.opacity(0.2), Color.white.opacity(0.15)]),
                    startPoint: .top,
                    endPoint: .bottomTrailing)
                )
            
            VStack(spacing: 25) {
                headerView
                displayView
                numberPadButtons
                submitButton
            }
            .padding(30)
        }
        .frame(maxWidth: 320)
        .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
    }
    
    private var headerView: some View {
        HStack {
            Spacer()
            Text("ENTER BPM")
                .font(.system(size: 12))
                .kerning(1.5)
                .foregroundColor(Color.white.opacity(0.4))
            Spacer()
            Button(action: {
                if #available(iOS 10.0, *) {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
                isShowingKeypad = false
            }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(Color.white.opacity(0.6))
                    .font(.system(size: 20, weight: .medium))
            }
        }
    }
    
    private var displayView: some View {
        VStack(spacing: 8) {
            Text(inputValue.isEmpty ? "0" : inputValue)
                .font(.custom("Kanit-SemiBold", size: 60))
                .kerning(2)
                .foregroundColor(Color.white.opacity(0.8))
                .shadow(color: Color.white.opacity(0.1), radius: 0.5, x: 0, y: 0)
                .monospacedDigit()
                .frame(height: 70)
        }
    }
    
    private var numberPadButtons: some View {
        VStack(spacing: 15) {
            // Row 1
            HStack(spacing: 15) {
                numberButton(number: "1")
                numberButton(number: "2")
                numberButton(number: "3")
            }
            
            // Row 2
            HStack(spacing: 15) {
                numberButton(number: "4")
                numberButton(number: "5")
                numberButton(number: "6")
            }
            
            // Row 3
            HStack(spacing: 15) {
                numberButton(number: "7")
                numberButton(number: "8")
                numberButton(number: "9")
            }
            
            // Bottom row
            HStack(spacing: 15) {
                clearButton
                numberButton(number: "0")
                deleteButton
            }
        }
    }
    
    private var clearButton: some View {
        Button("CLR") {
            handleClearInput()
        }
        .font(.custom("Kanit-Medium", size: 16))
        .foregroundColor(Color.white.opacity(0.8))
        .frame(width: 70, height: 50)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    private var deleteButton: some View {
        Button(action: {
            handleDeleteInput()
        }) {
            Image(systemName: "delete.left")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(Color.white.opacity(0.8))
        }
        .frame(width: 70, height: 50)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    private var submitButton: some View {
        Button(action: {
            submitValue()
        }) {
            Text("SET TEMPO")
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
    
    private func numberButton(number: String) -> some View {
        Button(action: {
            handleNumberInput(number)
        }) {
            Text(number)
                .font(.custom("Kanit-Medium", size: 24))
                .foregroundColor(Color.white.opacity(0.8))
                .shadow(color: Color.white.opacity(0.1), radius: 0.5, x: 0, y: 0)
        }
        .frame(width: 70, height: 50)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    private func handleNumberInput(_ number: String) {
        if isFirstInput {
            inputValue = number
            isFirstInput = false
        } else if inputValue.count < 3 {
            inputValue += number
        }
        
        if #available(iOS 10.0, *) {
            UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: 0.5)
        }
    }
    
    private func handleClearInput() {
        inputValue = ""
        isFirstInput = true
        
        if #available(iOS 10.0, *) {
            UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: 0.5)
        }
    }
    
    private func handleDeleteInput() {
        if !inputValue.isEmpty {
            inputValue.removeLast()
            if inputValue.isEmpty {
                isFirstInput = true
            }
        }
        
        if #available(iOS 10.0, *) {
            UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: 0.5)
        }
    }
    
    private func submitValue() {
        guard let tempo = Double(inputValue), tempo >= 40, tempo <= 240 else {
            inputValue = "\(Int(currentTempo))"
            isFirstInput = true
            return
        }
        
        if #available(iOS 10.0, *) {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
        
        onSubmit(tempo)
        isShowingKeypad = false
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        NumberPadView(
            isShowingKeypad: .constant(true),
            currentTempo: 120.0,
            onSubmit: { _ in }
        )
    }
}
