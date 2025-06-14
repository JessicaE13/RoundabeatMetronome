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
    @Bindable var metronome: MetronomeEngine
    @Environment(\.deviceEnvironment) private var device
    
    var body: some View {
        HStack(spacing: device.deviceType.buttonSpacing) {
            Spacer()
            
            // Time signature cycling button
            UniformButton(
                text: "TIME \(metronome.beatsPerBar)/4",
                action: {
                    // Cycle through time signatures: 3 -> 4 -> 5 -> 6 -> 3
                    switch metronome.beatsPerBar {
                    case 3:
                        metronome.beatsPerBar = 4
                    case 4:
                        metronome.beatsPerBar = 5
                    case 5:
                        metronome.beatsPerBar = 6
                    case 6:
                        metronome.beatsPerBar = 3
                    default:
                        metronome.beatsPerBar = 4
                    }
                }
            )
            
            // Subdivision cycling button
            UniformButton(
                text: "SUB DIV. \(metronome.subdivisionLabel())",
                action: {
                    // Cycle through subdivisions: 1 -> 2 -> 4 -> 3 -> 1
                    switch metronome.subdivision {
                    case 1:
                        metronome.subdivision = 2 // Quarter to eighth
                    case 2:
                        metronome.subdivision = 4 // Eighth to sixteenth
                    case 4:
                        metronome.subdivision = 3 // Sixteenth to triplet
                    case 3:
                        metronome.subdivision = 1 // Triplet to quarter
                    default:
                        metronome.subdivision = 1
                    }
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
            
            Spacer()
        }
        .frame(height: device.deviceType.uniformButtonHeight)
    }
}

#Preview {
    
    ZStack {
        BackgroundView()
        UniformButtonsView(metronome: MetronomeEngine())
            .deviceEnvironment(DeviceEnvironment())
    }
}
