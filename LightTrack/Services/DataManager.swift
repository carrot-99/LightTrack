//  DataManager.swift

import Foundation
import CoreData

/// アプリ全体で共有する Core Data スタックと測定記録の CRUD
final class DataManager {
    static let shared = DataManager()

    let container: NSPersistentContainer
    var context: NSManagedObjectContext { container.viewContext }

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "LightTrackDataModel")
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { _, error in
            if let error {
                fatalError("Core Data Store failed: \(error.localizedDescription)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    /// 測定記録を新しい順に取得する
    func fetchHealthData() -> [HealthData] {
        let request: NSFetchRequest<HealthDataEntity> = HealthDataEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        do {
            return try context.fetch(request).map { $0.toHealthData() }
        } catch {
            print("Failed to fetch HealthData: \(error)")
            return []
        }
    }

    @discardableResult
    func saveHealthData(date: Date, weight: Double, bodyFatPercentage: Double?) -> Bool {
        let entity = HealthDataEntity(context: context)
        entity.date = date
        entity.weight = weight
        entity.bodyFatPercentage = bodyFatPercentage ?? 0
        return saveContext()
    }

    @discardableResult
    func updateHealthData(_ record: HealthData, date: Date, weight: Double, bodyFatPercentage: Double?) -> Bool {
        guard let entity = entity(for: record) else { return false }
        entity.date = date
        entity.weight = weight
        entity.bodyFatPercentage = bodyFatPercentage ?? 0
        return saveContext()
    }

    @discardableResult
    func deleteHealthData(_ records: [HealthData]) -> Bool {
        records.compactMap(entity(for:)).forEach(context.delete)
        return saveContext()
    }

    // MARK: - Private

    /// ObjectID で対象を特定する（以前は日時で検索していたため、同時刻の記録で誤更新が起きていた）
    private func entity(for record: HealthData) -> HealthDataEntity? {
        guard let objectID = record.objectID else { return nil }
        return try? context.existingObject(with: objectID) as? HealthDataEntity
    }

    private func saveContext() -> Bool {
        guard context.hasChanges else { return true }
        do {
            try context.save()
            return true
        } catch {
            context.rollback()
            print("Failed to save context: \(error)")
            return false
        }
    }
}
