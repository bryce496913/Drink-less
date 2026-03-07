import CoreData
import Foundation

@MainActor
final class DataStore: ObservableObject {
    private let persistence: PersistenceController
    private var context: NSManagedObjectContext { persistence.container.viewContext }

    init(persistence: PersistenceController = .shared) {
        self.persistence = persistence
    }

    func loadProfile() -> UserProfile {
        let request = NSFetchRequest<UserProfileEntity>(entityName: "UserProfileEntity")
        if let entity = try? context.fetch(request).first {
            return UserProfile(
                id: entity.id,
                createdAt: entity.createdAt,
                name: entity.name,
                goalType: GoalType(rawValue: entity.goalType) ?? .drinkLess,
                weeklyTarget: Int(entity.weeklyTarget),
                dryDaysTarget: Int(entity.dryDaysTarget),
                baselineWeeklyDrinks: entity.baselineWeeklyDrinks,
                costPerDrink: entity.costPerDrink,
                caloriesPerDrink: entity.caloriesPerDrink
            )
        }
        let profile = UserProfile()
        saveProfile(profile)
        return profile
    }

    func saveProfile(_ profile: UserProfile) {
        let request = NSFetchRequest<UserProfileEntity>(entityName: "UserProfileEntity")
        let entity = (try? context.fetch(request).first) ?? UserProfileEntity(context: context)
        entity.id = profile.id
        entity.createdAt = profile.createdAt
        entity.name = profile.name
        entity.goalType = profile.goalType.rawValue
        entity.weeklyTarget = Int16(profile.weeklyTarget)
        entity.dryDaysTarget = Int16(profile.dryDaysTarget)
        entity.baselineWeeklyDrinks = profile.baselineWeeklyDrinks
        entity.costPerDrink = profile.costPerDrink
        entity.caloriesPerDrink = profile.caloriesPerDrink
        persistence.save()
    }

    func loadSettings() -> AppSettings {
        let request = NSFetchRequest<AppSettingsEntity>(entityName: "AppSettingsEntity")
        if let entity = try? context.fetch(request).first {
            return AppSettings(reminderTime: entity.reminderTime, remindersEnabled: entity.remindersEnabled, hasCompletedOnboarding: entity.hasCompletedOnboarding, backendSyncEnabled: entity.backendSyncEnabled, backendBaseURL: entity.backendBaseURL, deviceId: entity.deviceId, avoidWeekendForAutoDry: entity.avoidWeekendForAutoDry)
        }
        let settings = AppSettings()
        saveSettings(settings)
        return settings
    }

    func saveSettings(_ settings: AppSettings) {
        let request = NSFetchRequest<AppSettingsEntity>(entityName: "AppSettingsEntity")
        let entity = (try? context.fetch(request).first) ?? AppSettingsEntity(context: context)
        entity.reminderTime = settings.reminderTime
        entity.remindersEnabled = settings.remindersEnabled
        entity.hasCompletedOnboarding = settings.hasCompletedOnboarding
        entity.backendSyncEnabled = settings.backendSyncEnabled
        entity.backendBaseURL = settings.backendBaseURL
        entity.deviceId = settings.deviceId
        entity.avoidWeekendForAutoDry = settings.avoidWeekendForAutoDry
        persistence.save()
    }

    func fetchLogs(daysBack: Int = 120) -> [DayLog] {
        let start = Calendar.current.date(byAdding: .day, value: -daysBack, to: .now) ?? .distantPast
        let request = NSFetchRequest<DayLogEntity>(entityName: "DayLogEntity")
        request.predicate = NSPredicate(format: "date >= %@", start as NSDate)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        let entities = (try? context.fetch(request)) ?? []
        return entities.map {
            DayLog(id: $0.id, date: $0.date, plannedTargetDrinks: $0.plannedTargetDrinks, isDryPlanned: $0.isDryPlanned, totalDrinks: $0.totalDrinks, updatedAt: $0.updatedAt, notes: $0.notes, entries: (try? JSONDecoder().decode([DrinkEntry].self, from: $0.entriesBlob ?? Data())) ?? [])
        }
    }

    func upsert(log: DayLog) {
        let date = Calendar.current.startOfDay(for: log.date)
        let request = NSFetchRequest<DayLogEntity>(entityName: "DayLogEntity")
        request.predicate = NSPredicate(format: "date == %@", date as NSDate)
        let entity = (try? context.fetch(request).first) ?? DayLogEntity(context: context)
        entity.id = log.id
        entity.date = date
        entity.plannedTargetDrinks = log.plannedTargetDrinks
        entity.isDryPlanned = log.isDryPlanned
        entity.totalDrinks = log.totalDrinks
        entity.updatedAt = .now
        entity.notes = log.notes
        entity.entriesBlob = try? JSONEncoder().encode(log.entries)
        persistence.save()
    }

    func deleteAll() {
        ["UserProfileEntity", "AppSettingsEntity", "DayLogEntity"].forEach { name in
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: name)
            let delete = NSBatchDeleteRequest(fetchRequest: request)
            _ = try? context.execute(delete)
        }
        persistence.save()
    }
}
