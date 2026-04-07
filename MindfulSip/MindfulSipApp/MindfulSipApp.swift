import SwiftUI
import UIKit

@main
struct MindfulSipApp: App {
    @StateObject private var container = AppContainer()
    @Environment(\.scenePhase) private var scenePhase

    init() {
        let normalAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Poppins-Medium", size: 11) ?? UIFont.systemFont(ofSize: 11, weight: .medium),
            .foregroundColor: UIColor.white.withAlphaComponent(0.72)
        ]
        let selectedAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Poppins-Medium", size: 11) ?? UIFont.systemFont(ofSize: 11, weight: .medium),
            .foregroundColor: UIColor(AppTheme.highlight)
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
                .onChange(of: scenePhase) { phase in
                    if phase == .active {
                        container.notificationService.clearBadgeCount()
                    }
                }
        }
    }
}
