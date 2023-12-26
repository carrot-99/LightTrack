//  HomeView.swift

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: HealthDataViewModel
    @State private var inputWeight: String = ""
    @State private var inputBodyFat: String = ""
    @State private var selectedDate: Date = Date()
    
    var body: some View {
        ZStack {
            Color(red: 44 / 255, green: 44 / 255, blue: 46 / 255)
                  
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
                
                Divider()
                
                // 測定日時の入力
                DatePicker("測定日時:", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                    .padding()
                    .colorScheme(.dark)
                
                CustomTextField(
                    placeholderText: "　体重を入力してください",
                    foregroundColor: .white,
                    placeholderColor: .white.opacity(0.6),
                    text: $inputWeight,
                    keyboardType: .decimalPad
                )
                
                CustomTextField(
                    placeholderText: "　体脂肪率を入力してください (%)（任意）",
                    foregroundColor: .white,
                    placeholderColor: .white.opacity(0.6), 
                    text: $inputBodyFat,
                    keyboardType: .decimalPad
                )
                
                // 記録ボタン
                Button("記録する") {
                    if let newWeight = Double(inputWeight), !inputWeight.isEmpty {
                        let bodyFat = Double(inputBodyFat)
                        viewModel.addNewWeight(
                            weight: newWeight,
                            date: selectedDate,
                            bodyFatPercentage: bodyFat
                        )
                        inputWeight = ""
                        inputBodyFat = ""
                    }
                }
                .buttonStyle(DarkButtonStyle())
                
                Spacer()
            }
            .foregroundColor(.white)
            .padding()
        }
    }
}
