import GoogleMobileAds

class BannerAdsManager: NSObject, FullScreenContentDelegate, ObservableObject {
    
    // Properties
    @Published var interstitialAdLoaded: Bool = false
    var interstitialAd: InterstitialAd?
    
    override init() {
        super.init()
    }
    
    // Load InterstitialAd
    func loadInterstitialAd() {
        InterstitialAd.load(with: "ca-app-pub-3227610059153215/2868486663", request: Request()) { [weak self] ad, error in
            guard let self = self else { return }
            if let error = error {
                print("🔴: \(error.localizedDescription)")
                self.interstitialAdLoaded = false
                return
            }
            print("🟢: Loading succeeded")
            self.interstitialAdLoaded = true
            self.interstitialAd = ad
            self.interstitialAd?.fullScreenContentDelegate = self
        }
    }
    
    // Display InterstitialAd
    func displayInterstitialAd() {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        guard let root = windowScene?.windows.first?.rootViewController else {
            return
        }
        if let ad = interstitialAd {
            ad.present(from: root)
            self.interstitialAdLoaded = false
        } else {
            print("🔵: Ad wasn't ready")
            self.interstitialAdLoaded = false
            self.loadInterstitialAd()
        }
    }
    
    // MARK: - FullScreenContentDelegate
    
    // Failure notification
    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWith error: Error) {
        print("🟡: Failed to display interstitial ad")
        self.loadInterstitialAd()
    }
    
    // Will present notification
    func adWillPresentFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("🤩: Displayed an interstitial ad")
        self.interstitialAdLoaded = false
    }
    
    // Close notification
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("😔: Interstitial ad closed")
    }
}
