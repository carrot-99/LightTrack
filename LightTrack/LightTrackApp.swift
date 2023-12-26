//  LightTrackApp.swift

import SwiftUI

@main
struct LightTrackApp: App {
    var viewModel = HealthDataViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}
