//
//  RoundabeatMetronomeApp.swift
//  RoundabeatMetronome
//
//  Created by Jessica Estes on 4/13/25.
//

import SwiftUI

@main
struct RoundabeatMetronomeApp: App {
    
    @StateObject private var metronome = MetronomeEngine()
    
    var body: some Scene {
        WindowGroup {
            ContentView(metronome: metronome)
        }
    }
}
