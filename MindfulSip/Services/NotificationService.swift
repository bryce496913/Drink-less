import Foundation
import UserNotifications
import UIKit

struct NotificationService {
    static let boozeModeCategoryId = "BOOZE_MODE_CATEGORY"
    static let boozeModeAddDrinkActionId = "BOOZE_MODE_ADD_DRINK"

    private let reminderIdPrefix = "dailyLogReminder"
    private let weeklyPlanningReminderId = "weeklyPlanningReminder"
    private let boozeModeNotificationId = "boozeModeQuickAdd"
    private let reminderMessages = [
        "A mindful choice tonight can change tomorrow.",
        "Pause first. Your goal still matters.",
        "One less drink is still progress.",
        "Stay steady. You’re doing this for you.",
        "Tonight is a good night to keep it light.",
        "Small choices build real change.",
        "Check in with yourself before you pour.",
        "Your goals deserve your attention tonight.",
        "A little restraint can go a long way.",
        "You’re stronger than the habit.",
        "Slow down tonight. You’ll thank yourself later.",
        "Keep your promise to yourself tonight.",
        "Progress happens one choice at a time.",
        "Choose what supports tomorrow’s version of you.",
        "You don’t need perfect. Just intentional.",
        "A pause can be powerful.",
        "Keep going. Your effort counts.",
        "Be kind to yourself and stay mindful tonight.",
        "Remember why you started.",
        "Tonight is another chance to do yourself proud."
    ]

    func requestIfNeeded() async {
        _ = try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
        registerBoozeModeCategory()
    }

    func scheduleDailyReminder(at date: Date, from now: Date = .now, daysAhead: Int = 30) {
        let center = UNUserNotificationCenter.current()
        removeAllScheduledReminders()

        let calendar = Calendar.current
        let reminderTime = calendar.dateComponents([.hour, .minute], from: date)

        for offset in 0..<daysAhead {
            guard
                let day = calendar.date(byAdding: .day, value: offset, to: calendar.startOfDay(for: now)),
                let fireDate = calendar.date(bySettingHour: reminderTime.hour ?? 20, minute: reminderTime.minute ?? 0, second: 0, of: day),
                fireDate > now
            else {
                continue
            }

            let comps = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
            let content = UNMutableNotificationContent()
            content.title = "Mindful check-in"
            content.body = reminderMessage(for: fireDate)
            content.badge = 1
            if #available(iOS 15.0, *) {
                content.interruptionLevel = .timeSensitive
            }

            let request = UNNotificationRequest(
                identifier: reminderIdentifier(for: fireDate),
                content: content,
                trigger: UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
            )
            center.add(request)
        }

        scheduleWeeklyPlanningReminder()

        clearStaleDeliveredReminders()
    }

    func cancelDailyReminder() {
        removeAllScheduledReminders()
    }

    func scheduleBoozeModeQuickAdd(todayCount: Double) {
        registerBoozeModeCategory()

        let content = UNMutableNotificationContent()
        content.title = "Booze Mode active"
        content.body = "MindfulSip • Today: \(String(format: "%.1f", todayCount)) drinks. Tap Add Drink for a quick log."
        content.categoryIdentifier = Self.boozeModeCategoryId
        content.sound = .default
        if #available(iOS 15.0, *) {
            content.interruptionLevel = .active
        }

        // iOS does not support permanently pinned local notifications.
        // We keep one quickly-available local notification with an action button
        // and refresh it after each quick log.
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: boozeModeNotificationId, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    func cancelBoozeModeQuickAdd() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [boozeModeNotificationId])
        center.removeDeliveredNotifications(withIdentifiers: [boozeModeNotificationId])
    }

    func reminderMessage(for date: Date) -> String {
        let dayIndex = Calendar.current.ordinality(of: .day, in: .era, for: date) ?? 0
        let index = abs(dayIndex) % reminderMessages.count
        return reminderMessages[index]
    }

    func clearStaleDeliveredReminders(referenceDate: Date = .now) {
        let center = UNUserNotificationCenter.current()
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: referenceDate)

        center.getDeliveredNotifications { notifications in
            let stale = notifications
                .filter { $0.request.identifier.hasPrefix(reminderIdPrefix) }
                .filter { notification in
                    guard let date = reminderDate(from: notification.request.identifier) else { return true }
                    return calendar.startOfDay(for: date) != today
                }
                .map(\.request.identifier)

            guard !stale.isEmpty else { return }
            center.removeDeliveredNotifications(withIdentifiers: stale)
        }
    }

    func clearBadgeCount() {
        DispatchQueue.main.async {
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
    }

    private func registerBoozeModeCategory() {
        let addDrink = UNNotificationAction(
            identifier: Self.boozeModeAddDrinkActionId,
            title: "Add Drink",
            options: [.foreground]
        )
        let category = UNNotificationCategory(
            identifier: Self.boozeModeCategoryId,
            actions: [addDrink],
            intentIdentifiers: [],
            options: []
        )
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }

    private func removeAllScheduledReminders() {
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests { requests in
            let ids = requests
                .filter { $0.identifier.hasPrefix(reminderIdPrefix) || $0.identifier == weeklyPlanningReminderId }
                .map(\.identifier)
            if !ids.isEmpty {
                center.removePendingNotificationRequests(withIdentifiers: ids)
            }
        }

        center.getDeliveredNotifications { notifications in
            let ids = notifications
                .filter { $0.request.identifier.hasPrefix(reminderIdPrefix) }
                .map(\.request.identifier)
            if !ids.isEmpty {
                center.removeDeliveredNotifications(withIdentifiers: ids)
            }
        }
    }

    private func scheduleWeeklyPlanningReminder() {
        let center = UNUserNotificationCenter.current()
        var mondayMorning = DateComponents()
        mondayMorning.weekday = 2
        mondayMorning.hour = 9
        mondayMorning.minute = 0

        let content = UNMutableNotificationContent()
        content.title = "Plan your week"
        content.body = "It’s Monday morning. Set your weekly target and daily plan in MindfulSip."
        content.badge = 1
        if #available(iOS 15.0, *) {
            content.interruptionLevel = .active
        }

        let trigger = UNCalendarNotificationTrigger(dateMatching: mondayMorning, repeats: true)
        let request = UNNotificationRequest(identifier: weeklyPlanningReminderId, content: content, trigger: trigger)
        center.add(request)
    }

    private func reminderIdentifier(for date: Date) -> String {
        "\(reminderIdPrefix)-\(Int(date.timeIntervalSince1970))"
    }

    private func reminderDate(from identifier: String) -> Date? {
        guard
            identifier.hasPrefix(reminderIdPrefix),
            let timestamp = TimeInterval(identifier.replacingOccurrences(of: "\(reminderIdPrefix)-", with: ""))
        else {
            return nil
        }
        return Date(timeIntervalSince1970: timestamp)
    }
}
