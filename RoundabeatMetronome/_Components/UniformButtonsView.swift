import SwiftUI

// MARK: - Uniform Button Component
struct UniformButton: View {
    let label: String // e.g., "TIME" or "SUB DIV."
    let value: String // e.g., "4/4" or "♩"
    let action: () -> Void
    
    // Get screen dimensions directly
    private var screenWidth: CGFloat {
        UIScreen.main.bounds.width
    }
    
    // Check if device is iPad
    private var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 2) {
                Text(label)
                    .font(.system(size: buttonFontSize, weight: .medium))
                    .foregroundColor(.primary.opacity(0.4)) // Gray label
                Text(value)
                    .font(.system(size: buttonFontSize, weight: .medium))
                    .foregroundColor(.white) // White value
            }
            .kerning(1.2)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .multilineTextAlignment(.center)
        }
        .frame(
            width: uniformButtonWidth,
            height: uniformButtonHeight
        )
        .background(Color(.systemBackground).opacity(0.98))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.primary.opacity(0.2), lineWidth: 1)
        )
    }
    
    // MARK: - Responsive Properties
    
    private var buttonFontSize: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 16 :
            screenWidth <= 834 ? 18 :
            screenWidth <= 1024 ? 20 :
            22
        } else {
            return screenWidth <= 320 ? 10 :
            screenWidth <= 375 ? 11 :
            screenWidth <= 393 ? 12 :
            14
        }
    }
    
    private var uniformButtonWidth: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 130 :
            screenWidth <= 834 ? 140 :
            screenWidth <= 1024 ? 150 :
            160
        } else {
            return screenWidth <= 320 ? 90 :
            screenWidth <= 375 ? 95 :
            screenWidth <= 393 ? 100 :
            105
        }
    }
    
    private var uniformButtonHeight: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 50 :
            screenWidth <= 834 ? 54 :
            screenWidth <= 1024 ? 58 :
            62
        } else {
            return screenWidth <= 320 ? 36 :
            screenWidth <= 375 ? 38 :
            screenWidth <= 393 ? 42 :
            46
        }
    }
}

// MARK: - Uniform Button with Icon Component
struct UniformButtonWithIcon: View {
    let text: String
    let iconName: String
    let action: () -> Void
    
    // Get screen dimensions directly
    private var screenWidth: CGFloat {
        UIScreen.main.bounds.width
    }
    
    // Check if device is iPad
    private var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 3) {
                Text(text)
                    .font(.system(size: buttonFontSize, weight: .medium))
                    .foregroundColor(.primary.opacity(0.4)) // Gray text
                Image(systemName: iconName)
                    .font(.system(size: buttonFontSize - 1))
                    .foregroundColor(.white) // White icon
            }
            .kerning(1.2)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(
            width: uniformButtonWidth,
            height: uniformButtonHeight
        )
        .background(Color(.systemBackground).opacity(0.98))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.primary.opacity(0.2), lineWidth: 1)
        )
    }
    
    // MARK: - Responsive Properties
    
    private var buttonFontSize: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 16 :
            screenWidth <= 834 ? 18 :
            screenWidth <= 1024 ? 20 :
            22
        } else {
            return screenWidth <= 320 ? 10 :
            screenWidth <= 375 ? 11 :
            screenWidth <= 393 ? 12 :
            14
        }
    }
    
    private var uniformButtonWidth: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 130 :
            screenWidth <= 834 ? 140 :
            screenWidth <= 1024 ? 150 :
            160
        } else {
            return screenWidth <= 320 ? 90 :
            screenWidth <= 375 ? 95 :
            screenWidth <= 393 ? 100 :
            105
        }
    }
    
    private var uniformButtonHeight: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 50 :
            screenWidth <= 834 ? 54 :
            screenWidth <= 1024 ? 58 :
            62
        } else {
            return screenWidth <= 320 ? 36 :
            screenWidth <= 375 ? 38 :
            screenWidth <= 393 ? 42 :
            46
        }
    }
}

// MARK: - Uniform Buttons View
struct UniformButtonsView: View {
    @ObservedObject var metronome: MetronomeEngine
    
    // Bindings for showing pickers
    @Binding var showingTimeSignaturePicker: Bool
    @Binding var showingSubdivisionPicker: Bool
    
    // Get screen dimensions directly
    private var screenWidth: CGFloat {
        UIScreen.main.bounds.width
    }
    
    // Check if device is iPad
    private var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    // Helper function to get current subdivision symbol
    private func getCurrentSubdivisionSymbol() -> String {
        // Find the subdivision option that matches the current multiplier
        let currentOption = SubdivisionPickerView.subdivisionOptions.first { option in
            option.multiplier == metronome.subdivisionMultiplier
        }
        return currentOption?.symbol ?? "♩"
    }
    
    var body: some View {
        HStack(spacing: buttonSpacing) {
            // Time signature button
            UniformButton(
                label: "TIME  ",
                value: "\(metronome.beatsPerMeasure)/\(metronome.beatUnit)",
                action: {
                    showingTimeSignaturePicker = true
                }
            )
            
            // Subdivision button
            UniformButton(
                label: "SUB DIV.",
                value: getCurrentSubdivisionSymbol(),
                action: {
                    showingSubdivisionPicker = true
                }
            )
            
            // Tap tempo button
            UniformButtonWithIcon(
                text: "TAP  ",
                iconName: "hand.tap",
                action: {
                    metronome.tapTempo()
                }
            )
        }
        .frame(maxWidth: .infinity)
        .frame(height: uniformButtonHeight)
    }
    
    // MARK: - Responsive Properties
    
    private var buttonSpacing: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 16 :
            screenWidth <= 834 ? 20 :
            screenWidth <= 1024 ? 24 :
            28
        } else {
            return screenWidth <= 320 ? 6 :
            screenWidth <= 375 ? 8 :
            screenWidth <= 393 ? 10 :
            12
        }
    }
    
    private var uniformButtonHeight: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 50 :
            screenWidth <= 834 ? 54 :
            screenWidth <= 1024 ? 58 :
            62
        } else {
            return screenWidth <= 320 ? 38 :
            screenWidth <= 375 ? 42 :
            screenWidth <= 393 ? 46 :
            48
        }
    }
}

#Preview {
    ZStack {
        BackgroundView()
        UniformButtonsView(
            metronome: MetronomeEngine(),
            showingTimeSignaturePicker: .constant(false),
            showingSubdivisionPicker: .constant(false)
        )
    }
}
