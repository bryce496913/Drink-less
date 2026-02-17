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
    func saveLog(_ log: DayLog) { store.upsert(log: log); refresh() }
}
