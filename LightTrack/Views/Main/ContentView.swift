// ContentView.swift

import SwiftUI

/// 初回起動フロー（規約同意 → 身長入力）とメイン画面の切り替え
struct ContentView: View {
    @EnvironmentObject private var viewModel: HealthDataViewModel
    @AppStorage("hasAgreedToTerms") private var hasAgreedToTerms = false
    /// 身長入力が完了しているか（旧バージョンとの互換のためキー名は維持）
    @AppStorage("hasLaunchedBefore") private var hasCompletedOnboarding = false

    var body: some View {
        Group {
            if !hasAgreedToTerms {
                TermsAndPrivacyAgreementView {
                    hasAgreedToTerms = true
                }
            } else if !hasCompletedOnboarding {
                InitialHeightView { height in
                    viewModel.updateHeight(height)
                    hasCompletedOnboarding = true
                }
            } else {
                MainTabView()
            }
        }
        .animation(.default, value: hasAgreedToTerms)
        .animation(.default, value: hasCompletedOnboarding)
    }
}

#Preview {
    ContentView()
        .environmentObject(HealthDataViewModel.preview)
}
