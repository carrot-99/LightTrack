//  HealthDataViewModel.swift

import Foundation

/// アプリ全体で 1 つだけ生成し、Environment で共有する
@MainActor
final class HealthDataViewModel: ObservableObject {
    /// 新しい順に並んだ測定記録
    @Published private(set) var records: [HealthData] = []
    @Published private(set) var userHeight: Double
    @Published var goalWeight: Double? {
        didSet { saveGoalWeight() }
    }

    private let dataManager: DataManager
    private let settingsManager: UserSettingsManager
    private let defaults: UserDefaults
    private static let goalWeightKey = "goalWeight"

    init(
        dataManager: DataManager = .shared,
        settingsManager: UserSettingsManager = .shared,
        defaults: UserDefaults = .standard
    ) {
        self.dataManager = dataManager
        self.settingsManager = settingsManager
        self.defaults = defaults
        self.userHeight = settingsManager.fetchHeight()
        let goal = defaults.double(forKey: Self.goalWeightKey)
        self.goalWeight = goal > 0 ? goal : nil
        reload()
    }

    // MARK: - 最新値

    var latest: HealthData? { records.first }
    var previous: HealthData? { records.dropFirst().first }

    var latestBMI: Double? { latest?.bmi(heightCm: userHeight) }

    /// 前回記録との体重差
    var weightChangeFromPrevious: Double? {
        guard let latest, let previous else { return nil }
        return latest.weight - previous.weight
    }

    /// 目標体重までの残り（マイナスなら減量が必要）
    var remainingToGoal: Double? {
        guard let latest, let goalWeight else { return nil }
        return goalWeight - latest.weight
    }

    var latestBodyFat: Double? {
        records.first(where: { $0.bodyFatPercentage != nil })?.bodyFatPercentage
    }

    // MARK: - CRUD

    func reload() {
        records = dataManager.fetchHealthData()
    }

    @discardableResult
    func addRecord(date: Date, weight: Double, bodyFatPercentage: Double?) -> Bool {
        let success = dataManager.saveHealthData(date: date, weight: weight, bodyFatPercentage: bodyFatPercentage)
        reload()
        return success
    }

    @discardableResult
    func updateRecord(_ record: HealthData, date: Date, weight: Double, bodyFatPercentage: Double?) -> Bool {
        let success = dataManager.updateHealthData(record, date: date, weight: weight, bodyFatPercentage: bodyFatPercentage)
        reload()
        return success
    }

    func deleteRecords(_ targets: [HealthData]) {
        dataManager.deleteHealthData(targets)
        reload()
    }

    func updateHeight(_ height: Double) {
        settingsManager.saveHeight(height)
        userHeight = height
    }

    // MARK: - グラフ

    /// 指定期間の記録（古い順・1日1件＝その日の最後の記録）
    func dailyRecords(in period: ChartPeriod) -> [HealthData] {
        let start = period.startDate()
        let calendar = Calendar.current
        var seenDays = Set<Date>()
        var result: [HealthData] = []
        // records は新しい順なので、各日で最初に出てくるものがその日の最新
        for record in records {
            if let start, record.date < start { break }
            let day = calendar.startOfDay(for: record.date)
            if seenDays.insert(day).inserted {
                result.append(record)
            }
        }
        return result.reversed()
    }

    func chartPoints(metric: ChartMetric, period: ChartPeriod) -> [ChartPoint] {
        dailyRecords(in: period).compactMap { record in
            let value: Double?
            switch metric {
            case .weight: value = record.weight
            case .bodyFat: value = record.bodyFatPercentage
            case .bmi: value = record.bmi(heightCm: userHeight)
            }
            return value.map { ChartPoint(date: Calendar.current.startOfDay(for: record.date), value: $0) }
        }
    }

    // MARK: - エクスポート

    /// CSV ファイルを一時ディレクトリに書き出して URL を返す
    func exportCSV() -> URL? {
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = .current
        formatter.formatOptions = [.withFullDate, .withTime, .withColonSeparatorInTime, .withDashSeparatorInDate, .withSpaceBetweenDateAndTime]

        var lines = ["日時,体重(kg),体脂肪率(%),BMI"]
        for record in records.reversed() {
            let bodyFat = record.bodyFatPercentage.map { NumberInput.format($0) } ?? ""
            let bmi = record.bmi(heightCm: userHeight).map { NumberInput.format($0) } ?? ""
            lines.append("\(formatter.string(from: record.date)),\(NumberInput.format(record.weight, digits: 2)),\(bodyFat),\(bmi)")
        }

        let url = FileManager.default.temporaryDirectory.appendingPathComponent("LightTrack.csv")
        do {
            // Excel で文字化けしないよう BOM 付き UTF-8 で書き出す
            let data = Data([0xEF, 0xBB, 0xBF]) + Data(lines.joined(separator: "\n").utf8)
            try data.write(to: url, options: .atomic)
            return url
        } catch {
            print("Failed to export CSV: \(error)")
            return nil
        }
    }

    // MARK: - Private

    private func saveGoalWeight() {
        if let goalWeight {
            defaults.set(goalWeight, forKey: Self.goalWeightKey)
        } else {
            defaults.removeObject(forKey: Self.goalWeightKey)
        }
    }
}

// MARK: - Preview / サンプルデータ

extension HealthDataViewModel {
    /// 開発用のサンプルデータを投入する
    static func seedSampleData(into manager: DataManager, days: Int = 120) {
        let calendar = Calendar.current
        for offset in 0..<days {
            let date = calendar.date(byAdding: .day, value: -offset, to: Date())!
            manager.saveHealthData(
                date: date,
                weight: 68 + sin(Double(offset) / 4) + Double(offset) * 0.05,
                bodyFatPercentage: offset.isMultiple(of: 3) ? 21 + Double(offset) * 0.03 : nil
            )
        }
    }

    static var preview: HealthDataViewModel {
        let manager = DataManager(inMemory: true)
        seedSampleData(into: manager, days: 40)
        return HealthDataViewModel(
            dataManager: manager,
            settingsManager: UserSettingsManager(dataManager: manager),
            defaults: UserDefaults(suiteName: "preview") ?? .standard
        )
    }
}
