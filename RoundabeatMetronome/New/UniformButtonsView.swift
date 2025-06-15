import SwiftUI

// MARK: - Uniform Button Component
struct UniformButton: View {
    let text: String
    let action: () -> Void
    @Environment(\.deviceEnvironment) private var device
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.system(size: device.deviceType.buttonFontSize, weight: .medium))
                .foregroundColor(.primary.opacity(0.6))
                .kerning(1.2)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .multilineTextAlignment(.center)
        }
        .frame(
            width: device.deviceType.uniformButtonWidth,
            height: device.deviceType.uniformButtonHeight
        )
        .background(Color(.systemBackground).opacity(0.98))
        .cornerRadius(12)
        .overlay(
              RoundedRectangle(cornerRadius: 12)
                  .stroke(Color.primary.opacity(0.1), lineWidth: 1)
          )
    }
}

// MARK: - Uniform Button with Icon Component
struct UniformButtonWithIcon: View {
    let text: String
    let iconName: String
    let action: () -> Void
    @Environment(\.deviceEnvironment) private var device
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 3) {
                Text(text)
                    .font(.system(size: device.deviceType.buttonFontSize, weight: .medium))
                Image(systemName: iconName)
                    .font(.system(size: device.deviceType.buttonFontSize - 1))
            }
            .foregroundColor(.primary.opacity(0.6))
            .kerning(1.2)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(
            width: device.deviceType.uniformButtonWidth,
            height: device.deviceType.uniformButtonHeight
        )
        .background(Color(.systemBackground).opacity(0.98))
        .cornerRadius(12)
        .overlay(
              RoundedRectangle(cornerRadius: 12)
                  .stroke(Color.primary.opacity(0.1), lineWidth: 1)
          )
    }
}

// MARK: - Uniform Buttons View
struct UniformButtonsView: View {
    @ObservedObject var metronome: MetronomeEngine
    @Environment(\.deviceEnvironment) private var device
    
    // Bindings for showing pickers - now controlled by parent
    @Binding var showingTimeSignaturePicker: Bool
    @Binding var showingSubdivisionPicker: Bool
    
    // Helper function to get current subdivision symbol
    private func getCurrentSubdivisionSymbol() -> String {
        // Find the subdivision option that matches the current multiplier
        let currentOption = SubdivisionPickerView.subdivisionOptions.first { option in
            option.multiplier == metronome.subdivisionMultiplier
        }
        return currentOption?.symbol ?? "♩"
    }
    
    var body: some View {
        HStack(spacing: device.deviceType.buttonSpacing) {
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
        .frame(height: device.deviceType.uniformButtonHeight)
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
        .deviceEnvironment(DeviceEnvironment())
    }
}
