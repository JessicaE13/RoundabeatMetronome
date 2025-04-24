//
//  NoiseTextureView.swift
//  RoundabeatMetronome
//
//  Created by Jessica Estes on 4/24/25.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

struct NoiseTextureView: View {
    @State private var noiseImage: UIImage? = nil
    
    var body: some View {
        RoundedRectangle(cornerRadius: 7)
            .fill(.shadow(.inner(color: .black, radius: 2, y: 1)))
            .overlay {
                if let noiseImage {
                    Image(uiImage: noiseImage)
                        .resizable()
                        .blendMode(.overlay)
                        .opacity(0.3)
                        .clipShape(RoundedRectangle(cornerRadius: 7))
                }
            }
            .foregroundStyle(Color.black.opacity(0.2))
            .frame(width: 375, height: 155)
            .onAppear {
                generateNoiseTexture()
            }
    }
    
    func generateNoiseTexture() {
        let context = CIContext()
        let filter = CIFilter.randomGenerator()
        
        // Get output image from filter
        guard let outputImage = filter.outputImage else { return }
        
        // Scale the noise texture to match our view size
        let scaledImage = outputImage.cropped(to: CGRect(x: 0, y: 0, width: 375, height: 155))
        
        // Convert CIImage to UIImage
        if let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) {
            noiseImage = UIImage(cgImage: cgImage)
        }
    }
}

#Preview {
    NoiseTextureView()
}
