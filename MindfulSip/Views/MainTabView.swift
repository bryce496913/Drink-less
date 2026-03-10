import SwiftUI

enum AppTab: String, CaseIterable, Identifiable {
    case home
    case plan
    case track
    case progress
    case guidance

    var id: String { rawValue }

    var title: String {
        switch self {
        case .home: return "Home"
        case .plan: return "Plan"
        case .track: return "Track"
        case .progress: return "Progress"
        case .guidance: return "Guidance"
        }
    }

    var icon: String {
        switch self {
        case .home: return "house"
        case .plan: return "calendar"
        case .track: return "calendar.badge.clock"
        case .progress: return "chart.bar"
        case .guidance: return "heart.text.square"
        }
    }
}

struct MainTabShellView: View {
    static let bottomBarContentHeight: CGFloat = 62
    static let bottomBarReservedSpace: CGFloat = 94

    @State private var selectedTab: AppTab = .home

    var body: some View {
        ZStack(alignment: .bottom) {
            AppTheme.background
                .ignoresSafeArea()

            activeTabView
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

            CustomBottomNavigationBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(.container, edges: [.top, .bottom])
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    @ViewBuilder
    private var activeTabView: some View {
        switch selectedTab {
        case .home:
            HomeView()
        case .plan:
            PlanView()
        case .track:
            TrackView()
        case .progress:
            ProgressView()
        case .guidance:
            GuidanceView()
        }
    }
}

struct CustomBottomNavigationBar: View {
    @Binding var selectedTab: AppTab

    var body: some View {
        HStack(spacing: 4) {
            ForEach(AppTab.allCases) { tab in
                Button {
                    selectedTab = tab
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 17, weight: .semibold))
                        Text(tab.title)
                            .font(AppTheme.font(.caption, weight: .medium))
                    }
                    .foregroundStyle(selectedTab == tab ? AppTheme.text : AppTheme.highlight)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .padding(.top, 10)
        .padding(.bottom, 8)
        .frame(maxWidth: .infinity)
        .frame(minHeight: MainTabShellView.bottomBarContentHeight, alignment: .top)
        .background(AppTheme.surface.ignoresSafeArea(edges: .bottom))
        .overlay(alignment: .top) {
            Rectangle()
                .fill(AppTheme.highlight.opacity(0.2))
                .frame(height: 1)
        }
    }
}

struct MainTabView: View {
    var body: some View {
        MainTabShellView()
    }
}

#Preview {
    MainTabView().environmentObject(AppContainer())
}
