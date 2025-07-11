
import SwiftUI
import GoogleMobileAds
import RevenueCat
import RevenueCatUI

@main
struct RoundabeatMetronomeApp: App {

    var body: some Scene {
        WindowGroup {
            ContentView()
                .presentPaywallIfNeeded(requiredEntitlementIdentifier: "Pro")
        }
    }
}
