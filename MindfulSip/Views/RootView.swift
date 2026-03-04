import SwiftUI

struct RootView: View {
    @EnvironmentObject var container: AppContainer

    var body: some View {
        Group {
            if container.settings.hasCompletedOnboarding {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .background(AppTheme.background.ignoresSafeArea())
    }
}

#Preview {
    RootView().environmentObject(AppContainer())
}
