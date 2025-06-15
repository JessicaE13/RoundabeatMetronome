import AVFoundation

class ExactSnapPlayer {
    private let engine = AVAudioEngine()
    private let playerNode = AVAudioPlayerNode()
    private let format = AVAudioFormat(standardFormatWithSampleRate: 24000, channels: 1)!
    
    init() {
        engine.attach(playerNode)
        engine.connect(playerNode, to: engine.mainMixerNode, format: format)
        try? engine.start()
    }

    func playSnap() {
        let frameCount = AVAudioFrameCount(snapWaveform.count)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return }
        buffer.frameLength = frameCount
        
        let channelData = buffer.floatChannelData![0]
        for i in 0..<snapWaveform.count {
            channelData[i] = snapWaveform[i]
        }
        
        playerNode.stop()
        playerNode.scheduleBuffer(buffer, at: nil, options: .interrupts, completionHandler: nil)
        playerNode.play()
    }
}

import SwiftUI

struct SwiftUIView: View {
    let snapPlayer = ExactSnapPlayer()
    
    var body: some View {
        Button("Play Exact Snap") {
            snapPlayer.playSnap()
        }
        .padding()
    }
}


#Preview {
    SwiftUIView()
}
