//
//  RoundabeatMetronomeApp.swift
//  RoundabeatMetronome
//
//  Created by Jessica Estes on 4/13/25.
//

import SwiftUI

@main
struct RoundabeatMetronomeApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(metronome: metronome)
        }
    }
}
