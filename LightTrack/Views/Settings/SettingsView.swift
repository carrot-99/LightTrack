//  SettingsView.swift

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var viewModel: HealthDataViewModel
    @State private var exportURL: URL?

    var body: some View {
        NavigationStack {
            List {
                Section("プロフィール") {
                    NavigationLink {
                        UserInfoView()
                    } label: {
                        LabeledContent {
                            Text("\(NumberInput.format(viewModel.userHeight)) cm")
                        } label: {
                            Label("身長・目標体重", systemImage: "person.fill")
                        }
                    }
                }

                Section {
                    if let exportURL {
                        ShareLink(item: exportURL) {
                            Label("CSV で書き出す", systemImage: "square.and.arrow.up")
                        }
                    }
                } header: {
                    Text("データ")
                } footer: {
                    Text("\(viewModel.records.count) 件の記録を CSV 形式で共有・保存できます。")
                }

                Section("このアプリについて") {
                    NavigationLink {
                        TermsView()
                    } label: {
                        Label("利用規約", systemImage: "doc.text")
                    }
                    NavigationLink {
                        PrivacyPolicyView()
                    } label: {
                        Label("プライバシーポリシー", systemImage: "hand.raised")
                    }
                    if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                        LabeledContent("バージョン", value: version)
                    }
                }
            }
            .navigationTitle("設定")
            .onAppear { exportURL = viewModel.exportCSV() }
            .onChange(of: viewModel.records) { _ in exportURL = viewModel.exportCSV() }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(HealthDataViewModel.preview)
}
