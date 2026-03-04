import Foundation

@MainActor
final class AppContainer: ObservableObject {
    let store = DataStore()
    lazy var loggingService = LoggingService(store: store)
    let planService = PlanService()
    let analyticsService = AnalyticsService()
    let tipService = TipService()
    let notificationService = NotificationService()

    @Published var profile: UserProfile
    @Published var settings: AppSettings
    @Published var logs: [DayLog]

    private let dateService = DateService()

    init() {
        profile = store.loadProfile()
        settings = store.loadSettings()
        logs = store.fetchLogs(daysBack: 365)
    }

    func refresh() {
        profile = store.loadProfile()
        settings = store.loadSettings()
        logs = store.fetchLogs(daysBack: 365)
    }

    func saveProfile() { store.saveProfile(profile); refresh() }
    func saveSettings() { store.saveSettings(settings); refresh() }
    func saveProfileAndSettings() {
        store.saveProfile(profile)
        store.saveSettings(settings)
        refresh()
    }

    func saveLog(_ log: DayLog) { store.upsert(log: log); refresh() }

    func log(for date: Date) -> DayLog {
        let day = dateService.startOfDay(date)
        return logs.first { dateService.startOfDay($0.date) == day }
            ?? DayLog(date: day, plannedTargetDrinks: 0, isDryPlanned: false, totalDrinks: 0, updatedAt: .now)
    }

    func updateDrinkTotal(date: Date, total: Double, type: DrinkType? = nil, delta: Double? = nil) {
        loggingService.update(date: date, total: total, type: type, delta: delta)
        logs = store.fetchLogs(daysBack: 365)
    }
}
