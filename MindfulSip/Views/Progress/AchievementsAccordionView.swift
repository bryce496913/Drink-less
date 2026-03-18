import SwiftUI

struct AchievementsAccordionView: View {
    let achievements: [Achievement]
    let stats: AchievementStats
    let achievementService: AchievementService

    @State private var isExpanded = false
    @State private var selectedAchievement: Achievement?

    private let columns = [GridItem(.adaptive(minimum: 110, maximum: 140), spacing: 12)]

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            VStack(alignment: .leading, spacing: 14) {
                LazyVGrid(columns: columns, alignment: .leading, spacing: 12) {
                    ForEach(achievements) { achievement in
                        Button {
                            selectedAchievement = achievement
                        } label: {
                            AchievementBadgeView(achievement: achievement)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.top, 12)
        } label: {
            HStack(alignment: .center, spacing: 12) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [AppTheme.accent, Color(red: 0.49, green: 0.23, blue: 0.73)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 42, height: 42)
                    Text("🏆")
                        .font(.system(size: 20))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Achievements")
                        .font(AppTheme.font(.headline, weight: .semibold))
                        .foregroundStyle(AppTheme.text)
                    Text("\(achievementService.unlockedCount(for: achievements)) of \(achievements.count) unlocked")
                        .font(AppTheme.font(.caption))
                        .foregroundStyle(AppTheme.highlight)
                }

                Spacer()
            }
        }
        .tint(AppTheme.text)
        .padding(14)
        .background(
            LinearGradient(
                colors: [Color(red: 0.15, green: 0.06, blue: 0.25), Color(red: 0.09, green: 0.03, blue: 0.16)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 18, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(AppTheme.accent.opacity(0.4), lineWidth: 1)
        )
        .sheet(item: $selectedAchievement) { achievement in
            AchievementDetailPopupView(
                achievement: achievement,
                stats: stats,
                progressValue: achievementService.progress(for: achievement, stats: stats)
            )
        }
    }

}
