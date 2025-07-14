import SwiftUI

struct ParabolaPetal: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        
        let midX = width / 2
        
        for x in stride(from: -midX, through: midX, by: 1) {
            let normalizedX = x / midX  // range: -1 to 1
            let y = 1 - (normalizedX * normalizedX)
            let point = CGPoint(x: midX + x, y: height * (1 - y))
            
            if x == -midX {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        
        return path
    }
}

struct CircularParabolaBorderView: View {
    let petalCount = 30
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray, lineWidth: 1)
                .frame(width: 340, height: 340)
            
            Circle()
                .fill(Color.gray)
                .opacity(0.2)
                .padding(20)
                .frame(width: 300, height: 300)
            
            ForEach(0..<petalCount, id: \.self) { i in
                ParabolaPetal()
                    .stroke(Color.gray, lineWidth: 1.5)
                    .frame(width: 20, height: 20)
                    .scaleEffect(x: 1, y: -1) // this flips the petal upside down
                    .offset(y: -150)
                    .rotationEffect(.degrees(Double(i) * (360.0 / Double(petalCount))))
            }
        }
        .frame(width: 340, height: 340)
        .background(Color.white)
    }
}


#Preview {
    //ParabolaPetal()
    CircularParabolaBorderView()
}
