import SwiftUI

struct SegmentedCircleView: View {
    let beatsPerMeasure: Int
    let currentBeat: Int
    let isPlaying: Bool
    let diameter: CGFloat
    let lineWidth: CGFloat
    let highlightFirstBeat: Bool // New parameter
    
    private var radius: CGFloat { (diameter - lineWidth) / 2 }
    private let gapWidthPoints: CGFloat = 25.0
    
    init(
        beatsPerMeasure: Int,
        currentBeat: Int,
        isPlaying: Bool,
        diameter: CGFloat,
        lineWidth: CGFloat,
        highlightFirstBeat: Bool = true
    ) {
        self.beatsPerMeasure = beatsPerMeasure
        self.currentBeat = currentBeat
        self.isPlaying = isPlaying
        self.diameter = diameter
        self.lineWidth = lineWidth
        self.highlightFirstBeat = highlightFirstBeat
    }
    
    var body: some View {
        ZStack {
            ForEach(0 ..< beatsPerMeasure, id: \.self) { beatIndex in
                let (startAngle, endAngle) = angleRangeForBeat(beatIndex)
                ArcSegmentView(
                    center: CGPoint(x: diameter / 2, y: diameter / 2),
                    radius: radius,
                    startAngle: startAngle,
                    endAngle: endAngle,
                    lineWidth: lineWidth,
                    isActive: beatIndex == currentBeat && isPlaying,
                    isFirstBeat: beatIndex == 0,
                    gapWidth: gapWidthPoints,
                    highlightFirstBeat: highlightFirstBeat
                )
            }
        }
        .frame(width: diameter, height: diameter)
    }
    
    private func angleForDivider(_ index: Int) -> Double {
        let degreesPerBeat = 360.0 / Double(beatsPerMeasure)
        let halfSegment = degreesPerBeat / 2
        let startAngle = 270.0
        return startAngle - halfSegment + (Double(index) * degreesPerBeat)
    }
    
    private func angleRangeForBeat(_ beat: Int) -> (start: Double, end: Double) {
        let degreesPerBeat = 360.0 / Double(beatsPerMeasure)
        let gapDegrees = (gapWidthPoints / (2 * .pi * radius)) * 360.0
        let dividerAngle = angleForDivider(beat)
        let startAngle = dividerAngle + (gapDegrees / 2)
        let endAngle = dividerAngle + degreesPerBeat - (gapDegrees / 2)
        return (startAngle, endAngle)
    }
}

// MARK: - Convenience initializer for MetronomeEngine
extension SegmentedCircleView {
    init(metronome: MetronomeEngine, diameter: CGFloat, lineWidth: CGFloat) {
        self.init(
            beatsPerMeasure: metronome.beatsPerMeasure,
            currentBeat: metronome.currentBeat,
            isPlaying: metronome.isPlaying,
            diameter: diameter,
            lineWidth: lineWidth,
            highlightFirstBeat: metronome.highlightFirstBeat
        )
    }
}

#Preview {
    SegmentedCircleView(
        beatsPerMeasure: 4,
        currentBeat: 0, // Set to 0 to show first beat
        isPlaying: true,
        diameter: 200,
        lineWidth: 10,
        highlightFirstBeat: true
    )
}
