import Foundation

struct AnalyticsService {
    let dateService = DateService()

    func weeklyTotal(logs: [DayLog], weekStart: Date) -> Double {
        let week = Set(dateService.weekDates(from: weekStart).map(dateService.startOfDay))
        return logs.filter { week.contains(dateService.startOfDay($0.date)) }.reduce(0) { $0 + $1.totalDrinks }
    }

    func weeklyDryDays(logs: [DayLog], weekStart: Date) -> Int {
        let week = Set(dateService.weekDates(from: weekStart).map(dateService.startOfDay))
        return logs.filter { week.contains(dateService.startOfDay($0.date)) && $0.totalDrinks == 0 }.count
    }

    func saved(actualWeekly: Double, baselineWeekly: Double, perDrink: Double) -> Double {
        max(0, (baselineWeekly - actualWeekly) * perDrink)
    }

    func insights(logs: [DayLog], today: Date = .now) -> Insights {
        let sorted = logs.sorted { $0.date < $1.date }
        let last14Start = Calendar.current.date(byAdding: .day, value: -13, to: today) ?? today
        let prev14Start = Calendar.current.date(byAdding: .day, value: -27, to: today) ?? today
        let previous14End = Calendar.current.date(byAdding: .day, value: -14, to: today) ?? today
        let last14 = sorted.filter { $0.date >= last14Start && $0.date <= today }.reduce(0) { $0 + $1.totalDrinks }
        let previous14 = sorted.filter { $0.date >= prev14Start && $0.date <= previous14End }.reduce(0) { $0 + $1.totalDrinks }

        var weekdayTotals = Array(repeating: 0.0, count: 7)
        sorted.forEach { weekdayTotals[Calendar.current.component(.weekday, from: $0.date) - 1] += $0.totalDrinks }
        let top = weekdayTotals.enumerated().max(by: { $0.element < $1.element })?.offset ?? 0

        return Insights(last14: last14, previous14: previous14, topWeekday: top, dryStreak: dryStreak(logs: sorted, today: today), loggingStreak: loggingStreak(logs: sorted, today: today))
    }

    func weeklyGoalSuccessStreak(logs: [DayLog], weeklyTarget: Int, setupDate: Date, asOf date: Date = .now) -> Int {
        let target = Double(weeklyTarget)
        let calendar = Calendar.current
        let currentWeekStart = dateService.startOfWeek(date)
        let firstTrackableWeekStart = dateService.startOfWeek(setupDate)
        var streak = 0
        var cursor = calendar.date(byAdding: .day, value: -7, to: currentWeekStart) ?? currentWeekStart

        while streak < 52 {
            let weekStart = dateService.startOfWeek(cursor)
            guard weekStart >= firstTrackableWeekStart else { break }

            let weekTotal = weeklyTotal(logs: logs, weekStart: weekStart)
            if weekTotal <= target {
                streak += 1
            } else {
                break
            }

            guard let previous = calendar.date(byAdding: .day, value: -7, to: weekStart) else {
                break
            }
            cursor = previous
        }

        return streak
    }

    func dryStreak(logs: [DayLog], today: Date = .now) -> Int {
        let map = Dictionary(uniqueKeysWithValues: logs.map { (dateService.startOfDay($0.date), $0.totalDrinks) })
        var streak = 0
        for offset in 0..<365 {
            guard let date = Calendar.current.date(byAdding: .day, value: -offset, to: today) else { continue }
            let day = dateService.startOfDay(date)
            guard let value = map[day], value == 0 else { break }
            streak += 1
        }
        return streak
    }

    func loggingStreak(logs: [DayLog], today: Date = .now) -> Int {
        let days = Set(logs.map { dateService.startOfDay($0.date) })
        var streak = 0
        for offset in 0..<365 {
            guard let date = Calendar.current.date(byAdding: .day, value: -offset, to: today) else { continue }
            if days.contains(dateService.startOfDay(date)) { streak += 1 } else { break }
        }
        return streak
    }
}
