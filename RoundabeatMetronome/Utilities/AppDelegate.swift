//
//  AppDelegate.swift
//  RoundabeatMetronome
//
//  Created by Jessica Estes on 4/14/25.
//

import Foundation
import UIKit
import AVFoundation


// MARK: - App Delegate
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        setupAudioSession()
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Reinitialize audio session when app becomes active
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            
            // Use .playback category for best audio performance
            try audioSession.setCategory(.playback, mode: .default)
            
            // Request a specific buffer duration for lower latency
            try audioSession.setPreferredIOBufferDuration(0.005) // 5ms buffer
            
            // Set sample rate to standard high quality audio
            try audioSession.setPreferredSampleRate(44100)
            
            // Activate the session
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            
            print("✅ Audio session configured successfully")
            print("  - Buffer duration: \(audioSession.ioBufferDuration) seconds")
            print("  - Sample rate: \(audioSession.sampleRate) Hz")
        } catch {
            print("❌ Failed to set up audio session: \(error)")
        }
    }
}
