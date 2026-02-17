import CoreData
import Foundation

final class PersistenceController {
    static let shared = PersistenceController()
    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "MindfulSipModel")
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { _, error in
            if let error {
                fatalError("Core Data store failed: \(error)")
            }
        }
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    func save() {
        let context = container.viewContext
        guard context.hasChanges else { return }
        try? context.save()
    }
}

@objc(UserProfileEntity)
final class UserProfileEntity: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var createdAt: Date
    @NSManaged var goalType: String
    @NSManaged var weeklyTarget: Int16
    @NSManaged var dryDaysTarget: Int16
    @NSManaged var baselineWeeklyDrinks: Double
    @NSManaged var costPerDrink: Double
    @NSManaged var caloriesPerDrink: Double
}

@objc(AppSettingsEntity)
final class AppSettingsEntity: NSManagedObject {
    @NSManaged var reminderTime: Date
    @NSManaged var remindersEnabled: Bool
    @NSManaged var hasCompletedOnboarding: Bool
    @NSManaged var backendSyncEnabled: Bool
    @NSManaged var backendBaseURL: String
    @NSManaged var deviceId: String
    @NSManaged var avoidWeekendForAutoDry: Bool
}

@objc(DayLogEntity)
final class DayLogEntity: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var date: Date
    @NSManaged var plannedTargetDrinks: Double
    @NSManaged var isDryPlanned: Bool
    @NSManaged var totalDrinks: Double
    @NSManaged var updatedAt: Date
    @NSManaged var entriesBlob: Data?
}
