import Charts
import SwiftUI

struct ProgressView: View {
    @EnvironmentObject var container: AppContainer
    let analytics = AnalyticsService()
    let dateService = DateService()
    @State private var showDailyAchievements = false

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                let weekStart = dateService.startOfWeek(container.currentDate)
                let drinks = analytics.weeklyTotal(logs: container.logs, weekStart: weekStart, shouldIgnoreGoals: container.shouldIgnoreGoals(for:))
                let dryDays = analytics.weeklyDryDays(logs: container.logs, weekStart: weekStart, shouldIgnoreDryDayPenalty: container.shouldIgnoreDryDayPenalty(for:))
                let moneySpentWeek = drinks * container.profile.costPerDrink
                let caloriesWeek = drinks * container.profile.caloriesPerDrink
                let totalDrinks = container.logs.reduce(0) { $0 + $1.totalDrinks }
                let moneySpentTotal = totalDrinks * container.profile.costPerDrink
                let caloriesTotal = totalDrinks * container.profile.caloriesPerDrink
                let weeklyGoalStreak = analytics.weeklyGoalSuccessStreak(logs: container.logs, weeklyTarget: container.profile.weeklyTarget, setupDate: container.profile.createdAt, asOf: container.currentDate, shouldIgnoreGoals: container.shouldIgnoreGoals(for:))

                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .top, spacing: 12) {
                        VStack(alignment: .leading, spacing: 6) {
                            progressMetric(title: "This week", value: "\(String(format: "%.1f", drinks)) / \(container.profile.weeklyTarget)")
                            progressMetric(title: "Dry days", value: "\(dryDays) / \(container.profile.dryDaysTarget)")
                            progressMetric(title: "Money (week)", value: "$\(String(format: "%.0f", moneySpentWeek))")
                            progressMetric(title: "Goal streak", value: "\(weeklyGoalStreak) weeks")
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        VStack(alignment: .leading, spacing: 6) {
                            progressMetric(title: "Calories (week)", value: String(format: "%.0f", caloriesWeek))
                            progressMetric(title: "Money (total)", value: "$\(String(format: "%.0f", moneySpentTotal))")
                            progressMetric(title: "Calories (total)", value: String(format: "%.0f", caloriesTotal))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(10)
                    .background(AppTheme.background.opacity(0.55), in: RoundedRectangle(cornerRadius: 12))

                    Chart {
                        ForEach(dateService.weekDates(from: container.currentDate), id: \.self) { date in
                            let log = container.log(for: date)
                            let groupedEntries = Dictionary(grouping: log.entries.filter { $0.type != nil }, by: { $0.type! })

                            if groupedEntries.isEmpty {
                                BarMark(x: .value("Day", date, unit: .day), y: .value("Drinks", log.totalDrinks))
                                    .foregroundStyle(drinkTypeColor(.other))
                            } else {
                                ForEach(DrinkType.allCases) { type in
                                    let amount = groupedEntries[type]?.reduce(0) { $0 + $1.amount } ?? 0
                                    if amount > 0 {
                                        BarMark(x: .value("Day", date, unit: .day), y: .value("Drinks", amount))
                                            .foregroundStyle(drinkTypeColor(type))
                                    }
                                }
                            }
                        }
                    }
                    .frame(height: 180)

                    HStack(spacing: 10) {
                        ForEach(DrinkType.allCases) { type in
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(drinkTypeColor(type))
                                    .frame(width: 8, height: 8)
                                Text(type.rawValue.capitalized)
                                    .appTextStyle(.caption)
                            }
                        }
                    }

                    dailyAchievementsAccordion(
                        todayTotal: container.log(for: container.currentDate).totalDrinks,
                        dryStreak: analytics.dryStreak(logs: container.logs, shouldIgnoreDryDayPenalty: container.shouldIgnoreDryDayPenalty(for:)),
                        loggingStreak: analytics.loggingStreak(logs: container.logs),
                        weekTotal: drinks
                    )

                    let achievementService = AchievementService()
                    let achievementStats = achievementService.stats(logs: container.logs, today: container.currentDate)
                    let achievements = achievementService.achievements(logs: container.logs, today: container.currentDate)

                    AchievementsAccordionView(
                        achievements: achievements,
                        stats: achievementStats,
                        achievementService: achievementService
                    )
                }
                .appTextStyle(.body)
                .appTextColor(.primaryText)
                .padding()
                .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 18))
                .padding(.horizontal)
                .padding(.top, 12)
                .padding(.bottom, 24)
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .frame(minHeight: geometry.size.height, alignment: .top)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .background(AppTheme.background)
        .safeAreaInset(edge: .top, spacing: 0) {
            topHeaderBar
        }
        .appFullscreenContainer()
    }

    private func dailyAchievementsAccordion(todayTotal: Double, dryStreak: Int, loggingStreak: Int, weekTotal: Double) -> some View {
        let badges = dailyAchievementBadges(todayTotal: todayTotal, dryStreak: dryStreak, loggingStreak: loggingStreak, weekTotal: weekTotal)

        return DisclosureGroup(isExpanded: $showDailyAchievements) {
            VStack(alignment: .leading, spacing: 8) {
                if badges.isEmpty {
                    Text("Keep logging to unlock daily and weekly badges.")
                } else {
                    ForEach(badges, id: \.self) { badge in
                        Label(badge, systemImage: "rosette")
                    }
                }
            }
            .padding(.top, 8)
        } label: {
            Text("Daily Achievements")
                .accordionTitleStyle()
        }
        .appTextStyle(.body)
        .appTextColor(.secondaryText)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 16))
    }

    private func dailyAchievementBadges(todayTotal: Double, dryStreak: Int, loggingStreak: Int, weekTotal: Double) -> [String] {
        var badges: [String] = []
        if todayTotal == 0 { badges.append("Daily win: no drinks today") }
        if dryStreak >= 3 { badges.append("On fire: \(dryStreak)-day dry streak") }
        if loggingStreak >= 7 { badges.append("Consistency: logged \(loggingStreak) days") }
        if weekTotal <= Double(container.profile.weeklyTarget) { badges.append("Weekly goal is on track") }
        return badges
    }

    private func progressMetric(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(title)
                .statLabelStyle()
            Text(value)
                .appTextStyle(.body)
                .appTextColor(.highlightValue)
        }
    }

    private func drinkTypeColor(_ type: DrinkType) -> Color {
        switch type {
        case .wine:
            return Color(red: 0.8, green: 0.34, blue: 0.74)
        case .beer:
            return Color(red: 0.93, green: 0.65, blue: 0.28)
        case .spirits:
            return Color(red: 0.53, green: 0.46, blue: 0.93)
        case .cocktail:
            return Color(red: 0.24, green: 0.72, blue: 0.78)
        case .other:
            return AppTheme.highlight
        }
    }

    private var topHeaderBar: some View {
        VStack(spacing: 0) {
            Text("Progress")
                .pageTitleStyle()
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 16)
                .padding(.top, 6)
                .padding(.bottom, 10)

            Rectangle()
                .fill(AppTheme.highlight.opacity(0.2))
                .frame(height: 1)
        }
        .background(AppTheme.background.opacity(0.96))
    }

}

#Preview {
    ProgressView().environmentObject(AppContainer())
}
