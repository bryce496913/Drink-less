import Foundation

enum GoalType: String, Codable, CaseIterable, Identifiable {
    case drinkLess = "Drink less"
    case takeBreak = "Take a break"
    var id: String { rawValue }
}

enum DrinkType: String, Codable, CaseIterable, Identifiable {
    case beer, wine, spirits, cocktail, other
    var id: String { rawValue }
}

struct UserProfile: Codable {
    var id: UUID = UUID()
    var createdAt: Date = .now
    var name: String = "Friend"
    var goalType: GoalType = .drinkLess
    var weeklyTarget: Int = 10
    var dryDaysTarget: Int = 2
    var baselineWeeklyDrinks: Double = 10
    var costPerDrink: Double = 8
    var caloriesPerDrink: Double = 120
}

struct AppSettings: Codable {
    var reminderTime: Date = Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: .now) ?? .now
    var remindersEnabled: Bool = false
    var hasCompletedOnboarding: Bool = false
    var backendSyncEnabled: Bool = false
    var backendBaseURL: String = ""
    var deviceId: String = UUID().uuidString
    var avoidWeekendForAutoDry: Bool = false
}

struct DrinkEntry: Codable, Identifiable {
    let id: UUID
    let dateTime: Date
    let amount: Double
    let type: DrinkType?
}

struct DayLog: Codable, Identifiable {
    var id: UUID = UUID()
    var date: Date
    var plannedTargetDrinks: Double
    var isDryPlanned: Bool
    var totalDrinks: Double
    var updatedAt: Date
    var notes: String = ""
    var entries: [DrinkEntry] = []
}

struct WeeklyPoint: Identifiable {
    let id = UUID()
    let weekStart: Date
    let drinks: Double
    let dryDays: Int
}

struct Insights {
    let last14: Double
    let previous14: Double
    let topWeekday: Int
    let dryStreak: Int
    let loggingStreak: Int
}
