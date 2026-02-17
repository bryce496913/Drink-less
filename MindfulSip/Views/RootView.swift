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
    }
}

#Preview {
    RootView().environmentObject(AppContainer())
}
