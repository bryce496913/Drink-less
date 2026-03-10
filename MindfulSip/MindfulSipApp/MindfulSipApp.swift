import SwiftUI

@main
struct MindfulSipApp: App {
    @StateObject private var container = AppContainer()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(container)
                .preferredColorScheme(.dark)
                .tint(AppTheme.highlight)
                .appFullscreenContainer()
        }
    }
}
