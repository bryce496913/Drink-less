import Foundation
import UserNotifications

struct NotificationService {
    private let reminderId = "dailyLogReminder"

    func requestIfNeeded() async {
        _ = try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
    }

    func scheduleDailyReminder(at date: Date) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [reminderId])
        let comps = Calendar.current.dateComponents([.hour, .minute], from: date)
        let content = UNMutableNotificationContent()
        content.title = "Mindful check-in"
        content.body = "Log today's drinks"
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
        let request = UNNotificationRequest(identifier: reminderId, content: content, trigger: trigger)
        center.add(request)
    }

    func cancelDailyReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [reminderId])
    }
}
