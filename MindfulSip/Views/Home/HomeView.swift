import SwiftUI

struct HomeView: View {
    @EnvironmentObject var container: AppContainer
    @State private var amount: Double = 1
    @State private var showStats = true
    @State private var showAddDrinks = false
    @State private var showAchievements = false
    @State private var showTip = false

    private let analytics = AnalyticsService()

    private var displayName: String {
        let trimmed = container.profile.name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Friend" : trimmed
    }

    private var todayLog: DayLog {
        container.log(for: container.currentDate)
    }

    private var weekStart: Date {
        analytics.dateService.startOfWeek(container.currentDate)
    }

    private var weekTotal: Double {
        analytics.weeklyTotal(logs: container.logs, weekStart: weekStart)
    }

    private var dryStreak: Int {
        analytics.dryStreak(logs: container.logs)
    }

    private var loggingStreak: Int {
        analytics.loggingStreak(logs: container.logs)
    }

    private var moneySpentWeek: Double {
        weekTotal * container.profile.costPerDrink
    }

    private var caloriesWeek: Double {
        weekTotal * container.profile.caloriesPerDrink
    }

    private var grandTotalDrinks: Double {
        container.logs.reduce(0) { $0 + $1.totalDrinks }
    }

    private var moneySpentTotal: Double {
        grandTotalDrinks * container.profile.costPerDrink
    }

    private var caloriesTotal: Double {
        grandTotalDrinks * container.profile.caloriesPerDrink
    }

    private func format(_ value: Double, decimals: Int) -> String {
        value.formatted(.number.precision(.fractionLength(decimals)))
    }

    private var achievementBadges: [String] {
        var badges: [String] = []
        if todayLog.totalDrinks == 0 { badges.append("Daily win: no drinks today") }
        if dryStreak >= 3 { badges.append("On fire: \(dryStreak)-day dry streak") }
        if loggingStreak >= 7 { badges.append("Consistency: logged \(loggingStreak) days") }
        if weekTotal <= Double(container.profile.weeklyTarget) { badges.append("Weekly goal is on track") }
        return badges
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 14) {
                    VStack(spacing: 8) {
                        Text("Welcome, \(displayName)")
                            .font(AppTheme.font(.title, weight: .bold))
                            .foregroundStyle(AppTheme.text)
                        Text("Today: \(todayLog.totalDrinks, specifier: "%.1f") drinks")
                            .font(AppTheme.font(.title3, weight: .medium))
                            .foregroundStyle(AppTheme.highlight)
                    }
                    .frame(maxWidth: .infinity)

                    DisclosureGroup(isExpanded: $showStats) {
                        VStack(spacing: 10) {
                            HStack(spacing: 10) {
                                StatPill(title: "Dry streak", value: "\(dryStreak) d")
                                StatPill(title: "App streak", value: "\(loggingStreak) d")
                            }

                            HStack(spacing: 10) {
                                StatPill(title: "Money spent (week)", value: "$\(format(moneySpentWeek, decimals: 0))")
                                StatPill(title: "Calories drunk (week)", value: format(caloriesWeek, decimals: 0))
                            }

                            HStack(spacing: 10) {
                                StatPill(title: "Money spent (total)", value: "$\(format(moneySpentTotal, decimals: 0))")
                                StatPill(title: "Calories drunk (total)", value: format(caloriesTotal, decimals: 0))
                            }
                        }
                        .padding(.top, 8)
                    } label: {
                        Text("Stats")
                            .font(AppTheme.font(.headline, weight: .semibold))
                            .foregroundStyle(AppTheme.text)
                    }
                    .padding(16)
                    .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 16))

                    DisclosureGroup(isExpanded: $showAddDrinks) {
                        VStack(spacing: 12) {
                            DrinkQuickAddGrid { amountToAdd, type in
                                container.updateDrinkTotal(
                                    date: container.currentDate,
                                    total: todayLog.totalDrinks + amountToAdd,
                                    type: type,
                                    delta: amountToAdd
                                )
                                amount = container.log(for: container.currentDate).totalDrinks
                            }

                            Stepper("Set today total: \(amount, specifier: "%.1f")", value: $amount, in: 0 ... 20, step: 1)
                                .foregroundStyle(AppTheme.text)
                            Button("Save total") {
                                container.updateDrinkTotal(date: container.currentDate, total: amount)
                            }
                            .buttonStyle(PrimaryButtonStyle())
                        }
                        .padding(.top, 8)
                    } label: {
                        Text("Add Drinks")
                            .font(AppTheme.font(.headline, weight: .semibold))
                            .foregroundStyle(AppTheme.text)
                    }
                    .padding(16)
                    .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 16))

                    DisclosureGroup(isExpanded: $showAchievements) {
                        VStack(alignment: .leading, spacing: 8) {
                            if achievementBadges.isEmpty {
                                Text("Keep logging to unlock daily and weekly badges.")
                            } else {
                                ForEach(achievementBadges, id: \.self) { badge in
                                    Label(badge, systemImage: "rosette")
                                }
                            }
                        }
                        .padding(.top, 8)
                    } label: {
                        Text("Daily Achievements")
                            .font(AppTheme.font(.headline, weight: .semibold))
                    }
                    .font(AppTheme.font(.body))
                    .foregroundStyle(AppTheme.text.opacity(0.95))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 16))

                    DisclosureGroup(isExpanded: $showTip) {
                        Text(container.tipService.tip(for: container.currentDate))
                            .font(AppTheme.font(.body))
                            .foregroundStyle(AppTheme.text.opacity(0.9))
                            .padding(.top, 8)
                    } label: {
                        Text("Tip of The Day")
                            .font(AppTheme.font(.headline, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 16))

                    if todayLog.totalDrinks > todayLog.plannedTargetDrinks, todayLog.plannedTargetDrinks > 0 {
                        Text("You are above today’s target. Try water between drinks, \(displayName).")
                            .font(AppTheme.font(.footnote))
                            .foregroundStyle(AppTheme.text)
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(AppTheme.highlight.opacity(0.35), in: RoundedRectangle(cornerRadius: 12))
                    }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 24)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: geometry.size.height, alignment: .top)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .background(AppTheme.background.edgesIgnoringSafeArea(.all))
                .onAppear { amount = todayLog.totalDrinks }
                .appFullscreenContainer()
        }
    }
}

