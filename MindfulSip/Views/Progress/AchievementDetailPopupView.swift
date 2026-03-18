import SwiftUI

struct AchievementDetailPopupView: View {
    let achievement: Achievement
    let stats: AchievementStats
    let progressValue: Int

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 18) {
                VStack(spacing: 12) {
                    ZStack(alignment: .bottomTrailing) {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: achievement.isUnlocked
                                        ? [Color(red: 0.84, green: 0.66, blue: 1.0), AppTheme.accent, Color(red: 0.44, green: 0.17, blue: 0.63)]
                                        : [Color(red: 0.27, green: 0.23, blue: 0.35), Color(red: 0.18, green: 0.15, blue: 0.24)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 120, height: 120)
                            .overlay(Circle().stroke(Color.white.opacity(achievement.isUnlocked ? 0.45 : 0.15), lineWidth: 1.5))
                            .shadow(color: achievement.isUnlocked ? AppTheme.accent.opacity(0.5) : .clear, radius: 14, y: 8)

                        Text(achievement.emoji)
                            .font(.system(size: 54))

                        Image(systemName: achievement.iconName)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(10)
                            .background(AppTheme.surface.opacity(0.78), in: Circle())
                            .offset(x: 6, y: 6)
                    }

                    Text(achievement.title)
                        .font(AppTheme.font(.headline, weight: .semibold))
                        .foregroundStyle(AppTheme.text)

                    Text(achievement.isUnlocked ? "Unlocked" : "Locked")
                        .font(AppTheme.font(.caption, weight: .semibold))
                        .foregroundStyle(achievement.isUnlocked ? AppTheme.highlight : AppTheme.text.opacity(0.6))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(AppTheme.background.opacity(0.6), in: Capsule())
                }

                VStack(alignment: .leading, spacing: 12) {
                    detailRow(title: "How to earn it", value: achievement.description)
                    detailRow(title: "Category", value: categoryLabel)
                    detailRow(title: "Progress", value: "\(progressValue) of \(achievement.requirementValue)")
                    detailRow(title: "Current stats", value: "Dry streak: \(stats.dryStreak) • App-use streak: \(stats.appUseStreak) • Goal met days: \(stats.goalMetDays)")
                }
                .padding(14)
                .background(AppTheme.background.opacity(0.45), in: RoundedRectangle(cornerRadius: 16, style: .continuous))

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 28)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(AppTheme.surface.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(AppTheme.highlight)
                }
            }
        }
        .presentationDetents([.fraction(0.58), .medium, .large])
        .presentationDragIndicator(.visible)
    }

    private func detailRow(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(AppTheme.font(.caption2))
                .foregroundStyle(AppTheme.text.opacity(0.72))
            Text(value)
                .font(AppTheme.font(.body))
                .foregroundStyle(AppTheme.text)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var categoryLabel: String {
        switch achievement.category {
        case .dryStreak:
            return "Dry streak"
        case .appUseStreak:
            return "App-use streak"
        case .goalMetDays:
            return "Goal met days"
        }
    }
}
