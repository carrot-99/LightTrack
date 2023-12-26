//  SettingsView.swift

import SwiftUI

struct SettingsView: View {
    @State private var height: String = "\(UserSettingsManager.shared.fetchHeight())"
    @EnvironmentObject var viewModel: HealthDataViewModel

    var body: some View {
        VStack {
            Spacer()
            NavigationLink(destination: UserInfoView().environmentObject(HealthDataViewModel())) {
                Text("ユーザ情報")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(10)
            }
            NavigationLink(destination: TermsView()) {
                Text("利用規約")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(10)
            }
            NavigationLink(destination: PrivacyPolicyView()) {
                Text("プライバシーポリシー")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(10)
            }
            Spacer()
        }
        .padding()
        .navigationBarTitle("設定", displayMode: .inline)
        .background(Color(red: 44 / 255, green: 44 / 255, blue: 46 / 255))
        .navigationViewStyle(StackNavigationViewStyle())
        .foregroundColor(.white)
    }
}
