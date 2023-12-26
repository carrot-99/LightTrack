// ContentView.swift

import SwiftUI

struct ContentView: View {
    @AppStorage("hasLaunchedBefore") var hasLaunchedBefore: Bool = false
    @EnvironmentObject var viewModel: HealthDataViewModel
    @State private var isShowingTerms = true
    @State private var hasAgreedToTerms = UserDefaults.standard.bool(forKey: "hasAgreedToTerms")

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                if hasAgreedToTerms {
                    if !hasLaunchedBefore {
                        InitialHeightView { newHeight in
                            UserSettingsManager.shared.saveHeight(height: newHeight)
                            self.hasLaunchedBefore = true
                        }
                        .environmentObject(HealthDataViewModel())
                    } else {
                        InitialView()
                            .environmentObject(HealthDataViewModel())
                    }
                    
                    AdMobBannerView()
                        .frame(width: UIScreen.main.bounds.width, height: 50)
                        .background(Color.gray.opacity(0.1))
                } else {
                    TermsAndPrivacyAgreementView(isShowingTerms: $isShowingTerms, hasAgreedToTerms: $hasAgreedToTerms)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
