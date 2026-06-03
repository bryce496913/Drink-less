import Foundation

@MainActor
final class LoggingService {
    let store: DataStore
    let dateService = DateService()

    init(store: DataStore) { self.store = store }

    func update(date: Date, total: Double, type: DrinkType? = nil, delta: Double? = nil) {
        var log = log(for: date)
        log.totalDrinks = total.finiteOrDefault(0).clamped(to: 0...200)
        if let delta, delta.isFinite, delta > 0 {
            let entry = DrinkEntry(id: UUID(), dateTime: .now, amount: delta, type: type)
            log.entries.append(entry)
        }
        store.upsert(log: log.sanitized)
    }

    func log(for date: Date) -> DayLog {
        let day = dateService.startOfDay(date)
        return store.fetchLogs(daysBack: 365).first { dateService.startOfDay($0.date) == day }
            ?? DayLog(date: day, plannedTargetDrinks: 0, isDryPlanned: false, totalDrinks: 0, updatedAt: .now, notes: "")
    }
}
