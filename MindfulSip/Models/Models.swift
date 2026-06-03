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

extension UserProfile {
    static let weeklyTargetRange = 0...50
    static let dryDaysTargetRange = 0...7
    static let baselineWeeklyDrinksRange = 0.0...200.0
    static let costPerDrinkRange = 0.0...500.0
    static let caloriesPerDrinkRange = 0.0...2_000.0

    var sanitized: UserProfile {
        var copy = self
        let trimmedName = copy.name.trimmingCharacters(in: .whitespacesAndNewlines)
        copy.name = trimmedName.isEmpty ? "Friend" : String(trimmedName.prefix(80))
        copy.weeklyTarget = copy.weeklyTarget.clamped(to: Self.weeklyTargetRange)
        copy.dryDaysTarget = copy.dryDaysTarget.clamped(to: Self.dryDaysTargetRange)
        copy.baselineWeeklyDrinks = copy.baselineWeeklyDrinks.finiteOrDefault(10).clamped(to: Self.baselineWeeklyDrinksRange)
        copy.costPerDrink = copy.costPerDrink.finiteOrDefault(8).clamped(to: Self.costPerDrinkRange)
        copy.caloriesPerDrink = copy.caloriesPerDrink.finiteOrDefault(120).clamped(to: Self.caloriesPerDrinkRange)
        return copy
    }
}

struct AppSettings: Codable {
    var reminderTime: Date = Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: .now) ?? .now
    var remindersEnabled: Bool = false
    var hasCompletedOnboarding: Bool = false
    var avoidWeekendForAutoDry: Bool = false
    var targetsLockedWeekStart: Date? = nil
    var boozeModeEnabled: Bool = false
    var holidayModeEnabled: Bool = false
    var holidayStartDate: Date? = nil
    var holidayEndDate: Date? = nil
}

extension AppSettings {
    var sanitized: AppSettings {
        var copy = self
        if copy.holidayModeEnabled {
            let fallbackStart = copy.holidayStartDate ?? Date()
            let fallbackEnd = copy.holidayEndDate ?? fallbackStart
            copy.holidayStartDate = fallbackStart
            copy.holidayEndDate = fallbackEnd < fallbackStart ? fallbackStart : fallbackEnd
        } else {
            copy.holidayStartDate = nil
            copy.holidayEndDate = nil
        }
        return copy
    }
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

extension DayLog {
    var sanitized: DayLog {
        var copy = self
        copy.plannedTargetDrinks = copy.plannedTargetDrinks.finiteOrDefault(0).clamped(to: 0...50)
        copy.totalDrinks = copy.totalDrinks.finiteOrDefault(0).clamped(to: 0...200)
        copy.notes = String(copy.notes.prefix(2_000))
        copy.entries = copy.entries
            .filter { $0.amount.isFinite && $0.amount > 0 }
            .map { entry in
                DrinkEntry(
                    id: entry.id,
                    dateTime: entry.dateTime,
                    amount: entry.amount.clamped(to: 0.0...50.0),
                    type: entry.type
                )
            }
        return copy
    }
}

extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}

extension Double {
    func finiteOrDefault(_ defaultValue: Double) -> Double {
        isFinite ? self : defaultValue
    }
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
