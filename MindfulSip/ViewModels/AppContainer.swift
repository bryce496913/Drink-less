import Foundation
import Combine

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
    @Published var currentDate: Date = .now

    var todaysReminderMessage: String? {
        guard settings.remindersEnabled else { return nil }
        let today = dateService.startOfDay(currentDate)
        guard
            let triggerDate = Calendar.current.date(bySettingHour: Calendar.current.component(.hour, from: settings.reminderTime), minute: Calendar.current.component(.minute, from: settings.reminderTime), second: 0, of: today),
            currentDate >= triggerDate
        else {
            return nil
        }
        return notificationService.reminderMessage(for: triggerDate)
    }

    private let dateService = DateService()
    private var clockCancellable: AnyCancellable?
    private var lastReminderRefreshDay: Date

    init() {
        profile = store.loadProfile()
        settings = store.loadSettings()
        logs = store.fetchLogs(daysBack: 365)
        lastReminderRefreshDay = dateService.startOfDay(.now)
        startClock()
        applyReminderSettings()
    }

    var areWeeklyTargetsLocked: Bool {
        guard let lockWeekStart = settings.targetsLockedWeekStart else { return false }
        return dateService.startOfDay(lockWeekStart) == dateService.startOfDay(dateService.startOfWeek(currentDate))
    }

    func refresh() {
        profile = store.loadProfile()
        settings = store.loadSettings()
        logs = store.fetchLogs(daysBack: 365)
    }

    func saveProfile() {
        applyWeeklyTargetLock()
        store.saveProfile(profile)
        store.saveSettings(settings)
        refresh()
    }
    func saveSettings() {
        store.saveSettings(settings)
        applyReminderSettings()
        refresh()
    }
    func saveProfileAndSettings() {
        applyWeeklyTargetLock()
        store.saveProfile(profile)
        store.saveSettings(settings)
        applyReminderSettings()
        refresh()
    }

    func saveLog(_ log: DayLog) { store.upsert(log: log); refresh() }

    func log(for date: Date) -> DayLog {
        let day = dateService.startOfDay(date)
        return logs.first { dateService.startOfDay($0.date) == day }
            ?? DayLog(date: day, plannedTargetDrinks: 0, isDryPlanned: false, totalDrinks: 0, updatedAt: .now, notes: "")
    }

    func updateDrinkTotal(date: Date, total: Double, type: DrinkType? = nil, delta: Double? = nil) {
        loggingService.update(date: date, total: total, type: type, delta: delta)
        logs = store.fetchLogs(daysBack: 365)
    }

    private func startClock() {
        clockCancellable = Timer.publish(every: 30, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] now in
                guard let self else { return }
                currentDate = now

                let day = dateService.startOfDay(now)
                if day != lastReminderRefreshDay {
                    lastReminderRefreshDay = day
                    if settings.remindersEnabled {
                        applyReminderSettings()
                    }
                    notificationService.clearStaleDeliveredReminders(referenceDate: now)
                }
            }
    }

    private func applyReminderSettings() {
        guard settings.remindersEnabled else {
            notificationService.cancelDailyReminder()
            return
        }

        Task {
            await notificationService.requestIfNeeded()
            notificationService.scheduleDailyReminder(at: settings.reminderTime)
        }
    }

    private func applyWeeklyTargetLock() {
        let persistedProfile = store.loadProfile()
        let persistedSettings = store.loadSettings()

        let currentWeekStart = dateService.startOfWeek(currentDate)
        let lockIsActiveForCurrentWeek = persistedSettings.targetsLockedWeekStart.map {
            dateService.startOfDay($0) == dateService.startOfDay(currentWeekStart)
        } ?? false

        if lockIsActiveForCurrentWeek {
            profile.weeklyTarget = persistedProfile.weeklyTarget
            profile.dryDaysTarget = persistedProfile.dryDaysTarget
            settings.targetsLockedWeekStart = currentWeekStart
            return
        }

        let isMonday = dateService.calendar.component(.weekday, from: currentDate) == 2
        let targetsWereUpdated = profile.weeklyTarget != persistedProfile.weeklyTarget || profile.dryDaysTarget != persistedProfile.dryDaysTarget
        if isMonday && targetsWereUpdated {
            settings.targetsLockedWeekStart = currentWeekStart
        }
    }
}
