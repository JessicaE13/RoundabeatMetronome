
import SwiftUI
import GoogleMobileAds
import RevenueCat
import RevenueCatUI

@main
struct RoundabeatMetronomeApp: App {
    
    init () {
        Purchases.logLevel = .debug
        Purchases.configure(
            with: Configuration.Builder(withAPIKey: Constants.apiKey)
                .with(storeKitVersion: StoreKitVersion.storeKit2)
                .build()
        )
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .presentPaywallIfNeeded(requiredEntitlementIdentifier: "Pro")
                .task {
                    do {
                        UserViewModel.shared.offerings = try await Purchases.shared.offerings()
                    } catch {
                        print("Error fetching offerings: \(error)")
                    }
                }
        }
    }
}
