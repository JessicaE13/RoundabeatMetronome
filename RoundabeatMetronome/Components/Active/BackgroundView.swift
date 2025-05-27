import SwiftUI

struct BackgroundView: View {
    var body: some View {
        GeometryReader { geometry in
            //  VStack(spacing: 0) {
            // Top half with mesh gradient
            ZStack {
                MeshGradient(
                    width: 3,
                    height: 3,
                    points: [
                        [0.0, 0.0], [0.4, 0.0], [1.0, 0.0],
                        [0.0, 0.4], [0.7, 0.6], [1.0, 0.5],
                        [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
                    ],
                    colors: [
                        Color(red: 229/255, green: 235/255, blue: 219/255),
                        Color(red: 193/255, green: 168/255, blue: 190/255),
                        Color(red: 221/255, green: 185/255, blue: 198/255),
                        Color(red: 115/255, green: 86/255, blue: 128/255),
                        Color(red: 166/255, green: 119/255, blue: 154/255),
                        Color(red: 222/255, green: 169/255, blue: 193/255),
                        Color(red: 111/255, green: 68/255, blue: 115/255),
                        Color(red: 139/255, green: 98/255, blue: 117/255),
                        Color(red: 187/255, green: 138/255, blue: 144/255)
                    ]
                )
                .overlay(
                    Color.black.opacity(0.2) // gentle matte layer
                )
            }
            
            
            // Bottom half - empty/transparent
            VStack{
            //    Spacer()
                
                Rectangle()
                    .fill(Color.black.opacity(0.6))
                  //  .frame(height: geometry.size.height / 1.5)
            }
        }
        .ignoresSafeArea(.all)
    }
}

#Preview {
    BackgroundView()
}
