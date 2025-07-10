//
//  RoundabeatMetronomeApp.swift
//  RoundabeatMetronome
//
//  Created by Jessica Estes on 4/13/25.
//

import SwiftUI
import GoogleMobileAds


class AppDelegate:NSObject,UIApplicationDelegate{
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        GADMobileAds.sharedInstance().start()
        return true
    }
}



@main
struct RoundabeatMetronomeApp: App {
    
   // @StateObject private var metronome = MetronomeEngine()
    
    var body: some Scene {
        WindowGroup {
           ContentView()
                .environmentObject(InterstitialAdManager)
        }
    }
}
