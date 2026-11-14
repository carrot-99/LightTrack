//  HealthData.swift

import Foundation
import CoreData

/// 1回分の測定記録
struct HealthData: Identifiable, Equatable {
    /// Core Data 上のオブジェクトID（未保存のプレビュー用データでは nil）
    let objectID: NSManagedObjectID?
    var date: Date
    var weight: Double
    var bodyFatPercentage: Double?

    var id: String {
        objectID?.uriRepresentation().absoluteString ?? "\(date.timeIntervalSince1970)-\(weight)"
    }

    init(objectID: NSManagedObjectID? = nil, date: Date, weight: Double, bodyFatPercentage: Double?) {
        self.objectID = objectID
        self.date = date
        self.weight = weight
        self.bodyFatPercentage = bodyFatPercentage
    }

    func bmi(heightCm: Double) -> Double? {
        BMI.value(weightKg: weight, heightCm: heightCm)
    }
}

extension HealthDataEntity {
    func toHealthData() -> HealthData {
        // 旧バージョンでは体脂肪率未入力を 0 で保存していたため nil に変換する
        let bodyFat = bodyFatPercentage > 0 ? bodyFatPercentage : nil
        return HealthData(
            objectID: objectID,
            date: date ?? Date(),
            weight: weight,
            bodyFatPercentage: bodyFat
        )
    }
}

// MARK: - BMI

enum BMI {
    static func value(weightKg: Double, heightCm: Double) -> Double? {
        guard heightCm > 0, weightKg > 0 else { return nil }
        let heightM = heightCm / 100
        return weightKg / (heightM * heightM)
    }

    /// 日本肥満学会の判定基準
    static func category(for bmi: Double) -> String {
        switch bmi {
        case ..<18.5: return "低体重"
        case ..<25: return "普通体重"
        case ..<30: return "肥満(1度)"
        case ..<35: return "肥満(2度)"
        case ..<40: return "肥満(3度)"
        default: return "肥満(4度)"
        }
    }

    /// 指定した身長で BMI 22 となる標準体重
    static func idealWeight(heightCm: Double) -> Double {
        let heightM = heightCm / 100
        return 22 * heightM * heightM
    }
}

// MARK: - グラフ表示期間

enum ChartPeriod: String, CaseIterable, Identifiable {
    case week = "週"
    case month = "月"
    case threeMonths = "3ヶ月"
    case year = "年"
    case all = "全期間"

    var id: String { rawValue }

    /// 期間の開始日（全期間の場合は nil）
    func startDate(from now: Date = Date(), calendar: Calendar = .current) -> Date? {
        let today = calendar.startOfDay(for: now)
        switch self {
        case .week: return calendar.date(byAdding: .day, value: -6, to: today)
        case .month: return calendar.date(byAdding: .month, value: -1, to: today)
        case .threeMonths: return calendar.date(byAdding: .month, value: -3, to: today)
        case .year: return calendar.date(byAdding: .year, value: -1, to: today)
        case .all: return nil
        }
    }
}

// MARK: - グラフ表示項目

enum ChartMetric: String, CaseIterable, Identifiable {
    case weight = "体重"
    case bodyFat = "体脂肪率"
    case bmi = "BMI"

    var id: String { rawValue }

    var unit: String {
        switch self {
        case .weight: return "kg"
        case .bodyFat: return "%"
        case .bmi: return ""
        }
    }
}

struct ChartPoint: Identifiable {
    let date: Date
    let value: Double
    var id: Date { date }
}

// MARK: - 入力値の解析

enum NumberInput {
    /// 「65.4」「65,4」「６５．４」などを Double に変換する
    static func parse(_ text: String) -> Double? {
        let normalized = text
            .applyingTransform(.fullwidthToHalfwidth, reverse: false)?
            .replacingOccurrences(of: ",", with: ".")
            .trimmingCharacters(in: .whitespaces) ?? text
        guard !normalized.isEmpty else { return nil }
        return Double(normalized)
    }

    static func format(_ value: Double, digits: Int = 1) -> String {
        value.formatted(.number.precision(.fractionLength(digits)).grouping(.never))
    }
}

enum ValidationRange {
    static let weight: ClosedRange<Double> = 10...400
    static let bodyFat: ClosedRange<Double> = 1...80
    static let height: ClosedRange<Double> = 50...250
}
