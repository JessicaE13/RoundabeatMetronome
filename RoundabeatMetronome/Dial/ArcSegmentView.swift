//import SwiftUI
//
//struct ArcSegmentView: View {
//    let center: CGPoint
//    let radius: CGFloat
//    let startAngle: Double
//    let endAngle: Double
//    let lineWidth: CGFloat
//    let isActive: Bool
//    let isFirstBeat: Bool
//    let gapWidth: CGFloat
//    let highlightFirstBeat: Bool
//   
//    var body: some View {
//        ZStack {
//            // Shared arc path
//            let arcPath = Path { path in
//                path.addArc(center: center,
//                            radius: radius,
//                            startAngle: Angle(degrees: startAngle),
//                            endAngle: Angle(degrees: endAngle),
//                            clockwise: false)
//            }
//
//            if isActive {
//                // Determine if this beat should get special treatment
//                let shouldHighlightFirstBeat = isFirstBeat && highlightFirstBeat
//                let shouldShowOutlineOnly = !isFirstBeat && highlightFirstBeat
//                
//                if shouldHighlightFirstBeat {
//                   
//                    let primaryColor = Color.accentColor
//                    
//                    // Outermost soft glow
//                    arcPath
//                        .stroke(primaryColor.opacity(0.5),
//                                style: StrokeStyle(lineWidth: lineWidth + 20, lineCap: .round))
//                        .blur(radius: 15)
//                    
//                    // Middle glow layer
//                    arcPath
//                        .stroke(primaryColor.opacity(0.3),
//                                style: StrokeStyle(lineWidth: lineWidth + 12, lineCap: .round))
//                        .blur(radius: 8)
//                    
//                    // Inner glow
//                    arcPath
//                        .stroke(primaryColor.opacity(0.6),
//                                style: StrokeStyle(lineWidth: lineWidth + 4, lineCap: .round))
//                        .blur(radius: 3)
//                    
//                    // Core LED light - bright and crisp
//                    arcPath
//                        .stroke(
//                            LinearGradient(
//                                colors: [Color.white, Color.white.opacity(0.9)],
//                                startPoint: .topLeading,
//                                endPoint: .bottomTrailing
//                            ),
//                            style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
//                        )
//                        .shadow(color: primaryColor.opacity(0.8),
//                               radius: 2, x: 0, y: 0)
//                    
//                    // Inner highlight for extra LED brightness
//                    arcPath
//                        .stroke(primaryColor.opacity(0.9),
//                                style: StrokeStyle(lineWidth: lineWidth * 0.3, lineCap: .round))
//                        
//                } else if shouldShowOutlineOnly {
//                    // Other beats when first beat highlighting is enabled - OUTLINE only
//                    arcPath
//                        .strokedPath(StrokeStyle(lineWidth: lineWidth, lineCap: .round))
//                        .fill(Color(red: 43/255, green: 44/255, blue: 44/255))
//                        .shadow(color: Color(red: 101/255, green: 101/255, blue: 102/255).opacity(0.3), radius: 0.5, x: 0, y: 0)
//                    
//                    arcPath
//                        .strokedPath(StrokeStyle(lineWidth: lineWidth, lineCap: .round))
//                        .stroke(Color(red: 251/255, green: 251/255, blue: 252/255), lineWidth: 2.5)
//                        .blur(radius: 3)
//                    
//                    arcPath
//                        .strokedPath(StrokeStyle(lineWidth: lineWidth, lineCap: .round))
//                        .stroke(Color(red: 251/255, green: 251/255, blue: 252/255), lineWidth: 1.5)
//                        .shadow(color: Color(red: 201/255, green: 201/255, blue: 202/255).opacity(0.75), radius: 0.75, x: 0, y: 0)
//                        
//                } else {
//                    // Default behavior when highlighting is disabled - all beats get white glow
//                    let primaryColor = Color.accentColor
//                    
//                    // Outermost soft glow
//                    arcPath
//                        .stroke(primaryColor.opacity(0.5),
//                                style: StrokeStyle(lineWidth: lineWidth + 20, lineCap: .round))
//                        .blur(radius: 15)
//                    
//                    // Middle glow layer
//                    arcPath
//                        .stroke(primaryColor.opacity(0.3),
//                                style: StrokeStyle(lineWidth: lineWidth + 12, lineCap: .round))
//                        .blur(radius: 8)
//                    
//                    // Inner glow
//                    arcPath
//                        .stroke(primaryColor.opacity(0.6),
//                                style: StrokeStyle(lineWidth: lineWidth + 4, lineCap: .round))
//                        .blur(radius: 3)
//                    
//                    // Core LED light - bright and crisp
//                    arcPath
//                        .stroke(
//                            LinearGradient(
//                                colors: [Color.white, Color.white.opacity(0.9)],
//                                startPoint: .topLeading,
//                                endPoint: .bottomTrailing
//                            ),
//                            style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
//                        )
//                        .shadow(color: primaryColor.opacity(0.8),
//                               radius: 2, x: 0, y: 0)
//                    
//                    // Inner highlight for extra LED brightness
//                    arcPath
//                        .stroke(primaryColor.opacity(0.9),
//                                style: StrokeStyle(lineWidth: lineWidth * 0.3, lineCap: .round))
//                }
//                
//            } else {
//                // Inactive state - subtle outline
//                arcPath
//                    .strokedPath(StrokeStyle(lineWidth: lineWidth, lineCap: .round))
//                    .fill(Color(red: 43/255, green: 44/255, blue: 44/255))
//                    .shadow(color: Color(red: 101/255, green: 101/255, blue: 102/255).opacity(0.3), radius: 0.5, x: 0, y: 0)
//                arcPath
//                    .strokedPath(StrokeStyle(lineWidth: lineWidth, lineCap: .round))
//                    .stroke(Color(red: 1/255, green: 1/255, blue: 2/255), lineWidth: 1.5)
//                    .shadow(color: Color(red: 101/255, green: 101/255, blue: 102/255).opacity(0.75), radius: 0.5, x: 0, y: 0)
//            }
//        }
//        .animation(.easeInOut(duration: 0.04), value: isActive)
//    }
//}
//
//#Preview {
//    ZStack {
//        BackgroundView()
//        
//        GeometryReader { geometry in
//            ArcSegmentView(
//                center: CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2),
//                radius: 120,
//                startAngle: 225,
//                endAngle: 315,
//                lineWidth: 25,
//                isActive: false,
//                isFirstBeat: true,
//                gapWidth: 10,
//                highlightFirstBeat: true
//            )
//        }
//    }
//}
