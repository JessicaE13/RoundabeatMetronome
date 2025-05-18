import SwiftUI

struct SegmentView: View {
    @ObservedObject var metronome: MetronomeEngine
    let arcGap: CGFloat = 0.02
    let tickCount = 60 // Change this number for more or fewer ticks
    
    var body: some View {
        ZStack {
            // Main segments with inner shadow effect and subtle outline - keeping original spacing
            ForEach(0..<metronome.beatsPerMeasure, id: \.self) { index in
                ZStack {
                    // Subtle inner shadow effect
                    Circle()
                        .trim(from: arcGap, to: (1 / CGFloat(metronome.beatsPerMeasure)) - arcGap)
                        .rotation(.degrees(Double(index) * (360 / Double(metronome.beatsPerMeasure))))
                        .rotation(.degrees(-180 + (180 / Double(metronome.beatsPerMeasure))))
                        .stroke(
                            Color(red: 229/255, green: 225/255, blue: 217/255),
                            style: StrokeStyle(lineWidth: 27, lineCap: .round)
                        )
                        .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
                        .frame(width: 275, height: 275)
                    
                    // Main segment with gradient overlay - red for current beat, normal for others
                    Circle()
                        .trim(from: arcGap, to: (1 / CGFloat(metronome.beatsPerMeasure)) - arcGap)
                        .rotation(.degrees(Double(index) * (360 / Double(metronome.beatsPerMeasure))))
                        .rotation(.degrees(-180 + (180 / Double(metronome.beatsPerMeasure))))
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    metronome.isPlaying && metronome.currentBeat == index  ?
                                        Color.red.opacity(0.8) : Color.white.opacity(0.3),    // lighter at top
                                    metronome.isPlaying && metronome.currentBeat  == index ?
                                        Color.red.opacity(0.6) : Color.white.opacity(0.2)     // darker at bottom for depth
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            style: StrokeStyle(lineWidth: 26, lineCap: .round)
                        )
                        .overlay(
                            Circle()
                                .trim(from: arcGap, to: (1 / CGFloat(metronome.beatsPerMeasure)) - arcGap)
                                .rotation(.degrees(Double(index) * (360 / Double(metronome.beatsPerMeasure))))
                                .rotation(.degrees(-180 + (180 / Double(metronome.beatsPerMeasure))))
                                .stroke(
                                    metronome.isPlaying && metronome.currentBeat == index ?
                                        Color.red.opacity(0.3) : Color.gray.opacity(0.2),
                                    style: StrokeStyle(lineWidth: 27, lineCap: .round)
                                )
                                .blendMode(.overlay)
                        )
                        .frame(width: 275, height: 275)
                }
            }

            // Outer ring
            Circle()
                .fill(Color.black.opacity(0.8))
                .shadow(radius: 10)
                .frame(width: 215)
            
            // Outer ring
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                .frame(width: 215)

            // Inner white button background
            Circle()
                .fill(Color.clear)
                .frame(width: 100)

            // Inner ring border
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                .shadow(radius: 5)
                .frame(width: 100)
            
            ForEach(0..<tickCount, id: \.self) { index in
                Rectangle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 1, height: 48)
                    .offset(y: -79) // Positioned halfway between 275 and 100 diameter
                    .rotationEffect(.degrees(Double(index) * (360 / Double(tickCount))))
            }
            
            // Play/pause icon depending on metronome state
            Image(systemName: metronome.isPlaying ? "pause.fill" : "play.fill")
                .font(.system(size: 50, weight: .light))
                .foregroundStyle(
                    RadialGradient(
                        gradient: Gradient(colors: [.white, .gray]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 45
                    )
                )
        }
        .frame(width: 310, height: 310)
        .contentShape(Rectangle())
        .clipped()
        .onTapGesture {
            metronome.togglePlayback()
        }
    }
}

struct SliderView: View {
    @ObservedObject var metronome: MetronomeEngine

    var body: some View {
        VStack(spacing: 20) {
            // Time signature beats per measure control
            VStack(alignment: .leading) {
                Text("Beats Per Measure: \(metronome.beatsPerMeasure)")
                    .font(.headline)
                Slider(value: Binding<Double>(
                    get: { Double(metronome.beatsPerMeasure) },
                    set: { metronome.updateTimeSignature(numerator: Int($0), denominator: metronome.beatUnit) }
                ), in: 2...8, step: 1)
            }
            .padding(.horizontal)
            
            // Tempo control
            VStack(alignment: .leading) {
                Text("Tempo: \(Int(metronome.tempo)) BPM")
                    .font(.headline)
                Slider(value: $metronome.tempo, in: metronome.minTempo...metronome.maxTempo)
                    .onChange(of: metronome.tempo) { newValue in
                        metronome.updateTempo(to: newValue)
                    }
            }
            .padding(.horizontal)
        }
    }
}

struct CombinedVIew: View {
    @StateObject private var metronome = MetronomeEngine()

    var body: some View {
        VStack {
            SegmentView(metronome: metronome)
            SliderView(metronome: metronome)
        }
    }
}

#Preview {
    CombinedVIew()
}
