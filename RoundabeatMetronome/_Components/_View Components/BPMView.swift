import SwiftUI

struct BPMView: View {
    @ObservedObject var metronome: MetronomeEngine
    @Binding var showingNumberPad: Bool
    
    // Get actual screen width directly
    private var screenWidth: CGFloat {
        UIScreen.main.bounds.width
    }
    
    // Get screen height for responsive sizing
    private var screenHeight: CGFloat {
        UIScreen.main.bounds.height
    }
    
    // Check if device is iPad
    private var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                HStack(alignment: .center, spacing: buttonSpacing) {
                    
//                    // Minus button
//                    Button("-1") {
//                        let newBPM = metronome.bpm - 1
//                        metronome.bpm = max(40, min(400, newBPM))
//                    }
//                    .font(.system(size: buttonFontSize, weight: .medium))
//                    .frame(
//                        width: bpmButtonWidth,
//                        height: bpmButtonHeight
//                    )
//                    .buttonStyle(.bordered)
                    
                    // Centered BPM display - properly calculated width
                    Button(action: {
                        showingNumberPad = true
                    }) {
                        Text("\(metronome.bpm)")
                            .font(.custom("Kanit-SemiBold", size: bpmFontSize))
                            .foregroundStyle(Color.primary.opacity(0.9))
                            .kerning(2.0)
                            .lineLimit(1)
                            .frame(
                                width: calculateBPMDisplayWidth(containerWidth: geometry.size.width),
                                height: largeFontSize,
                                alignment: .center
                            )
                            .background(Color.clear)
                    }
                    .buttonStyle(.plain)
                    
//                    // Plus button
//                    Button("+1") {
//                        let newBPM = metronome.bpm + 1
//                        metronome.bpm = max(40, min(400, newBPM))
//                    }
//                    .font(.system(size: buttonFontSize, weight: .medium))
//                    .frame(
//                        width: bpmButtonWidth,
//                        height: bpmButtonHeight
//                    )
//                    .buttonStyle(.bordered)
                }
                .frame(maxWidth: .infinity)
                .offset(y: isIPad ? -16 : -16)
                
                // BPM label
                Text("BEATS PER MINUTE (BPM)")
                    .font(.system(
                        size: buttonFontSize,
                        weight: .medium
                    ))
                    .foregroundStyle(Color("Gray1"))
                    .kerning(1.2)
                    .offset(y: isIPad ? 4 : -8)
            }
            .frame(maxWidth: .infinity, maxHeight: bpmViewHeight, alignment: .center)
            .offset(y: isIPad ? -10 : 6)
        }
        .frame(height: bpmViewHeight, alignment: .center)
    }
    
    // MARK: - Improved Calculations
    
    private func calculateBPMDisplayWidth(containerWidth: CGFloat) -> CGFloat {
        // Calculate available width for BPM display
        let totalButtonWidth = bpmButtonWidth * 2
        let totalSpacing = buttonSpacing * 2
        let availableWidth = containerWidth - totalButtonWidth - totalSpacing
        
        // Use minimum required width, but don't exceed available space
        let minRequiredWidth = bpmDisplayMinWidth
        return min(availableWidth, max(minRequiredWidth, availableWidth * 0.6))
    }
    
    private var bpmFontSize: CGFloat {
        // Simplified font size calculation based on display width
        if isIPad {
            return screenWidth <= 768 ? 100 :
                   screenWidth <= 834 ? 120 :
                   screenWidth <= 1024 ? 130 :
                   150
        } else {
            return screenWidth <= 320 ? 65 :
                   screenWidth <= 375 ? 75 :
                   screenWidth <= 393 ? 90 :
                   95
        }
    }
    
    // MARK: - Responsive Properties (Cleaned up)
    
    private var largeFontSize: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 100 :
                   screenWidth <= 834 ? 120 :
                   screenWidth <= 1024 ? 130 :
                   150
        } else {
            return screenWidth <= 320 ? 65 :
                   screenWidth <= 375 ? 75 :
                   screenWidth <= 393 ? 90 :
                   95
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
    
    private var bpmViewHeight: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 130 :
                   screenWidth <= 834 ? 150 :
                   screenWidth <= 1024 ? 160 :
                   180
        } else {
            return screenWidth <= 320 ? 75 :
                   screenWidth <= 375 ? 85 :
                   screenWidth <= 393 ? 90 :
                   95
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
    
    private var bpmButtonHeight: CGFloat {
        if isIPad {
            return screenWidth <= 768 ? 45 :
                   screenWidth <= 834 ? 50 :
                   screenWidth <= 1024 ? 55 :
                   60
        } else {
            return screenWidth <= 320 ? 28 :
                   screenWidth <= 375 ? 32 :
                   screenWidth <= 393 ? 36 :
                   40
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
