//import SwiftUI
//
//struct FullDialControl: View {
//    
//    @ObservedObject var metronome: MetronomeEngine
//    
//    var body: some View {
//        
//        
//        
//        GeometryReader { geometry in
//            
//            let dialSize = geometry.size.width * 0.72
//            
//            ZStack{
//                
//                SegmentedCircleView(
//                    metronome: metronome,
//                    diameter: dialSize,
//                    lineWidth: 50
//                )
//           
//            }
//        }
//    }
//}
//
//#Preview {
//    FullDialControl(metronome: MetronomeEngine())
//}
