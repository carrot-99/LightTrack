//  TermsAndPrivacyAgreementView.swift

import SwiftUI

struct TermsAndPrivacyAgreementView: View {
    var onAgree: () -> Void

    @State private var isShowingTerms = false
    @State private var isShowingPrivacyPolicy = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "scalemass.fill")
                .font(.system(size: 56))
                .foregroundStyle(Color.accentColor)

            VStack(spacing: 8) {
                Text("LightTrack へようこそ")
                    .font(.title2.bold())
                Text("体重・体脂肪率・BMI をシンプルに記録できます。記録したデータはこの端末内にのみ保存されます。")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Text("本アプリでは広告を表示します。ご利用の前に、利用規約とプライバシーポリシーをご確認ください。")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            HStack(spacing: 24) {
                Button("利用規約") { isShowingTerms = true }
                Button("プライバシーポリシー") { isShowingPrivacyPolicy = true }
            }
            .font(.subheadline.weight(.semibold))

            Spacer()

            Button("同意してはじめる", action: onAgree)
                .buttonStyle(PrimaryButtonStyle())
        }
        .padding(24)
        .sheet(isPresented: $isShowingTerms) {
            DocumentSheet(title: "利用規約") { TermsView() }
        }
        .sheet(isPresented: $isShowingPrivacyPolicy) {
            DocumentSheet(title: "プライバシーポリシー") { PrivacyPolicyView() }
        }
    }
}

/// 規約類をシートで表示するためのラッパー
private struct DocumentSheet<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            content
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("閉じる") { dismiss() }
                    }
                }
        }
    }
}

#Preview {
    TermsAndPrivacyAgreementView {}
}
