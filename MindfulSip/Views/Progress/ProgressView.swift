import Charts
import SwiftUI

struct ProgressView: View {
    @EnvironmentObject var container: AppContainer
    let analytics = AnalyticsService()
    let dateService = DateService()

    var body: some View {
        ScrollView {
            let weekStart = dateService.startOfWeek(container.currentDate)
            let drinks = analytics.weeklyTotal(logs: container.logs, weekStart: weekStart)
            let dryDays = analytics.weeklyDryDays(logs: container.logs, weekStart: weekStart)
            let moneySpentWeek = drinks * container.profile.costPerDrink
            let caloriesWeek = drinks * container.profile.caloriesPerDrink
            let totalDrinks = container.logs.reduce(0) { $0 + $1.totalDrinks }
            let moneySpentTotal = totalDrinks * container.profile.costPerDrink
            let caloriesTotal = totalDrinks * container.profile.caloriesPerDrink

            VStack(alignment: .leading, spacing: 16) {
                Text("This week: \(drinks, specifier: "%.1f") / \(container.profile.weeklyTarget)")
                Text("Dry days: \(dryDays) / \(container.profile.dryDaysTarget)")
                Text("Money spent this week: $\(moneySpentWeek, specifier: "%.0f")")
                Text("Calories drunk this week: \(caloriesWeek, specifier: "%.0f")")
                Text("Money spent total: $\(moneySpentTotal, specifier: "%.0f")")
                Text("Calories drunk total: \(caloriesTotal, specifier: "%.0f")")

                Chart {
                    ForEach(dateService.weekDates(from: container.currentDate), id: \.self) { date in
                        let log = container.log(for: date)
                        BarMark(x: .value("Day", date, unit: .day), y: .value("Drinks", log.totalDrinks))
                            .foregroundStyle(AppTheme.highlight)
                    }
                }
                .frame(height: 180)

                if container.logs.count >= 14 {
                    let insight = analytics.insights(logs: container.logs)
                    Text("Last 14 days: \(insight.last14, specifier: "%.1f"), previous: \(insight.previous14, specifier: "%.1f")")
                    Text("No-drink streak: \(insight.dryStreak) days")
                    Text("App-use streak: \(insight.loggingStreak) days")

                    Text("Achievements")
                        .font(AppTheme.font(.headline, weight: .semibold))
                    if insight.dryStreak >= 3 { Text("🏅 \(insight.dryStreak)-day dry streak") }
                    if insight.loggingStreak >= 7 { Text("🏅 \(insight.loggingStreak)-day app consistency") }
                    if drinks <= Double(container.profile.weeklyTarget) { Text("🏅 Weekly target met") }
                }
            }
            .font(AppTheme.font(.body))
            .foregroundStyle(AppTheme.text)
            .padding()
            .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 18))
            .padding()
        }
        .background(AppTheme.background.ignoresSafeArea())
        .navigationTitle("Progress")
    }
}

#Preview {
    ProgressView().environmentObject(AppContainer())
}
