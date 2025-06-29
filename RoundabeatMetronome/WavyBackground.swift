import SwiftUI

struct WavyBackground: View {


        let columns = 150
        let rows = 200
        let dotSize: CGFloat = 8
        let spacing: CGFloat = 12
        
        var body: some View {
            ZStack {
    
                
                // Speaker grille dots
                VStack(spacing: spacing) {
                    ForEach(0..<rows, id: \.self) { row in
                        HStack(spacing: spacing) {
                            ForEach(0..<columns, id: \.self) { column in
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color.white.opacity(0.9),
                                                Color.gray.opacity(0.6)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                  
                                    .overlay(
                                        Circle()
                                            .stroke(Color.black.opacity(0.3), lineWidth: 0.5)
                                    )
                                    .shadow(
                                        color: .black.opacity(0.4),
                                        radius: 1,
                                        x: 1,
                                        y: 1
                                    )
                                    .scaleEffect(randomScale(row: row, column: column))
                            }
                        }
                    }
                }
       
            }
            .background(Color.gray.opacity(0.1))
  
            
            
        }
        
        // Add slight random variation to dot sizes for more realistic texture
        private func randomScale(row: Int, column: Int) -> CGFloat {
            let seed = Double(row * columns + column)
            let random = sin(seed * 12.9898) * 43758.5453
            let normalizedRandom = abs(random.truncatingRemainder(dividingBy: 1.0))
            return 0.8 + (normalizedRandom * 0.4) // Scale between 0.8 and 1.2
        }
    }

 


 #Preview {
    WavyBackground()
}
