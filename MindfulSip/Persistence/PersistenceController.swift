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
        container.loadPersistentStores { [container] storeDescription, error in
            guard let error else { return }

            // A persistent-store failure should not crash users at launch. If the
            // on-disk store cannot be opened, fall back to an in-memory store so
            // the app remains usable and the issue can be resolved by a future
            // migration or data reset.
            let fallbackDescription = NSPersistentStoreDescription()
            fallbackDescription.type = NSInMemoryStoreType
            fallbackDescription.url = URL(fileURLWithPath: "/dev/null")
            container.persistentStoreDescriptions = [fallbackDescription]
            container.loadPersistentStores { _, fallbackError in
                if let fallbackError {
                    assertionFailure("Core Data fallback store failed after \(storeDescription): \(error), fallback: \(fallbackError)")
                }
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
    @NSManaged var name: String
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
    @NSManaged var avoidWeekendForAutoDry: Bool
    @NSManaged var targetsLockedWeekStart: Date?
    @NSManaged var boozeModeEnabled: Bool
    @NSManaged var holidayModeEnabled: Bool
    @NSManaged var holidayStartDate: Date?
    @NSManaged var holidayEndDate: Date?
}

@objc(DayLogEntity)
final class DayLogEntity: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var date: Date
    @NSManaged var plannedTargetDrinks: Double
    @NSManaged var isDryPlanned: Bool
    @NSManaged var totalDrinks: Double
    @NSManaged var updatedAt: Date
    @NSManaged var notes: String
    @NSManaged var entriesBlob: Data?
}
