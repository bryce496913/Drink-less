import SwiftUI

@main
struct MindfulSipApp: App {
    @StateObject private var container = AppContainer()
    @Environment(\.scenePhase) private var scenePhase

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
