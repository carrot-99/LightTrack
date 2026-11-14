//  AdMobBannerView.swift

import SwiftUI
import GoogleMobileAds

struct AdMobBannerView: UIViewRepresentable {
    /// Google 公式のテスト用バナー ID（開発中に本番広告を表示するとポリシー違反になるため）
    private static let testAdUnitID = "ca-app-pub-3940256099942544/2934735716"

    private let adUnitID: String?

    init() {
        #if DEBUG
        adUnitID = Self.testAdUnitID
        #else
        adUnitID = Bundle.main.infoDictionary?["AdBannerUnitID"] as? String
        #endif
    }

    func makeUIView(context: Context) -> GADBannerView {
        let width = UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.screen.bounds.width }
            .first ?? 320
        let banner = GADBannerView(adSize: GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(width))
        guard let adUnitID else {
            // ID が無い場合はクラッシュさせず、広告なしで表示を続ける
            print("AdBannerUnitID not found in Info.plist")
            return banner
        }
        banner.adUnitID = adUnitID

        let request = GADRequest()
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            request.scene = windowScene
            banner.rootViewController = windowScene.windows.first(where: \.isKeyWindow)?.rootViewController
        }
        banner.load(request)
        return banner
    }

    func updateUIView(_ uiView: GADBannerView, context: Context) {}
}
