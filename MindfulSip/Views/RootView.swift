import SwiftUI

struct RootView: View {
    @EnvironmentObject var container: AppContainer

    var body: some View {
        ZStack(alignment: .top) {
            AppTheme.background

            Group {
                if container.settings.hasCompletedOnboarding {
                    MainTabView()
                } else {
                    OnboardingView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .appFullscreenContainer()
    }
}

#Preview {
    RootView().environmentObject(AppContainer())
}
