//import SwiftUI
//
//struct TempoSelectorView: View {
//    @ObservedObject var metronome: MetronomeEngine
//    @Binding var previousTempo: Double
//    
//    var body: some View {
//        GeometryReader { geometry in
//          
//            
//            ZStack {
//                ScrollView(.horizontal, showsIndicators: false) {
//                    ScrollViewReader { proxy in
//                        HStack {
//                            Spacer()
//                                .frame(width: 75)
//                            
//                            ForEach(TempoRange.allRanges.indices, id: \.self) { index in
//                                let range = TempoRange.allRanges[index]
//                                let isSelected = TempoRange.getCurrentRange(for: metronome.tempo).name == range.name
//                                
//                                VStack(spacing: 4) {
//                                    Text(range.name.uppercased())
//                                        .font(.system(.subheadline, weight: .medium))
//                                        .kerning(2.0)
//                                        .foregroundColor(isSelected ?
//                                                         Color.white.opacity(0.9) :
//                                                            Color.white.opacity(0.4))
//                                        .multilineTextAlignment(.center)
//                                        .lineLimit(2)
//                                        .minimumScaleFactor(0.8)
//                                    
//                                    Text("\(range.minBPM)-\(range.maxBPM)")
//                                        .font(.custom("Kanit-Regular", size: 10))
//                                        .kerning(1.5)
//                                        .foregroundColor(isSelected ?
//                                                         Color.white.opacity(0.7) :
//                                                            Color.white.opacity(0.3))
//                                }
//                                .frame(minWidth: 65)
//                                .padding( 8)
//                                .padding(.horizontal, 12)
//                                .background(
//                                    RoundedRectangle(cornerRadius: 15)
//                                        .stroke(Color.accentColor.opacity(0.5), lineWidth: 1)
//                                        .opacity(isSelected ? 1 : 0)
//                                )
//                                .padding(1)
//                                .contentShape(Rectangle())
//                                .onTapGesture {
//                                    let generator = UIImpactFeedbackGenerator(style: .medium)
//                                    generator.impactOccurred()
//                                    metronome.updateTempo(to: Double(range.midBPM))
//                                    previousTempo = metronome.tempo
//                                }
//                                .id(index)
//                            }
//                            
//                            Spacer()
//                                .frame(width: 75)
//                        }
//                        .padding(.horizontal,50)
//                        .onAppear {
//                            // Scroll to current tempo range on appear
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                                if let currentIndex = TempoRange.allRanges.firstIndex(where: { $0.name == TempoRange.getCurrentRange(for: metronome.tempo).name }) {
//                                    withAnimation(.easeInOut(duration: 0.5)) {
//                                        proxy.scrollTo(currentIndex, anchor: getScrollAnchor(for: currentIndex))
//                                    }
//                                }
//                            }
//                        }
//                        .onChange(of: metronome.tempo) { oldValue, newValue in
//                            // Auto-scroll to current tempo range when tempo changes with smoother animation
//                            if let currentIndex = TempoRange.allRanges.firstIndex(where: { $0.name == TempoRange.getCurrentRange(for: metronome.tempo).name }) {
//                                withAnimation(.easeInOut(duration: 0.6)) {
//                                    proxy.scrollTo(currentIndex, anchor: getScrollAnchor(for: currentIndex))
//                                }
//                            }
//                        }
//                    }
//                }
//                .scrollBounceBehavior(.basedOnSize)
//            }
//        }
//        .frame(height: 60)
//    }
//    
//    // Helper function to determine scroll anchor based on position
//    private func getScrollAnchor(for index: Int) -> UnitPoint {
//        let totalCount = TempoRange.allRanges.count
//        
//        // For the first item, align to leading to prevent empty space on the left
//        if index == 0 {
//            return .leading
//        }
//        // For the last item, align to trailing to prevent empty space on the right
//        else if index == totalCount - 1 {
//            return .trailing
//        }
//        // For all middle items, center as usual
//        else {
//            return .center
//        }
//    }
//}
//
//#Preview {
//    ZStack {
//        BackgroundView()
//        
//        VStack {
//            TempoSelectorView(
//                metronome: MetronomeEngine(),
//                previousTempo: .constant(120)
//            )
//            .overlay(
//                Rectangle()
//                    .stroke(Color.red, lineWidth: 1)
//            )
//        }
//    }
//}
