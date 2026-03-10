import SwiftUI

struct MainTabView: View {
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.black
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.systemPink
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.systemPink]
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor.white
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.white]
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        ZStack(alignment: .top) {
            AppTheme.background
                .ignoresSafeArea()

            TabView {
                HomeView().tabItem { Label("Home", systemImage: "house") }
                PlanView().tabItem { Label("Plan", systemImage: "calendar") }
                TrackView().tabItem { Label("Track", systemImage: "calendar.badge.clock") }
                ProgressView().tabItem { Label("Progress", systemImage: "chart.bar") }
                GuidanceView().tabItem { Label("Guidance", systemImage: "heart.text.square") }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

#Preview {
    MainTabView().environmentObject(AppContainer())
}
