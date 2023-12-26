//  UserSettingsManager.swift

import CoreData
import SwiftUI

class UserSettingsManager {
    static let shared = UserSettingsManager()
    let container: NSPersistentContainer
    
    init() {
        container = NSPersistentContainer(name: "LightTrackDataModel")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }

    func saveHeight(height: Double) {
        let context = container.viewContext
        let request: NSFetchRequest<UserSettingsEntity> = UserSettingsEntity.fetchRequest()
        if let settings = try? context.fetch(request).first {
            settings.height = height
        } else {
            let newSettings = UserSettingsEntity(context: context)
            newSettings.height = height
        }
        
        do {
            try context.save()
            print("Success save height: \(height)")
        } catch {
            print("Failed to save height: \(error)")
        }
    }

    func fetchHeight() -> Double {
        let context = container.viewContext
        let request: NSFetchRequest<UserSettingsEntity> = UserSettingsEntity.fetchRequest()
        
        if let settings = try? context.fetch(request).first {
            return settings.height
        } else {
            return 170.0
        }
    }
}
