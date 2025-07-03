////
////  BannerAdView.swift
////  RoundabeatMetronome
////
////  Created by Jessica Estes on 7/2/25.
////
//import SwiftUI
//import GoogleMobileAds
//
//struct BannerAdView: UIViewRepresentable {
//    var adUnitID: String
//
//    func makeUIView(context: Context) -> BannerView {
//        let banner = BannerView(adSize: AdSizeBanner)
//        banner.adUnitID = adUnitID
//        banner.rootViewController = UIApplication.shared.windows.first?.rootViewController
//        banner.load(GADRequest())
//        return banner
//    }
//
//    func updateUIView(_ uiView: BannerView, context: Context) {}
//}
//
//#Preview {
//    BannerAdView()
//}
