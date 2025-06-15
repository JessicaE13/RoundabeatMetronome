import SwiftUI

// MARK: - Uniform Button Component
struct UniformButton: View {
    let text: String
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
            Text(text)
                .font(.system(size: buttonFontSize, weight: .medium))
                .foregroundColor(.primary.opacity(0.6))
                .kerning(1.2)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .multilineTextAlignment(.center)
        }
        .frame(
            width: uniformButtonWidth,
            height: uniformButtonHeight
        )
        .background(Color(.systemBackground).opacity(0.98))
        .cornerRadius(12)
        .overlay(
              RoundedRectangle(cornerRadius: 12)
                  .stroke(Color.primary.opacity(0.1), lineWidth: 1)
          )
    }
    
    // MARK: - Responsive Properties
    
    private var buttonFontSize: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 14 :
                   screenWidth <= 834 ? 16 :
                   screenWidth <= 1024 ? 18 :
                   20
        } else {
            return screenWidth <= 320 ? 10 :
                   screenWidth <= 375 ? 11 :
                   screenWidth <= 393 ? 12 :
                   13
        }
    }
    
    private var uniformButtonWidth: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 110 :
                   screenWidth <= 834 ? 120 :
                   screenWidth <= 1024 ? 130 :
                   140
        } else {
            return screenWidth <= 320 ? 75 :
                   screenWidth <= 375 ? 85 :
                   screenWidth <= 393 ? 95 :
                   105
        }
    }
    
    private var uniformButtonHeight: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 40 :
                   screenWidth <= 834 ? 44 :
                   screenWidth <= 1024 ? 48 :
                   52
        } else {
            return screenWidth <= 320 ? 28 :
                   screenWidth <= 375 ? 32 :
                   screenWidth <= 393 ? 36 :
                   38
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
                Image(systemName: iconName)
                    .font(.system(size: buttonFontSize - 1))
            }
            .foregroundColor(.primary.opacity(0.6))
            .kerning(1.2)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(
            width: uniformButtonWidth,
            height: uniformButtonHeight
        )
        .background(Color(.systemBackground).opacity(0.98))
        .cornerRadius(12)
        .overlay(
              RoundedRectangle(cornerRadius: 12)
                  .stroke(Color.primary.opacity(0.1), lineWidth: 1)
          )
    }
    
    // MARK: - Responsive Properties
    
    private var buttonFontSize: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 14 :
                   screenWidth <= 834 ? 16 :
                   screenWidth <= 1024 ? 18 :
                   20
        } else {
            return screenWidth <= 320 ? 10 :
                   screenWidth <= 375 ? 11 :
                   screenWidth <= 393 ? 12 :
                   13
        }
    }
    
    private var uniformButtonWidth: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 110 :
                   screenWidth <= 834 ? 120 :
                   screenWidth <= 1024 ? 130 :
                   140
        } else {
            return screenWidth <= 320 ? 75 :
                   screenWidth <= 375 ? 85 :
                   screenWidth <= 393 ? 95 :
                   105
        }
    }
    
    private var uniformButtonHeight: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 40 :
                   screenWidth <= 834 ? 44 :
                   screenWidth <= 1024 ? 48 :
                   52
        } else {
            return screenWidth <= 320 ? 28 :
                   screenWidth <= 375 ? 32 :
                   screenWidth <= 393 ? 36 :
                   38
        }
    }
}

// MARK: - Uniform Buttons View (Back to Original Layout)
struct UniformButtonsView: View {
    @ObservedObject var metronome: MetronomeEngine
    
    // Bindings for showing pickers - removed sound picker
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
            // Time signature button - shows actual time signature and opens picker
            UniformButton(
                text: "TIME \(metronome.beatsPerMeasure)/\(metronome.beatUnit)",
                action: {
                    showingTimeSignaturePicker = true
                }
            )
            
            // Subdivision button - now opens subdivision picker
            UniformButton(
                text: "SUB DIV. \(getCurrentSubdivisionSymbol())",
                action: {
                    showingSubdivisionPicker = true
                }
            )
            
            // Tap tempo button
            UniformButtonWithIcon(
                text: "TAP",
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
            return screenWidth <= 768 ? 40 :
                   screenWidth <= 834 ? 44 :
                   screenWidth <= 1024 ? 48 :
                   52
        } else {
            return screenWidth <= 320 ? 28 :
                   screenWidth <= 375 ? 32 :
                   screenWidth <= 393 ? 36 :
                   38
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
