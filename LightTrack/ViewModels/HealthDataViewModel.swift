//  HealthDataViewModel.swift

import Foundation
import Combine
import SwiftUICharts

class HealthDataViewModel: ObservableObject {
    @Published var latestHealthData: HealthData
    @Published var healthDataRecords: [HealthData] = []
    @Published var actualWeightChartDataPoints: [LineChartDataPoint] = []
    @Published var isLoading = false
    var userHeight: Double
    var weightChartDataPoints: [LineChartDataPoint] {
        let groupedByDay = Dictionary(grouping: healthDataRecords) { $0.date.startOfDay }
        let sortedDates = groupedByDay.keys.sorted()

        var dataPoints: [LineChartDataPoint] = []
        for date in sortedDates {
            if let recordsForDay = groupedByDay[date], let latestRecord = recordsForDay.max(by: { $0.date < $1.date }) {
                let dayLabel = DateFormatter.localizedString(from: latestRecord.date, dateStyle: .medium, timeStyle: .short)
                dataPoints.append(LineChartDataPoint(value: latestRecord.weight, xAxisLabel: dayLabel, description: dayLabel))
            }
        }
        return dataPoints
    }
    
    init() {
        let fetchedRecords = DataManager.shared.fetchHealthData()
        self.healthDataRecords = fetchedRecords
        self.latestHealthData = fetchedRecords.first ?? HealthData(date: Date(), weight: 70.0, bodyFatPercentage: 22.0)
        self.userHeight = UserSettingsManager.shared.fetchHeight()
    }

    func calculateBMI() -> Double {
        return latestHealthData.calculateBMI(height: userHeight)
    }
    
    func fetchLatestHealthData() {
        let fetchedRecords = DataManager.shared.fetchHealthData()
        self.healthDataRecords = fetchedRecords.sorted(by: { $0.date > $1.date })
        if let mostRecent = fetchedRecords.first {
            self.latestHealthData = mostRecent
        }
    }
    
    func addNewWeight(weight: Double, date: Date, bodyFatPercentage: Double?) {
        let newData = HealthData(
            date: date,
            weight: weight,
            bodyFatPercentage: bodyFatPercentage
        )

        healthDataRecords.insert(newData, at: 0)

        if date > latestHealthData.date {
            latestHealthData = newData
        }

        DataManager.shared.saveHealthData(
            date: date,
            weight: weight,
            bodyFatPercentage: bodyFatPercentage
        )
    }
    
    func updateRecord(record: HealthData, newWeight: Double, newBodyFat: Double?, newDate: Date) {
        DataManager.shared.updateHealthData(record: record, newWeight: newWeight, newBodyFat: newBodyFat, newDate: newDate)
        fetchLatestHealthData()
    }
    
    func deleteRecord(record: HealthData) {
        DataManager.shared.deleteHealthData(record: record)
        fetchLatestHealthData()
    }
    
    func generateDataPoints(forPeriod period: Period) -> [LineChartDataPoint] {
        let sortedRecords = healthDataRecords.sorted { $0.date < $1.date }
        let calendar = Calendar.current
        
        // 期間に応じた開始日を取得
        let startDate = calendar.date(byAdding: period.dateComponent, value: period.value, to: Date())!
        let endDate = Date()
        
        var lastValue: Double?
        var dataPoints: [LineChartDataPoint] = []
        
        for date in Date.dates(from: startDate, to: endDate) {
            let dayLabel = DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none)
            if let record = sortedRecords.first(where: { calendar.isDate($0.date, inSameDayAs: date) }) {
                lastValue = record.weight
                dataPoints.append(LineChartDataPoint(value: record.weight, xAxisLabel: dayLabel, description: dayLabel))
            } else if let lastValue = lastValue {
                // データが欠けている日には最後の値を使用
                dataPoints.append(LineChartDataPoint(value: lastValue, xAxisLabel: dayLabel, description: dayLabel))
            }
        }
        
        return dataPoints
    }
    
    var weights: [Double] {
        healthDataRecords.map { $0.weight }
    }
    
    var bmiValues: [Double] {
        healthDataRecords.map { $0.calculateBMI(height: userHeight) }
    }
}

extension HealthDataViewModel {
    func updateDataPoints(forPeriod period: Period) {
        isLoading = true
        DispatchQueue.global(qos: .userInitiated).async {
            sleep(1)  // 時間のかかる処理を模擬

            let newWeightChartDataPoints = self.generateDataPoints(forPeriod: period)

            DispatchQueue.main.async {
                self.actualWeightChartDataPoints = newWeightChartDataPoints
                self.isLoading = false
            }
        }
    }
}

extension Date {
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
}
