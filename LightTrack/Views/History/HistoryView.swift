//  HistoryView.swift

import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var viewModel: HealthDataViewModel
    @State private var isLoading = true

    var body: some View {
        List {
            ForEach(viewModel.healthDataRecords, id: \.date) { record in
                recordRow(record)
            }
            .onDelete(perform: deleteRecord)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                isLoading = false
            }
            setupNavigationBar()
        }
    }
    
    private func recordRow(_ record: HealthData) -> some View {
        NavigationLink(destination: RecordDetailView(record: record).environmentObject(viewModel)) {
            HStack {
                VStack(alignment: .leading) {
                    Text(record.formattedDateTime)
                        .font(.caption)
                    Text("体重: \(record.weight, specifier: "%.1f") kg")
                        .font(.headline)
                    if let bodyFat = record.bodyFatPercentage, bodyFat > 0 {
                        Text("体脂肪率: \(bodyFat, specifier: "%.1f")%")
                    }
                }
                Spacer()
            }
            .padding()
            .background(Color(red: 44 / 255, green: 44 / 255, blue: 46 / 255))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.white.opacity(0.25), lineWidth: 1)
            )
            .shadow(color: Color.gray.opacity(0.8), radius: 5, x: 0, y: 2)
            .padding(.vertical, 4)
        }
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }
    
    private func setupNavigationBar() {
        UINavigationBar.appearance().backgroundColor = UIColor(red: 44 / 255, green: 44 / 255, blue: 46 / 255, alpha: 1)
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().tintColor = .blue
        UINavigationBar.appearance().isTranslucent = false
    }
    
    private func deleteRecord(at offsets: IndexSet) {
        for index in offsets {
            let record = viewModel.healthDataRecords[index]
            viewModel.deleteRecord(record: record)
        }
    }
}
