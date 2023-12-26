//  RecordDetailView.swift

import SwiftUI

struct RecordDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewModel: HealthDataViewModel
    var record: HealthData
    @State private var inputWeight: String = ""
    @State private var inputBodyFat: String = ""
    @State private var selectedDate: Date = Date()
    
    var body: some View {
        VStack {
            DatePicker("測定日時", selection: $selectedDate)
                .padding()
            
            CustomTextField(
                placeholderText: "　体重 (kg)",
                foregroundColor: .blue,
                placeholderColor: .white.opacity(0.6),
                text: $inputWeight,
                keyboardType: .decimalPad
            )
            .padding()
            
            CustomTextField(
                placeholderText: "　体脂肪率 (%)",
                foregroundColor: .blue,
                placeholderColor: .white.opacity(0.6),
                text: $inputBodyFat,
                keyboardType: .decimalPad
            )
            .padding()
            
            Button("保存") {
                if let newWeight = Double(inputWeight), let newBodyFat = Double(inputBodyFat) {
                    viewModel.updateRecord(
                        record: record,
                        newWeight: newWeight,
                        newBodyFat: newBodyFat,
                        newDate: selectedDate
                    )
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .buttonStyle(DarkButtonStyle())
        }
        .onAppear{
            print("record:\(record)")
            inputWeight = String(record.weight)
            if let bodyFat = record.bodyFatPercentage {
                inputBodyFat = String(bodyFat)
            }
            selectedDate = record.date
        }
        .foregroundColor(.blue)
    }
}
