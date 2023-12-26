//  UserInfoView.swift

import SwiftUI

struct UserInfoView: View {
    @State private var height: String = ""
    @EnvironmentObject var viewModel: HealthDataViewModel

    var body: some View {
        VStack {
            HStack {
                Spacer()
                VStack(alignment: .leading) {
                    Text("最新の体重")
                        .font(.headline)
                    Text("\(viewModel.latestHealthData.weight, specifier: "%.2f") kg")
                        .font(.title)
                }
                Spacer()
                VStack(alignment: .leading) {
                    Text("最新のBMI")
                        .font(.headline)
                    Text("\(viewModel.calculateBMI(), specifier: "%.2f")")
                        .font(.title)
                }
                Spacer()
            }
            .padding()
            
            VStack(alignment: .leading) {
                Text("現在の身長")
                    .font(.headline)
                Text("\(viewModel.userHeight, specifier: "%.1f") cm")
                    .font(.title)
            }
            
            CustomTextField(
                placeholderText: "　身長を変更(cm)",
                foregroundColor: .white,
                placeholderColor: .white.opacity(0.6),
                text: $height,
                keyboardType: .decimalPad
            )
            Button("更新") {
                if let heightValue = Double(height) {
                    viewModel.userHeight = heightValue
                    UserSettingsManager.shared.saveHeight(height: heightValue)
                }
            }
            .buttonStyle(DarkButtonStyle())
            Spacer()
        }
        .padding(.top, 20)
        .padding()
        .background(Color(red: 44 / 255, green: 44 / 255, blue: 46 / 255))
        .foregroundColor(.white)
    }
}
