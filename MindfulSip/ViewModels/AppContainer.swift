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

    var isHolidayModeActive: Bool {
        guard settings.holidayModeEnabled else { return false }
        return isDateInHolidayRange(currentDate)
    }

    private let dateService = DateService()
    private var clockCancellable: AnyCancellable?
    private var lastReminderRefreshDay: Date

    init() {
        profile = store.loadProfile().sanitized
        settings = store.loadSettings().sanitized
        logs = store.fetchLogs(daysBack: 365)
        lastReminderRefreshDay = dateService.startOfDay(.now)
        startClock()
        applyReminderSettings()
        syncBoozeModeExperience()
    }

    var areWeeklyTargetsLocked: Bool {
        guard isLockEnforcedToday, let lockWeekStart = settings.targetsLockedWeekStart else { return false }
        return dateService.startOfDay(lockWeekStart) == dateService.startOfDay(dateService.startOfWeek(currentDate))
    }

    var canEditWeeklyPlan: Bool {
        !areWeeklyTargetsLocked
    }

    private var isLockEnforcedToday: Bool {
        dateService.calendar.component(.weekday, from: currentDate) != 2
    }

    func isDateInHolidayRange(_ date: Date) -> Bool {
        guard settings.holidayModeEnabled,
              let start = settings.holidayStartDate,
              let end = settings.holidayEndDate else {
            return false
        }
        let day = dateService.startOfDay(date)
        let startDay = dateService.startOfDay(start)
        let endDay = dateService.startOfDay(end)
        guard startDay <= endDay else { return false }
        return day >= startDay && day <= endDay
    }

    func shouldIgnoreGoals(for date: Date) -> Bool {
        isDateInHolidayRange(date)
    }

    func shouldIgnoreDryDayPenalty(for date: Date) -> Bool {
        isDateInHolidayRange(date)
    }

    func refresh() {
        profile = store.loadProfile().sanitized
        settings = store.loadSettings().sanitized
        logs = store.fetchLogs(daysBack: 365)
        syncBoozeModeExperience()
    }

    func saveProfile() {
        profile = profile.sanitized
        applyWeeklyTargetLock()
        store.saveProfile(profile)
        store.saveSettings(settings)
        refresh()
    }
    func saveSettings() {
        settings = settings.sanitized
        store.saveSettings(settings)
        applyReminderSettings()
        syncBoozeModeExperience()
        refresh()
    }
    func saveProfileAndSettings() {
        profile = profile.sanitized
        settings = settings.sanitized
        applyWeeklyTargetLock()
        store.saveProfile(profile)
        store.saveSettings(settings)
        applyReminderSettings()
        syncBoozeModeExperience()
        refresh()
    }

    func saveLog(_ log: DayLog) { store.upsert(log: log.sanitized); refresh() }

    func log(for date: Date) -> DayLog {
        let day = dateService.startOfDay(date)
        return logs.first { dateService.startOfDay($0.date) == day }
            ?? DayLog(date: day, plannedTargetDrinks: 0, isDryPlanned: false, totalDrinks: 0, updatedAt: .now, notes: "")
    }

    func updateDrinkTotal(date: Date, total: Double, type: DrinkType? = nil, delta: Double? = nil) {
        loggingService.update(date: date, total: total.finiteOrDefault(0).clamped(to: 0...200), type: type, delta: delta?.finiteOrDefault(0).clamped(to: 0...50))
        logs = store.fetchLogs(daysBack: 365)
        if settings.boozeModeEnabled {
            notificationService.scheduleBoozeModeQuickAdd(todayCount: log(for: currentDate).totalDrinks)
        }
    }

    func quickAddDrink(amount: Double = 1.0, type: DrinkType? = .other) {
        guard amount.isFinite, amount > 0 else { return }
        let today = log(for: currentDate)
        updateDrinkTotal(date: currentDate, total: today.totalDrinks + amount, type: type, delta: amount)
    }

    func registerWeeklyPlanSavedIfNeeded() {
        let currentWeekStart = dateService.startOfWeek(currentDate)
        let isMonday = dateService.calendar.component(.weekday, from: currentDate) == 2
        let lockIsActiveForCurrentWeek = settings.targetsLockedWeekStart.map {
            dateService.startOfDay($0) == dateService.startOfDay(currentWeekStart)
        } ?? false

        guard isMonday, !lockIsActiveForCurrentWeek else { return }
        settings.targetsLockedWeekStart = currentWeekStart
        store.saveSettings(settings)
        refresh()
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
                    if settings.boozeModeEnabled {
                        syncBoozeModeExperience()
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
            let isAuthorized = await notificationService.requestIfNeeded()
            guard isAuthorized else {
                settings.remindersEnabled = false
                store.saveSettings(settings)
                notificationService.cancelDailyReminder()
                return
            }
            notificationService.scheduleDailyReminder(at: settings.reminderTime)
        }
    }

    private func syncBoozeModeExperience() {
        if settings.boozeModeEnabled {
            Task {
                guard await notificationService.requestIfNeeded() else {
                    settings.boozeModeEnabled = false
                    store.saveSettings(settings)
                    notificationService.cancelBoozeModeQuickAdd()
                    return
                }
                notificationService.scheduleBoozeModeQuickAdd(todayCount: log(for: currentDate).totalDrinks)
            }
        } else {
            notificationService.cancelBoozeModeQuickAdd()
        }
    }

    private func applyWeeklyTargetLock() {
        let persistedProfile = store.loadProfile()
        let persistedSettings = store.loadSettings()

        let currentWeekStart = dateService.startOfWeek(currentDate)
        let lockIsActiveForCurrentWeek = persistedSettings.targetsLockedWeekStart.map {
            dateService.startOfDay($0) == dateService.startOfDay(currentWeekStart)
        } ?? false

        if lockIsActiveForCurrentWeek, isLockEnforcedToday {
            profile.weeklyTarget = persistedProfile.weeklyTarget
            profile.dryDaysTarget = persistedProfile.dryDaysTarget
            settings.targetsLockedWeekStart = currentWeekStart
            return
        }

        let isMonday = !isLockEnforcedToday
        let targetsWereUpdated = profile.weeklyTarget != persistedProfile.weeklyTarget || profile.dryDaysTarget != persistedProfile.dryDaysTarget
        if isMonday && targetsWereUpdated {
            settings.targetsLockedWeekStart = currentWeekStart
        }
    }
}
