//  LightTrackApp.swift

import SwiftUI

@main
struct LightTrackApp: App {
    @StateObject private var viewModel: HealthDataViewModel

    init() {
        #if DEBUG
        // 起動引数 -seedSampleData でサンプルデータを投入（記録が空のときのみ）
        if ProcessInfo.processInfo.arguments.contains("-seedSampleData"),
           DataManager.shared.fetchHealthData().isEmpty {
            HealthDataViewModel.seedSampleData(into: .shared)
        }
        #endif
        _viewModel = StateObject(wrappedValue: HealthDataViewModel())
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}
