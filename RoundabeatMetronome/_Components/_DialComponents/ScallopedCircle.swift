import SwiftUI

struct ScallopedCircle: View {
    // Configuration variables
    let circleSize: CGFloat = 24
    let offsetRadius: CGFloat = 172
    
    var body: some View {
        ZStack {
            // Twelve white circles evenly distributed around the circle
            // Each circle is positioned at 30-degree intervals (360° / 12 = 30°)
            
            // Circle 1: Top (0°)
            Circle()
                .fill(Color.white)
                .frame(width: circleSize, height: circleSize)
                .offset(x: 0, y: -offsetRadius)
            
            // Circle 2: 30°
            Circle()
                .fill(Color.white)
                .frame(width: circleSize, height: circleSize)
                .offset(x: offsetRadius * 0.5, y: -offsetRadius * 0.866)
            
            // Circle 3: 60°
            Circle()
                .fill(Color.white)
                .frame(width: circleSize, height: circleSize)
                .offset(x: offsetRadius * 0.866, y: -offsetRadius * 0.5)
            
            // Circle 4: 90° (Right)
            Circle()
                .fill(Color.white)
                .frame(width: circleSize, height: circleSize)
                .offset(x: offsetRadius, y: 0)
            
            // Circle 5: 120°
            Circle()
                .fill(Color.white)
                .frame(width: circleSize, height: circleSize)
                .offset(x: offsetRadius * 0.866, y: offsetRadius * 0.5)
            
            // Circle 6: 150°
            Circle()
                .fill(Color.white)
                .frame(width: circleSize, height: circleSize)
                .offset(x: offsetRadius * 0.5, y: offsetRadius * 0.866)
            
            // Circle 7: 180° (Bottom)
            Circle()
                .fill(Color.white)
                .frame(width: circleSize, height: circleSize)
                .offset(x: 0, y: offsetRadius)
            
            // Circle 8: 210°
            Circle()
                .fill(Color.white)
                .frame(width: circleSize, height: circleSize)
                .offset(x: -offsetRadius * 0.5, y: offsetRadius * 0.866)
            
            // Circle 9: 240°
            Circle()
                .fill(Color.white)
                .frame(width: circleSize, height: circleSize)
                .offset(x: -offsetRadius * 0.866, y: offsetRadius * 0.5)
            
            // Circle 10: 270° (Left)
            Circle()
                .fill(Color.white)
                .frame(width: circleSize, height: circleSize)
                .offset(x: -offsetRadius, y: 0)
            
            // Circle 11: 300°
            Circle()
                .fill(Color.white)
                .frame(width: circleSize, height: circleSize)
                .offset(x: -offsetRadius * 0.866, y: -offsetRadius * 0.5)
            
            // Circle 12: 330°
            Circle()
                .fill(Color.white)
                .frame(width: circleSize, height: circleSize)
                .offset(x: -offsetRadius * 0.5, y: -offsetRadius * 0.866)
            
//            // Outer white circle
//            Circle()
//                .fill(Color.white)
//                .frame(width: 205, height: 205)
//            
//            // Inner black circle
//            Circle()
//                .fill(Color.black)
//                .frame(width: 203, height: 203)
       }
    }
}

#Preview {
    ZStack {
 BackgroundView()
        ScallopedCircle()
    }
}
