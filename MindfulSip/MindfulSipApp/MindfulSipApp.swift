import SwiftUI
import UIKit
import UserNotifications

final class NotificationActionRouter: NSObject, ObservableObject {
    var onBoozeQuickAdd: (() -> Void)?
}

final class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    let actionRouter = NotificationActionRouter()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        guard response.actionIdentifier == NotificationService.boozeModeAddDrinkActionId else { return }
        await MainActor.run {
            actionRouter.onBoozeQuickAdd?()
        }
    }
}

@main
struct MindfulSipApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var container = AppContainer()
    @Environment(\.scenePhase) private var scenePhase

    init() {
        let normalAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Poppins-Medium", size: 12) ?? UIFont.systemFont(ofSize: 12, weight: .medium),
            .foregroundColor: UIColor.white.withAlphaComponent(0.68)
        ]
        let selectedAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Poppins-Medium", size: 12) ?? UIFont.systemFont(ofSize: 12, weight: .medium),
            .foregroundColor: UIColor(AppTheme.accent)
        ]

        UITabBarItem.appearance().setTitleTextAttributes(normalAttributes, for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes(selectedAttributes, for: .selected)
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(container)
                .preferredColorScheme(.dark)
                .tint(AppTheme.highlight)
                .appFullscreenContainer()
                .onAppear {
                    appDelegate.actionRouter.onBoozeQuickAdd = {
                        container.quickAddDrink()
                    }
                }
                .onChange(of: scenePhase) { phase in
                    if phase == .active {
                        container.notificationService.clearBadgeCount()
                    }
                }
        }
    }
}
