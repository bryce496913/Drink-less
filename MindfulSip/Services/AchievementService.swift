import Foundation

struct AchievementService {
    private let analytics = AnalyticsService()
    private let dateService = DateService()

    func stats(logs: [DayLog], today: Date = .now) -> AchievementStats {
        AchievementStats(
            dryStreak: analytics.dryStreak(logs: logs, today: today),
            appUseStreak: analytics.loggingStreak(logs: logs, today: today),
            goalMetDays: goalMetDays(logs: logs, today: today)
        )
    }

    func achievements(logs: [DayLog], today: Date = .now) -> [Achievement] {
        let currentStats = stats(logs: logs, today: today)
        return Self.catalog.map { achievement in
            var updated = achievement
            updated.isUnlocked = currentStats.value(for: achievement.requirementType) >= achievement.requirementValue
            return updated
        }
    }

    func unlockedCount(for achievements: [Achievement]) -> Int {
        achievements.filter(\.isUnlocked).count
    }

    func progress(for achievement: Achievement, stats: AchievementStats) -> Int {
        min(stats.value(for: achievement.requirementType), achievement.requirementValue)
    }

    func goalMetDays(logs: [DayLog], today: Date = .now) -> Int {
        let todayStart = dateService.startOfDay(today)
        let uniqueLogs = Dictionary(uniqueKeysWithValues: logs.map { (dateService.startOfDay($0.date), $0) })

        return uniqueLogs.values.reduce(into: 0) { count, log in
            guard dateService.startOfDay(log.date) <= todayStart else { return }
            if log.totalDrinks <= log.plannedTargetDrinks {
                count += 1
            }
        }
    }

