import SwiftUI

extension Notification.Name {
    static let openPlanTab = Notification.Name("openPlanTab")
}

enum AppTab: String, CaseIterable, Identifiable {
    case home
    case plan
    case track
    case progress
    case settings

    var id: String { rawValue }

    var title: String {
        switch self {
        case .home: return "Home"
        case .plan: return "Plan"
        case .track: return "Track"
        case .progress: return "Progress"
        case .settings: return "Settings"
        }
    }

    var icon: String {
        switch self {
        case .home: return "house"
        case .plan: return "calendar"
        case .track: return "calendar.badge.clock"
        case .progress: return "chart.bar"
        case .settings: return "gearshape"
        }
    }
}

struct MainTabView: View {
    @State private var selectedTab: AppTab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label(AppTab.home.title, systemImage: AppTab.home.icon)
                }
                .tag(AppTab.home)

            PlanView()
                .tabItem {
                    Label(AppTab.plan.title, systemImage: AppTab.plan.icon)
                }
                .tag(AppTab.plan)

            TrackView()
                .tabItem {
                    Label(AppTab.track.title, systemImage: AppTab.track.icon)
                }
                .tag(AppTab.track)

            ProgressView()
                .tabItem {
                    Label(AppTab.progress.title, systemImage: AppTab.progress.icon)
                }
                .tag(AppTab.progress)

            SettingsView()
                .tabItem {
                    Label(AppTab.settings.title, systemImage: AppTab.settings.icon)
                }
                .tag(AppTab.settings)
        }
        .onReceive(NotificationCenter.default.publisher(for: .openPlanTab)) { _ in
            selectedTab = .plan
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .appFullscreenContainer()
    }
}

#Preview {
    MainTabView().environmentObject(AppContainer())
}
