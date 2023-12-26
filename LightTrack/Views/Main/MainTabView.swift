// MainTabView.swift

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var viewModel: HealthDataViewModel
    
    var body: some View {
        TabView {
            // グラフ画面タブ
            GraphView()
                .environmentObject(HealthDataViewModel())
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("グラフ")
                }
            
            // ホーム画面タブ
            HomeView()
                .environmentObject(HealthDataViewModel())
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("ホーム")
                }
            
            // 履歴画面タブ
            HistoryView()
                .environmentObject(HealthDataViewModel())
                .tabItem {
                    Image(systemName: "clock.fill")
                    Text("履歴")
                }
            
            // 設定画面タブ
            SettingsView()
                .environmentObject(HealthDataViewModel())
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("設定")
                }
        }
        .padding(.bottom, 50)
        .tabViewStyle(DefaultTabViewStyle())
        .foregroundColor(.white)
        .overlay(
            VStack {
                Spacer()
                AdMobBannerView()
                    .frame(width: UIScreen.main.bounds.width, height: 50)
                    .background(Color.gray.opacity(0.1))
            },
            alignment: .bottom
        )
        .navigationBarBackButtonHidden(true)
    }
}
