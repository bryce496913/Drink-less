import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView().tabItem { Label("Home", systemImage: "house") }
            PlanView().tabItem { Label("Plan", systemImage: "calendar") }
            TrackView().tabItem { Label("Track", systemImage: "list.bullet") }
            ProgressView().tabItem { Label("Progress", systemImage: "chart.bar") }
        }
    }
}

#Preview {
    MainTabView().environmentObject(AppContainer())
}
