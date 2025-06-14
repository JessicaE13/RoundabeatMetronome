import SwiftUI

struct BPMView: View {
    @Bindable var metronome: MetronomeEngine
    @Environment(\.deviceEnvironment) private var device
    
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
                
                // Centered BPM display
                Text("\(metronome.bpm)")
                    .font(.custom("Kanit-SemiBold",
                                  size: device.screenWidth <= 375 ? 70 :
                                        device.screenWidth <= 420 ? 90 :
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
      
           
            
            
            // BPM label
            Text("BEATS PER MINUTE (BPM)")
                .font(.system(
                    size: device.deviceType.buttonFontSize,
                    weight: .medium
                ))
                .foregroundStyle(Color.primary.opacity(0.4))
                .kerning(1.2)
                .offset(y: device.deviceType.isIPad ? 4 : -14)
        }
        .frame(maxWidth: .infinity, maxHeight: device.deviceType.bpmViewHeight, alignment: .center)
        .offset(y: device.deviceType.isIPad ? -10 : 6)
    }
}

#Preview {
    BPMView(metronome: MetronomeEngine())
        .deviceEnvironment(DeviceEnvironment())
        .background(Color.red)
}
