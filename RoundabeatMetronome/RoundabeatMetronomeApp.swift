
import SwiftUI
import GoogleMobileAds
import RevenueCat

@main
struct RoundabeatMetronomeApp: App {
    init() {
        Purchases.configure(withAPIKey: "appl_bjboiZRJoRJDLDsmrANaGgsXWzR")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
            
        }
    }
}
