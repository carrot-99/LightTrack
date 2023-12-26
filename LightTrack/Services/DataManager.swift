//  DataManager.swift

import Foundation
import CoreData

class DataManager {
    static let shared = DataManager()

    let container: NSPersistentContainer

    init() {
        container = NSPersistentContainer(name: "LightTrackDataModel")
        container.loadPersistentStores { (description, error) in
            if let error = error {
                fatalError("Core Data Store failed \(error.localizedDescription)")
            }
        }
    }

    func fetchHealthData() -> [HealthData] {
        let request: NSFetchRequest<HealthDataEntity> = HealthDataEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]

        do {
            let results = try container.viewContext.fetch(request).map { $0.toHealthData() }
            return results
        } catch {
            print("Failed to fetch HealthData: \(error)")
            return []
        }
    }

    func saveHealthData(date: Date, weight: Double, bodyFatPercentage: Double?) {
        let entity = HealthDataEntity(context: container.viewContext)
        entity.date = date
        entity.weight = weight
        entity.bodyFatPercentage = bodyFatPercentage ?? 0

        do {
            try container.viewContext.save()
            print("HealthData saved successfully: \(date), \(weight), \(String(describing: bodyFatPercentage))")
        } catch {
            container.viewContext.rollback()
            print("Failed to save HealthData: \(error)")
        }
    }
    
    func updateHealthData(record: HealthData, newWeight: Double, newBodyFat: Double?, newDate: Date) {
        let request: NSFetchRequest<HealthDataEntity> = HealthDataEntity.fetchRequest()
        request.predicate = NSPredicate(format: "date == %@", record.date as CVarArg)

        do {
            let results = try container.viewContext.fetch(request)
            if let entity = results.first {
                entity.weight = newWeight
                entity.bodyFatPercentage = newBodyFat ?? 0
                entity.date = newDate
                try container.viewContext.save()
            }
        } catch {
            print("Update failed: \(error)")
        }
    }

    func deleteHealthData(record: HealthData) {
        let request: NSFetchRequest<HealthDataEntity> = HealthDataEntity.fetchRequest()
        request.predicate = NSPredicate(format: "date == %@", record.date as CVarArg)

        do {
            let results = try container.viewContext.fetch(request)
            if let entity = results.first {
                container.viewContext.delete(entity)
                try container.viewContext.save()
            }
        } catch {
            print("Deletion failed: \(error)")
        }
    }
}
