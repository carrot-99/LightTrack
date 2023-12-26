//  HealthData.swift

import Foundation

struct HealthData {
    var date: Date
    var weight: Double
    var bodyFatPercentage: Double?
    
    func calculateBMI(height: Double) -> Double {
        return (weight * 10000) / (height * height)
    }
    
    var formattedDateTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm" 
        return formatter.string(from: date)
    }
}

extension HealthDataEntity {
    func toHealthData() -> HealthData {
        return HealthData(
            date: self.date ?? Date(),
            weight: self.weight,
            bodyFatPercentage: self.bodyFatPercentage
        )
    }
}

enum Period {
    case week, month, year
    
    var dateComponent: Calendar.Component {
        switch self {
            case .week: return .weekOfYear
            case .month: return .month
            case .year: return .year
        }
    }
    
    var value: Int {
        switch self {
            case .week: return -1
            case .month: return -1
            case .year: return -1
        }
    }
}

extension Date {
    static func dates(from startDate: Date, to endDate: Date) -> [Date] {
        var dates: [Date] = []
        var date = startDate
        
        let calendar = Calendar.current
        while date <= endDate {
            dates.append(date)
            date = calendar.date(byAdding: .day, value: 1, to: date)!
        }
        
        return dates
    }
}