private struct DrinkQuickAddGrid: View {
    let onAdd: (Double, DrinkType) -> Void

    private let options: [(title: String, icon: String, amount: Double)] = [
        ("Wine", "🍷", 1.0),
        ("Beer", "🍺", 1.0),
        ("Shot", "🥃", 0.5),
        ("Large Beer", "🍺", 1.5),
        ("Cocktail", "🍸", 1.5),
        ("Double Shot", "🥃", 2.0)
    ]

    private func drinkType(for title: String) -> DrinkType {
        switch title {
        case "Wine":
            return .wine
        case "Beer", "Large Beer":
            return .beer
        case "Shot", "Double Shot":
            return .spirits
        case "Cocktail":
            return .cocktail
        default:
            return .other
        }
    }

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
            ForEach(options, id: \.title) { option in
                Button {
                    onAdd(option.amount, drinkType(for: option.title))
                } label: {
                    VStack(spacing: 4) {
                        Text(option.icon)
                            .font(.system(size: 21))
                        Text(option.title)
                            .font(AppTheme.font(.caption, weight: .semibold))
                            .multilineTextAlignment(.center)
                        Text("+\(option.amount, specifier: "%.1f")")
                            .font(AppTheme.font(.caption2))
                    }
                    .foregroundStyle(AppTheme.text)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(AppTheme.background.opacity(0.6), in: RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }
        }
    }
}

private struct StatPill: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(AppTheme.font(.footnote))
                .foregroundStyle(AppTheme.text.opacity(0.8))
            Text(value)
                .font(AppTheme.font(.headline, weight: .bold))
                .foregroundStyle(AppTheme.highlight)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(AppTheme.background.opacity(0.45), in: RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {
    HomeView().environmentObject(AppContainer())
}
