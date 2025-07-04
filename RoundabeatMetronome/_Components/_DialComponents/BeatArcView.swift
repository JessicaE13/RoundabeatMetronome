//
//  BeatArcView.swift
//  RoundabeatMetronome
//
//  Created by Jessica Estes on 7/1/25.
//

import SwiftUI

struct BeatArcView: View {
    let beatNumber: Int
    let totalBeats: Int
    let isActive: Bool
    let size: CGFloat
    let emphasizeFirstBeatOnly: Bool
    
    // FIXED: Consistent stroke width calculations
    private var arcWidth: CGFloat { size * 0.08 }
    private var activeArcWidth: CGFloat { arcWidth * 1.0 } // Consistent with frame calculation
    
    // The maximum stroke width (for active state) determines the frame size needed
    private var maxStrokeWidth: CGFloat { activeArcWidth }
    
    // Frame size needs to account for stroke extending beyond the path
    private var frameSize: CGFloat { size + maxStrokeWidth }
    
    // Calculate arc parameters
    private var center: CGPoint { CGPoint(x: frameSize / 2, y: frameSize / 2) }
    private var radius: CGFloat { size / 2 }
    private var lineWidth: CGFloat { isActive ? activeArcWidth : arcWidth }
    
    // Determine if this beat should show the special outline glow
    private var shouldShowOutlineGlow: Bool {
        emphasizeFirstBeatOnly && isActive && beatNumber != 1
    }
    
    // Determine if this beat should show the normal active state
    private var shouldShowNormalActive: Bool {
        isActive && (!emphasizeFirstBeatOnly || beatNumber == 1)
    }
    
    private var arcAngles: (start: Double, end: Double) {
        let fixedGapDegrees: Double = 16.0 // 16 degrees gap between segments
        let gapAsFraction: CGFloat = CGFloat(fixedGapDegrees / 360.0)
        let totalGapFraction = gapAsFraction * CGFloat(totalBeats)
        let availableSpaceForSegments = 1.0 - totalGapFraction
        let segmentWidth = availableSpaceForSegments / CGFloat(totalBeats)
        
        let adjustedStart = CGFloat(beatNumber - 1) * (segmentWidth + gapAsFraction)
        let adjustedEnd = adjustedStart + segmentWidth
        
        // Convert to degrees and adjust for rotation
        let halfSegmentWidthInDegrees = Double(segmentWidth) * 360.0 / 2.0
        let rotationOffset = -90.0 - halfSegmentWidthInDegrees
        
        let startAngle = (Double(adjustedStart) * 360.0) + rotationOffset
        let endAngle = (Double(adjustedEnd) * 360.0) + rotationOffset
        
        return (startAngle, endAngle)
    }
    
    var body: some View {
        ZStack {
            // Shared arc path
            let arcPath = Path { path in
                path.addArc(center: center,
                            radius: radius,
                            startAngle: Angle(degrees: arcAngles.start),
                            endAngle: Angle(degrees: arcAngles.end),
                            clockwise: false)
            }
            
            // Base etched outline
            arcPath
                .strokedPath(StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .stroke(shouldShowNormalActive ?
                        Color(red: 1/255, green: 1/255, blue: 2/255).opacity(0.3) :
                            Color.primary.opacity(0.1),
                        lineWidth: shouldShowNormalActive ? 1.0 : 1.0)
//                .shadow(color: Color(red: 101/255, green: 101/255, blue: 102/255).opacity(shouldShowNormalActive ? 0.2 : 0.75),
//                        radius: 0.5, x: 0, y: 0)
            
            // Special bright white glowing outline for non-first beats when emphasizeFirstBeatOnly is true
            if shouldShowOutlineGlow {
                arcPath
                    .strokedPath(StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                    .fill(Color(red: 43/255, green: 44/255, blue: 44/255))
                    .shadow(color: Color(red: 101/255, green: 101/255, blue: 102/255).opacity(0.3),
                            radius: 0.5, x: 0, y: 0)
                
                arcPath
                    .strokedPath(StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                    .stroke(Color.white.opacity(0.6), lineWidth: 1.75)
                    .shadow(color: Color.white.opacity(shouldShowNormalActive ? 0.3 : 0.6), radius: 4, x: 0, y: 0)
                    .shadow(color: Color.white.opacity(shouldShowNormalActive ? 0.2 : 0.4), radius: 8, x: 0, y: 0)
                    .shadow(color: Color(red: 101/255, green: 101/255, blue: 102/255).opacity(shouldShowNormalActive ? 0.1 : 0.3), radius: 12, x: 0, y: 0)
            }
            
            // Normal active state (only for first beat when emphasizeFirstBeatOnly is true, or all beats when false)
            if shouldShowNormalActive {
                // Inner light core - brightest white
                arcPath
                    .strokedPath(StrokeStyle(lineWidth: lineWidth * 0.98, lineCap: .round))
                    .fill(Color.white)
                
                // Medium glow layer that bleeds over the outline
                arcPath
                    .strokedPath(StrokeStyle(lineWidth: lineWidth * 0.99, lineCap: .round))
                    .fill(Color.white.opacity(0.7))
                    .blur(radius: 2)
                
                // Wider glow layer that further bleeds over the outline
                arcPath
                    .strokedPath(StrokeStyle(lineWidth: lineWidth * 1.1, lineCap: .round))
                    .fill(Color.white.opacity(0.5))
                    .blur(radius: 4)
                
                // Outer atmospheric glow
                arcPath
                    .strokedPath(StrokeStyle(lineWidth: lineWidth * 1.2, lineCap: .round))
                    .fill(Color.white.opacity(0.3))
                    .blur(radius: 8)
                
                // Outermost subtle glow
                arcPath
                    .strokedPath(StrokeStyle(lineWidth: lineWidth * 1.5, lineCap: .round))
                    .fill(Color.white.opacity(0.15))
                    .blur(radius: 12)
            } else if !isActive {
                // Inactive state - subtle fill
                arcPath
                    .strokedPath(StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                    .fill(Color.clear)
                    .fill(Color(red: 44/255, green: 44/255, blue: 45/255))
                   // .shadow(color: Color(red: 101/255, green: 101/255, blue: 102/255).opacity(0.3),
                     //       radius: 0.5, x: 0, y: 0)
            }
        }
        .frame(width: frameSize, height: frameSize, alignment: .center)
    }
}

#Preview {
    ZStack {
        
        BackgroundView()
        
        BeatArcView(
            beatNumber: 1,
            totalBeats: 4,
            isActive: true,
            size: 250,
            emphasizeFirstBeatOnly: true
        )
        
        // Active non-first beat with emphasis (should show outline glow)
        BeatArcView(
            beatNumber: 2,
            totalBeats: 4,
            isActive: false,
            size: 250,
            emphasizeFirstBeatOnly: true
        )
        
        // Inactive beat
        BeatArcView(
            beatNumber: 3,
            totalBeats: 4,
            isActive: false,
            size: 250,
            emphasizeFirstBeatOnly: false
        )
        
        // Active beat without emphasis
        BeatArcView(
            beatNumber: 4,
            totalBeats: 4,
            isActive: false,
            size: 250,
            emphasizeFirstBeatOnly: false
        )
        
        // Play button in center
             Button(action: {
                 // Add your play/pause action here
             }) {
                 Image(systemName: "play.fill")
                     .font(.system(size: 75))
                     .foregroundColor(.white)

             }
             
         
        
        
        
    }
    .frame(width: 330, height: 330)
   
}
