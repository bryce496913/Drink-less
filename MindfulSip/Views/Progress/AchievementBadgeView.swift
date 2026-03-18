import SwiftUI

struct AchievementBadgeView: View {
    let achievement: Achievement

    var body: some View {
        VStack(spacing: 10) {
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(badgeGradient)
                    .overlay(
                        Circle()
                            .strokeBorder(strokeColor, lineWidth: achievement.isUnlocked ? 2 : 1)
                    )
                    .frame(width: 78, height: 78)
                    .shadow(color: achievement.isUnlocked ? AppTheme.accent.opacity(0.55) : .clear, radius: 10, y: 4)

                Text(achievement.emoji)
                    .font(.system(size: 30))

                Image(systemName: achievement.iconName)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(symbolColor)
                    .padding(6)
                    .background(.ultraThinMaterial.opacity(0.65), in: Circle())
                    .offset(x: 4, y: 4)
            }

            Text(achievement.title)
                .font(AppTheme.font(.caption, weight: .semibold))
                .foregroundStyle(AppTheme.text.opacity(achievement.isUnlocked ? 1 : 0.7))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)

            Text(achievement.isUnlocked ? "Unlocked" : "Locked")
                .font(AppTheme.font(.caption2))
                .foregroundStyle(achievement.isUnlocked ? AppTheme.highlight : AppTheme.text.opacity(0.45))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(cardBackground, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(strokeColor.opacity(0.8), lineWidth: 1)
        )
        .opacity(achievement.isUnlocked ? 1 : 0.68)
        .saturation(achievement.isUnlocked ? 1 : 0.15)
    }

    private var badgeGradient: LinearGradient {
        LinearGradient(
            colors: achievement.isUnlocked
                ? [Color(red: 0.83, green: 0.64, blue: 1.0), AppTheme.accent, Color(red: 0.39, green: 0.14, blue: 0.58)]
                : [Color(red: 0.29, green: 0.24, blue: 0.38), Color(red: 0.19, green: 0.16, blue: 0.26)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var cardBackground: LinearGradient {
        LinearGradient(
            colors: achievement.isUnlocked
                ? [AppTheme.surface.opacity(0.96), Color(red: 0.24, green: 0.11, blue: 0.36)]
                : [AppTheme.background.opacity(0.95), AppTheme.surface.opacity(0.8)],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private var strokeColor: Color {
        achievement.isUnlocked ? Color(red: 0.86, green: 0.73, blue: 1.0) : AppTheme.text.opacity(0.16)
    }

    private var symbolColor: Color {
        achievement.isUnlocked ? .white : AppTheme.text.opacity(0.65)
    }
}
