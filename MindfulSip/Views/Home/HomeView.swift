import SwiftUI

struct HomeView: View {
    @EnvironmentObject var container: AppContainer
    @State private var amount: Double = 1

    private let analytics = AnalyticsService()

    private var todayLog: DayLog {
        container.log(for: .now)
    }

    private var weekStart: Date {
        analytics.dateService.startOfWeek(.now)
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

    private var moneySaved: Double {
        analytics.saved(actualWeekly: weekTotal, baselineWeekly: container.profile.baselineWeeklyDrinks, perDrink: container.profile.costPerDrink)
    }

    private var caloriesSaved: Double {
        max(0, (container.profile.baselineWeeklyDrinks - weekTotal) * container.profile.caloriesPerDrink)
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
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Mindful Sip")
                            .font(AppTheme.font(.title, weight: .bold))
                            .foregroundStyle(AppTheme.text)
                        Text("Today: \(todayLog.totalDrinks, specifier: "%.1f") drinks")
                            .font(AppTheme.font(.title3, weight: .medium))
                            .foregroundStyle(AppTheme.highlight)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    HStack(spacing: 10) {
                        StatPill(title: "Dry streak", value: "\(dryStreak) d")
                        StatPill(title: "App streak", value: "\(loggingStreak) d")
                    }

                    HStack(spacing: 10) {
                        StatPill(title: "Money saved", value: "$\(format(moneySaved, decimals: 0))")
                        StatPill(title: "Calories saved", value: format(caloriesSaved, decimals: 0))
                    }

                    VStack(spacing: 10) {
                        HStack {
                            ForEach([0.5, 1.0, 2.0, 3.0], id: \.self) { quick in
                                Button("+\(quick, specifier: "%.1f")") {
                                    container.updateDrinkTotal(date: .now, total: todayLog.totalDrinks + quick, delta: quick)
                                    amount = container.log(for: .now).totalDrinks
                                }
                                .buttonStyle(SecondaryButtonStyle())
                                .accessibilityLabel("Add \(format(quick, decimals: 1)) drinks")
                            }
                        }

                        Stepper("Set today total: \(amount, specifier: "%.1f")", value: $amount, in: 0 ... 20, step: 0.5)
                            .foregroundStyle(AppTheme.text)
                        Button("Save total") {
                            container.updateDrinkTotal(date: .now, total: amount)
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
                        Text(container.tipService.tip(for: .now))
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
