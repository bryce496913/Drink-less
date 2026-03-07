import SwiftUI

struct HomeView: View {
    @EnvironmentObject var container: AppContainer
    @State private var amount: Double = 1

    private let analytics = AnalyticsService()

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
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    VStack(spacing: 8) {
                        Text("Mindful Sips")
                            .font(AppTheme.font(.title, weight: .bold))
                            .foregroundStyle(AppTheme.text)
                        Text("Today: \(todayLog.totalDrinks, specifier: "%.1f") drinks")
                            .font(AppTheme.font(.title3, weight: .medium))
                            .foregroundStyle(AppTheme.highlight)
                    }
                    .frame(maxWidth: .infinity)

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

                    VStack(spacing: 12) {
                        Text("Add drinks")
                            .font(AppTheme.font(.headline, weight: .semibold))
                            .foregroundStyle(AppTheme.text)

                        DrinkQuickAddGrid { delta in
                            container.updateDrinkTotal(date: container.currentDate, total: todayLog.totalDrinks + delta, delta: delta)
                            amount = container.log(for: container.currentDate).totalDrinks
                        }

                        Stepper("Set today total: \(amount, specifier: "%.1f")", value: $amount, in: 0 ... 20, step: 1)
                            .foregroundStyle(AppTheme.text)
                        Button("Save total") {
                            container.updateDrinkTotal(date: container.currentDate, total: amount)
                        }
                        .buttonStyle(PrimaryButtonStyle())
                    }
                    .padding(16)
                    .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 16))

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Daily achievements")
                            .font(AppTheme.font(.headline, weight: .semibold))
                        if achievementBadges.isEmpty {
                            Text("Keep logging to unlock daily and weekly badges.")
                        } else {
                            ForEach(achievementBadges, id: \.self) { badge in
                                Label(badge, systemImage: "rosette")
                            }
                        }
                    }
                    .font(AppTheme.font(.body))
                    .foregroundStyle(AppTheme.text.opacity(0.95))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 16))

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tip of the day")
                            .font(AppTheme.font(.headline, weight: .semibold))
                        Text(container.tipService.tip(for: container.currentDate))
                            .font(AppTheme.font(.body))
                            .foregroundStyle(AppTheme.text.opacity(0.9))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 16))

                    if todayLog.totalDrinks > todayLog.plannedTargetDrinks, todayLog.plannedTargetDrinks > 0 {
                        Text("You are above today’s target. Try water between drinks.")
                            .font(AppTheme.font(.footnote))
                            .foregroundStyle(AppTheme.text)
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(AppTheme.highlight.opacity(0.35), in: RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(.horizontal)
                .padding(.top, 6)
                .padding(.bottom, 24)
            }
            .background(AppTheme.background.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { NavigationLink("Settings", destination: SettingsView()) }
            .onAppear { amount = todayLog.totalDrinks }
        }
    }
}

private struct DrinkQuickAddGrid: View {
    let onAdd: (Double) -> Void

    private let options: [(title: String, icon: String, amount: Double)] = [
        ("Wine", "wineglass", 1.0),
        ("Beer", "mug", 1.0),
        ("Shot", "drop.fill", 0.5),
        ("Large beer", "waterbottle", 1.5),
        ("Cocktail", "cup.and.saucer", 1.5),
        ("Double mix", "2.circle", 2.0)
    ]

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
            ForEach(options, id: \.title) { option in
                Button {
                    onAdd(option.amount)
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: option.icon)
                            .font(.system(size: 18, weight: .semibold))
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
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {
    HomeView().environmentObject(AppContainer())
}
