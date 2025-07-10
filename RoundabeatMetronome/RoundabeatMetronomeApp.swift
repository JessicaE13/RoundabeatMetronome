
import SwiftUI
import GoogleMobileAds

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        GADMobileAds.sharedInstance().start { status in
        }
        return true
    }
}

@main
struct RoundabeatMetronomeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @StateObject private var bannerAdsManager = BannerAdsManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(bannerAdsManager)
        }
    }
}
