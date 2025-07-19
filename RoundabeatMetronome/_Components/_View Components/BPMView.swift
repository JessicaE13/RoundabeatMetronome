import SwiftUI

struct BPMView: View {
    @ObservedObject var metronome: MetronomeEngine
    @Binding var showingNumberPad: Bool
    
    private var screenWidth: CGFloat {
        UIScreen.main.bounds.width
    }

    private var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var body: some View {
        VStack(spacing: isIPad ? 8 : 4) {
            // BPM Value Button
            Button(action: {
                showingNumberPad = true
            }) {
                Text("\(metronome.bpm)")
                    .font(.custom("Kanit-SemiBold", size: bpmFontSize))
                    .foregroundStyle(Color.primary.opacity(0.9))
                    .kerning(2.0)
                    .lineLimit(1)
                    .frame(
                        width: calculateBPMDisplayWidth(containerWidth: screenWidth),
                        height: bpmFontSize * 0.7
                    )
            }
            .buttonStyle(.plain)

            // BPM Label
//            Text("BEATS PER MINUTE (BPM)")
//                .font(.system(size: buttonFontSize, weight: .medium))
//                .foregroundStyle(Color("Gray1"))
//                .kerning(1.2)
        }
        .frame(maxWidth: .infinity, alignment: .center)
      //  .padding(.vertical, isIPad ? 10 : 6) // Allows natural spacing top and bottom
    }
    
    // MARK: - Layout Calculations

    private func calculateBPMDisplayWidth(containerWidth: CGFloat) -> CGFloat {
        let totalButtonWidth = bpmButtonWidth * 2
        let totalSpacing = buttonSpacing * 2
        let availableWidth = containerWidth - totalButtonWidth - totalSpacing
        let minRequiredWidth = bpmDisplayMinWidth
        return min(availableWidth, max(minRequiredWidth, availableWidth * 0.6))
    }

    private var bpmFontSize: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 100 :
                   screenWidth <= 834 ? 110 :
                   screenWidth <= 1024 ? 120 :
                   140
        } else {
            return screenWidth <= 320 ? 60 :
                   screenWidth <= 375 ? 65 :
                   screenWidth <= 393 ? 70 :
                   75
        }
    }

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

    private var bpmButtonWidth: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 70 :
                   screenWidth <= 834 ? 80 :
                   screenWidth <= 1024 ? 90 :
                   100
        } else {
            return screenWidth <= 320 ? 32 :
                   screenWidth <= 375 ? 38 :
                   screenWidth <= 393 ? 45 :
                   50
        }
    }

    private var bpmDisplayMinWidth: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 240 :
                   screenWidth <= 834 ? 280 :
                   screenWidth <= 1024 ? 320 :
                   360
        } else {
            return screenWidth <= 320 ? 140 :
                   screenWidth <= 375 ? 160 :
                   screenWidth <= 393 ? 180 :
                   200
        }
    }
}

#Preview {
    BPMView(
        metronome: MetronomeEngine(),
        showingNumberPad: .constant(false)
    )
    .background(Color.red)
}
