//
//  TempoScrollView.swift
//

import SwiftUI

// MARK: - Tempo Markings Data
extension TempoMarking {
    static let allTempos: [TempoMarking] = [
        TempoMarking(name: "Larghissimo", bpmRange: 40...50, bpm: 45),
        TempoMarking(name: "Grave", bpmRange: 51...60, bpm: 55),
        TempoMarking(name: "Largo", bpmRange: 61...70, bpm: 65),
        TempoMarking(name: "Adagio", bpmRange: 71...80, bpm: 75),
        TempoMarking(name: "Andante", bpmRange: 81...90, bpm: 85),
        TempoMarking(name: "Moderato", bpmRange: 91...110, bpm: 100),
        TempoMarking(name: "Allegretto", bpmRange: 111...120, bpm: 115),
        TempoMarking(name: "Allegro", bpmRange: 121...140, bpm: 130),
        TempoMarking(name: "Vivace", bpmRange: 141...160, bpm: 150),
        TempoMarking(name: "Presto", bpmRange: 161...180, bpm: 170),
        TempoMarking(name: "Prestissimo", bpmRange: 181...220, bpm: 200),
        TempoMarking(name: "Ultra Fast", bpmRange: 221...400, bpm: 300)
    ]
    
    static func getTempoForBPM(_ bpm: Int) -> TempoMarking? {
        return allTempos.first { $0.bpmRange.contains(bpm) }
    }
}

// MARK: - Tempo Marking Data Structure
struct TempoMarking {
    let name: String
    let bpmRange: ClosedRange<Int>
    let bpm: Int // Representative BPM for this tempo
    
    var displayText: String {
        return "\(name)\n\(bpmRange.lowerBound)-\(bpmRange.upperBound)"
    }
}

// MARK: - Individual Tempo Marking View
struct TempoMarkingView: View {
    let tempo: TempoMarking
    let isSelected: Bool
    let onTap: () -> Void
    @Environment(\.deviceEnvironment) private var device
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                // Tempo name
                Text(tempo.name.uppercased())
                    .font(.system(
                        size: device.deviceType.smallFontSize,
                        weight: isSelected ? .bold : .medium
                    ))
                    .foregroundColor(isSelected ? .primary.opacity(0.9) : .primary.opacity(0.4))
                    .kerning(1.2)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                // BPM range - Updated to use Kanit-Medium
                Text("\(tempo.bpmRange.lowerBound)-\(tempo.bpmRange.upperBound)")
                    .font(.custom("Kanit-Regular", size: device.deviceType.smallFontSize))
                    .foregroundColor(isSelected ? .primary.opacity(0.9) : .primary.opacity(0.4))
                    .kerning(1.4)
                    .padding(.bottom, -4)
            }
            .frame(width: 120)
            .frame(maxHeight: .infinity) // Content fills available space
        
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.clear : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.primary.opacity(isSelected ? 0.3 : 0), lineWidth: 1)
                    )
            )
            .padding(.vertical, 1)
       
        }
 
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

// MARK: - Horizontal Tempo Scroll View
struct TempoScrollView: View {
    let currentBPM: Int
    let onTempoChange: (Int) -> Void
    @Environment(\.deviceEnvironment) private var device
    
    @State private var scrollPosition: CGFloat = 0
    
    private let itemWidth: CGFloat = 100
    private let itemSpacing: CGFloat = 10
    
    var body: some View {
        // Tempo scroll area - constrained to content height
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: itemSpacing) {
                    ForEach(Array(TempoMarking.allTempos.enumerated()), id: \.offset) { index, tempo in
                        TempoMarkingView(
                            tempo: tempo,
                            isSelected: tempo.bpmRange.contains(currentBPM),
                            onTap: {
                                onTempoChange(tempo.bpm)
                            }
                        )
                        .id(index)
                    }
                }
                .padding(.horizontal, device.screenWidth / 2 - itemWidth / 2) // Center the scroll
            }
            .frame(height: device.deviceType.tempoMarkingHeight + 20) // Match the original height exactly
            .onAppear {
                // Scroll to current tempo on appear
                if let currentTempo = TempoMarking.getTempoForBPM(currentBPM),
                   let index = TempoMarking.allTempos.firstIndex(where: { $0.name == currentTempo.name }) {
                    proxy.scrollTo(index, anchor: .center)
                }
            }
            .onChange(of: currentBPM) { _, newBPM in
                // Auto-scroll when BPM changes externally
                if let currentTempo = TempoMarking.getTempoForBPM(newBPM),
                   let index = TempoMarking.allTempos.firstIndex(where: { $0.name == currentTempo.name }) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        proxy.scrollTo(index, anchor: .center)
                    }
                }
            }
        }
    }
}

#Preview {
    let deviceEnv = DeviceEnvironment()
    deviceEnv.updateDevice(width: 390, height: 844) // Simulate iPhone screen size
    
    return VStack {
        TempoScrollView(
            currentBPM: 120,
            onTempoChange: { bpm in print("BPM changed to \(bpm)") }
        )
     
        .background(Color.red.opacity(0.2))
        .deviceEnvironment(deviceEnv)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)

}

