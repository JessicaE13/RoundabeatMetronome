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
        GeometryReader { geometry in
      
            let maxWidth: CGFloat =  320
            let maxHeight: CGFloat =  500
            
            ZStack {
                // Base shape with black fill matching BPMView
                RoundedRectangle(cornerRadius:  35)
                    .fill(Color.black.opacity(0.95))
                
                // Outer stroke with gradient matching BPMView
                RoundedRectangle(cornerRadius: 35)
                    .inset(by: 0.5)
                    .stroke(LinearGradient(
                        gradient: Gradient(colors: [Color.white.opacity(0.2), Color.white.opacity(0.15)]),
                        startPoint: .top,
                        endPoint: .bottomTrailing)
                    )
                
                VStack(spacing: 25) {
                    headerView()
                    displayView()
                    numberPadButtons()
                    submitButton()
                }
                .padding(30)
            }
            .frame(maxWidth: maxWidth, maxHeight: maxHeight)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
        }
    }
    
    private func headerView() -> some View {
        HStack {
            Spacer()
            Text("ENTER BPM")
                .font(.system(size:12))
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
    
    private func displayView() -> some View {
        VStack(spacing: 8) {
            Text(inputValue.isEmpty ? "0" : inputValue)
                .font(.custom("Kanit-SemiBold", size: 60))
                .kerning(2)
                .foregroundColor(Color.white.opacity(0.8))
                .shadow(color: Color.white.opacity(0.1), radius: 0.5, x: 0, y: 0)
                .monospacedDigit()
                .frame(height: 80)
                .frame(minWidth: 240)
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
    
    private func numberPadButtons() -> some View {
        let buttonSpacing: CGFloat = 15
        let buttonSize: CGSize = CGSize(width: 70, height: 50)
        
        return VStack(spacing: buttonSpacing) {
            // Row 1
            HStack(spacing: buttonSpacing) {
                numberButton(number: "1", size: buttonSize)
                numberButton(number: "2", size: buttonSize)
                numberButton(number: "3", size: buttonSize)
            }
            
            // Row 2
            HStack(spacing: buttonSpacing) {
                numberButton(number: "4", size: buttonSize)
                numberButton(number: "5", size: buttonSize)
                numberButton(number: "6", size: buttonSize)
            }
            
            // Row 3
            HStack(spacing: buttonSpacing) {
                numberButton(number: "7", size: buttonSize)
                numberButton(number: "8", size: buttonSize)
                numberButton(number: "9", size: buttonSize)
            }
            
            // Bottom row
            HStack(spacing: buttonSpacing) {
                clearButton(size: buttonSize)
                numberButton(number: "0", size: buttonSize)
                deleteButton(size: buttonSize)
            }
        }
    }
    
    private func clearButton(size: CGSize) -> some View {
        Button("CLR") {
            handleClearInput()
        }
        .font(.custom("Kanit-Medium", size: 16))
        .foregroundColor(Color.white.opacity(0.8))
        .frame(width: size.width, height: size.height)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    private func deleteButton(size: CGSize) -> some View {
        Button(action: {
            handleDeleteInput()
        }) {
            Image(systemName: "delete.left")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(Color.white.opacity(0.8))
        }
        .frame(width: size.width, height: size.height)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    private func submitButton() -> some View {
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
    
    private func numberButton(number: String, size: CGSize) -> some View {
        Button(action: {
            handleNumberInput(number)
        }) {
            Text(number)
                .font(.custom("Kanit-Medium", size: 24))
                .foregroundColor(Color.white.opacity(0.8))
                .shadow(color: Color.white.opacity(0.1), radius: 0.5, x: 0, y: 0)
        }
        .frame(width: size.width, height: size.height)
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
       BackgroundView()
        
        NumberPadView(
            isShowingKeypad: .constant(true),
            currentTempo: 120.0,
            onSubmit: { _ in }
        )
    }
}
