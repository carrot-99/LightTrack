//  InitialView.swift

import SwiftUI

struct InitialView: View {
    @EnvironmentObject var viewModel: HealthDataViewModel
    @State private var userHeight: Double = 1.75
    @State private var inputWeight: String = ""
    @State private var inputBodyFat: String = ""
    @State private var selectedDate: Date = Date()
    @State private var showMainTabView = false
    
    var body: some View {
        VStack {
                HomeView()
                    .environmentObject(viewModel)
            
            Spacer()
            
            Button("入力を終了する") {
                showMainTabView = true
            }
            .buttonStyle(DarkButtonStyle(backgroundColor: Color.green))
            
            NavigationLink(destination: MainTabView().environmentObject(HealthDataViewModel()), isActive: $showMainTabView) {
                EmptyView()
            }
            
            Spacer()
            .padding(.horizontal, 40)
        }
        .padding()
        .background(Color(red: 44 / 255, green: 44 / 255, blue: 46 / 255))
        .foregroundColor(.white)
        .onAppear {
            viewModel.fetchLatestHealthData()
        }
    }
}

struct DarkButtonStyle: ButtonStyle {
    var backgroundColor: Color = .blue

    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding()
            .background(backgroundColor)
            .foregroundColor(.white)
            .cornerRadius(5)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}
