// MainTabView.swift

import SwiftUI

struct MainTabView: View {
    enum Tab: Hashable {
        case home, graph, history, settings
    }

    @State private var selection: Tab = .home

    var body: some View {
        TabView(selection: $selection) {
            HomeView()
                .adBanner()
                .tabItem { Label("ホーム", systemImage: "house.fill") }
                .tag(Tab.home)

            GraphView()
                .adBanner()
                .tabItem { Label("グラフ", systemImage: "chart.xyaxis.line") }
                .tag(Tab.graph)

            HistoryView()
                .adBanner()
                .tabItem { Label("履歴", systemImage: "list.bullet.rectangle") }
                .tag(Tab.history)

            SettingsView()
                .adBanner()
                .tabItem { Label("設定", systemImage: "gearshape.fill") }
                .tag(Tab.settings)
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(HealthDataViewModel.preview)
}
