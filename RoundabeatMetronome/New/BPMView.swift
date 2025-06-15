import SwiftUI

struct BPMView: View {
    @ObservedObject var metronome: MetronomeEngine
    @Environment(\.deviceEnvironment) private var device
    @Binding var showingNumberPad: Bool
    
    // Get actual screen width directly
    private var actualScreenWidth: CGFloat {
        UIScreen.main.bounds.width
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: device.deviceType.buttonSpacing) {
                // Minus button
                Button("-1") {
                    let newBPM = metronome.bpm - 1
                    metronome.bpm = max(40, min(400, newBPM))
                }
                .font(.system(size: device.deviceType.buttonFontSize, weight: .medium))
                .frame(
                    width: device.deviceType.bpmButtonWidth,
                    height: device.deviceType.bpmButtonHeight
                )
                .buttonStyle(.bordered)
                
                // Centered BPM display - now tappable and uses actual screen width
                Button(action: {
                    showingNumberPad = true
                }) {
                    Text("\(metronome.bpm)")
                        .font(.custom("Kanit-SemiBold",
                                      size: actualScreenWidth <= 375 ? 70 :
                                            actualScreenWidth <= 420 ? 90 :
                                            actualScreenWidth <= 800 ? 100 :
                                            actualScreenWidth <= 900 ? 110 :
                                            120))
                        .foregroundStyle(Color.primary.opacity(0.9))
                        .kerning(2.0)
                        .lineLimit(1)
                        .frame(
                            minWidth: device.deviceType.bpmDisplayMinWidth,
                            idealHeight: device.deviceType.largeFontSize,
                            maxHeight: device.deviceType.largeFontSize
                        )
                        .background(Color.clear)
                }
                .buttonStyle(.plain)
                
                // Plus button
                Button("+1") {
                    let newBPM = metronome.bpm + 1
                    metronome.bpm = max(40, min(400, newBPM))
                }
                .font(.system(size: device.deviceType.buttonFontSize, weight: .medium))
                .frame(
                    width: device.deviceType.bpmButtonWidth,
                    height: device.deviceType.bpmButtonHeight
                )
                .buttonStyle(.bordered)
            }
            .offset(y: device.deviceType.isIPad ? -8 : -16)
      
          // Text("\(actualScreenWidth)")
            
            
            // BPM label
            Text("BEATS PER MINUTE (BPM)")
                .font(.system(
                    size: device.deviceType.buttonFontSize,
                    weight: .medium
                ))
                .foregroundStyle(Color.primary.opacity(0.4))
                .kerning(1.2)
                .offset(y: device.deviceType.isIPad ? 4 : -8)
        }
        .frame(maxWidth: .infinity, maxHeight: device.deviceType.bpmViewHeight, alignment: .center)
        .offset(y: device.deviceType.isIPad ? -10 : 6)
        .onAppear {
            // Debug: Print the actual screen width vs device environment width
            print("🔍 Actual screen width: \(actualScreenWidth)")
            print("🔍 Device environment width: \(device.screenWidth)")
        }
    }
}

#Preview {
    BPMView(
        metronome: MetronomeEngine(),
        showingNumberPad: .constant(false)
    )
    .deviceEnvironment(DeviceEnvironment())
    .background(Color.red)
}
