import SwiftUI

struct RootView: View {
    @EnvironmentObject var container: AppContainer

    var body: some View {
        ZStack(alignment: .top) {
            AppTheme.background
                .ignoresSafeArea()

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
    }
}

#Preview {
    RootView().environmentObject(AppContainer())
}