    static let catalog: [Achievement] = [
        Achievement(id: "first-step", title: "First Step", description: "Use the app for 1 day.", category: .appUseStreak, requirementType: .appUseStreak, requirementValue: 1, iconName: "figure.walk", emoji: "👣", isUnlocked: false),
        Achievement(id: "dry-start", title: "Dry Start", description: "Complete 1 dry day.", category: .dryStreak, requirementType: .dryStreak, requirementValue: 1, iconName: "drop", emoji: "💧", isUnlocked: false),
        Achievement(id: "goal-keeper", title: "Goal Keeper", description: "Meet your daily goal 1 time.", category: .goalMetDays, requirementType: .goalMetDays, requirementValue: 1, iconName: "checkmark.shield", emoji: "✅", isUnlocked: false),
        Achievement(id: "two-day-glow", title: "Two-Day Glow", description: "Use the app for 2 days in a row.", category: .appUseStreak, requirementType: .appUseStreak, requirementValue: 2, iconName: "sparkles", emoji: "✨", isUnlocked: false),
        Achievement(id: "steady-sip", title: "Steady Sip", description: "Meet your daily goal 3 times.", category: .goalMetDays, requirementType: .goalMetDays, requirementValue: 3, iconName: "checkmark.circle", emoji: "☕", isUnlocked: false),
        Achievement(id: "clear-day-duo", title: "Clear Day Duo", description: "Reach a 2-day dry streak.", category: .dryStreak, requirementType: .dryStreak, requirementValue: 2, iconName: "sun.max", emoji: "☀️", isUnlocked: false),
        Achievement(id: "showing-up", title: "Showing Up", description: "Use the app for 5 days in a row.", category: .appUseStreak, requirementType: .appUseStreak, requirementValue: 5, iconName: "calendar", emoji: "📅", isUnlocked: false),
        Achievement(id: "on-track", title: "On Track", description: "Meet your daily goal 5 times.", category: .goalMetDays, requirementType: .goalMetDays, requirementValue: 5, iconName: "flag", emoji: "🚩", isUnlocked: false),
        Achievement(id: "calm-momentum", title: "Calm Momentum", description: "Reach a 3-day dry streak.", category: .dryStreak, requirementType: .dryStreak, requirementValue: 3, iconName: "leaf", emoji: "🍃", isUnlocked: false),
        Achievement(id: "weekly-check-in", title: "Weekly Check-In", description: "Use the app for 7 days in a row.", category: .appUseStreak, requirementType: .appUseStreak, requirementValue: 7, iconName: "calendar.circle", emoji: "🗓️", isUnlocked: false),
        Achievement(id: "goal-streaker", title: "Goal Streaker", description: "Meet your daily goal 7 times.", category: .goalMetDays, requirementType: .goalMetDays, requirementValue: 7, iconName: "rosette", emoji: "🎖️", isUnlocked: false),
        Achievement(id: "fresh-rhythm", title: "Fresh Rhythm", description: "Reach a 5-day dry streak.", category: .dryStreak, requirementType: .dryStreak, requirementValue: 5, iconName: "moon.stars", emoji: "🌙", isUnlocked: false),
        Achievement(id: "strong-week", title: "Strong Week", description: "Use the app for 10 days in a row.", category: .appUseStreak, requirementType: .appUseStreak, requirementValue: 10, iconName: "checkmark.seal", emoji: "💪", isUnlocked: false),
        Achievement(id: "golden-balance", title: "Golden Balance", description: "Meet your daily goal 10 times.", category: .goalMetDays, requirementType: .goalMetDays, requirementValue: 10, iconName: "scalemass", emoji: "⚖️", isUnlocked: false),
        Achievement(id: "clear-mind", title: "Clear Mind", description: "Reach a 7-day dry streak.", category: .dryStreak, requirementType: .dryStreak, requirementValue: 7, iconName: "sunrise", emoji: "🌅", isUnlocked: false),
        Achievement(id: "daily-anchor", title: "Daily Anchor", description: "Use the app for 14 days in a row.", category: .appUseStreak, requirementType: .appUseStreak, requirementValue: 14, iconName: "anchor", emoji: "⚓", isUnlocked: false),
        Achievement(id: "promise-kept", title: "Promise Kept", description: "Meet your daily goal 14 times.", category: .goalMetDays, requirementType: .goalMetDays, requirementValue: 14, iconName: "heart.text.square", emoji: "🤝", isUnlocked: false),
        Achievement(id: "bright-stretch", title: "Bright Stretch", description: "Reach a 10-day dry streak.", category: .dryStreak, requirementType: .dryStreak, requirementValue: 10, iconName: "sparkle", emoji: "🌟", isUnlocked: false),
        Achievement(id: "habit-builder", title: "Habit Builder", description: "Use the app for 21 days in a row.", category: .appUseStreak, requirementType: .appUseStreak, requirementValue: 21, iconName: "square.stack.3d.up", emoji: "🧱", isUnlocked: false),
        Achievement(id: "goal-builder", title: "Goal Builder", description: "Meet your daily goal 21 times.", category: .goalMetDays, requirementType: .goalMetDays, requirementValue: 21, iconName: "stairs", emoji: "🪜", isUnlocked: false),
        Achievement(id: "clear-horizon", title: "Clear Horizon", description: "Reach a 14-day dry streak.", category: .dryStreak, requirementType: .dryStreak, requirementValue: 14, iconName: "sun.horizon", emoji: "🌄", isUnlocked: false),
        Achievement(id: "dedicated", title: "Dedicated", description: "Use the app for 30 days in a row.", category: .appUseStreak, requirementType: .appUseStreak, requirementValue: 30, iconName: "laurel.leading", emoji: "🏅", isUnlocked: false),
        Achievement(id: "in-control", title: "In Control", description: "Meet your daily goal 30 times.", category: .goalMetDays, requirementType: .goalMetDays, requirementValue: 30, iconName: "steeringwheel", emoji: "🎯", isUnlocked: false),
        Achievement(id: "calm-current", title: "Calm Current", description: "Reach a 21-day dry streak.", category: .dryStreak, requirementType: .dryStreak, requirementValue: 21, iconName: "water.waves", emoji: "🌊", isUnlocked: false),
        Achievement(id: "everyday-strength", title: "Everyday Strength", description: "Use the app for 45 days in a row.", category: .appUseStreak, requirementType: .appUseStreak, requirementValue: 45, iconName: "bolt.heart", emoji: "❤️", isUnlocked: false),
        Achievement(id: "true-north", title: "True North", description: "Meet your daily goal 45 times.", category: .goalMetDays, requirementType: .goalMetDays, requirementValue: 45, iconName: "location.north.line", emoji: "🧭", isUnlocked: false),
        Achievement(id: "clear-path", title: "Clear Path", description: "Reach a 30-day dry streak.", category: .dryStreak, requirementType: .dryStreak, requirementValue: 30, iconName: "road.lanes", emoji: "🛣️", isUnlocked: false),
        Achievement(id: "unshakeable", title: "Unshakeable", description: "Use the app for 60 days in a row.", category: .appUseStreak, requirementType: .appUseStreak, requirementValue: 60, iconName: "mountain.2", emoji: "⛰️", isUnlocked: false),
        Achievement(id: "goal-master", title: "Goal Master", description: "Meet your daily goal 60 times.", category: .goalMetDays, requirementType: .goalMetDays, requirementValue: 60, iconName: "crown", emoji: "👑", isUnlocked: false),
        Achievement(id: "mindful-legend", title: "Mindful Legend", description: "Reach a 45-day dry streak.", category: .dryStreak, requirementType: .dryStreak, requirementValue: 45, iconName: "flame", emoji: "🔥", isUnlocked: false)
    ]
}
