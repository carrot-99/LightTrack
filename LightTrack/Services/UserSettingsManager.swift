//  UserSettingsManager.swift

import CoreData

/// 身長などのユーザ設定を保存する。DataManager と同じ Core Data スタックを共有する。
final class UserSettingsManager {
    static let shared = UserSettingsManager()

    static let defaultHeight: Double = 170.0

    private let dataManager: DataManager
    private var context: NSManagedObjectContext { dataManager.context }

    init(dataManager: DataManager = .shared) {
        self.dataManager = dataManager
    }

    func saveHeight(_ height: Double) {
        let settings = fetchSettings() ?? UserSettingsEntity(context: context)
        settings.height = height
        do {
            try context.save()
        } catch {
            context.rollback()
            print("Failed to save height: \(error)")
        }
    }

    func fetchHeight() -> Double {
        guard let height = fetchSettings()?.height, height > 0 else {
            return Self.defaultHeight
        }
        return height
    }

    private func fetchSettings() -> UserSettingsEntity? {
        let request: NSFetchRequest<UserSettingsEntity> = UserSettingsEntity.fetchRequest()
        request.fetchLimit = 1
        return try? context.fetch(request).first
    }
}
