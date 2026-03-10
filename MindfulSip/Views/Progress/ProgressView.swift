import Charts
import SwiftUI

struct ProgressView: View {
    @EnvironmentObject var container: AppContainer
    let analytics = AnalyticsService()
    let dateService = DateService()

    var body: some View {
        GeometryReader { geometry in
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
                    HStack(alignment: .top, spacing: 12) {
                        VStack(alignment: .leading, spacing: 6) {
                            progressMetric(title: "This week", value: "\(String(format: "%.1f", drinks)) / \(container.profile.weeklyTarget)")
                            progressMetric(title: "Dry days", value: "\(dryDays) / \(container.profile.dryDaysTarget)")
                            progressMetric(title: "Money (week)", value: "$\(String(format: "%.0f", moneySpentWeek))")
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
                            BarMark(x: .value("Day", date, unit: .day), y: .value("Drinks", log.totalDrinks))
                                .foregroundStyle(AppTheme.highlight)
                        }
                    }
                    .frame(height: 180)

                    if container.logs.count >= 14 {
                        let insight = analytics.insights(logs: container.logs)
                        Text("Last 14 days: \(String(format: "%.1f", insight.last14)), previous: \(String(format: "%.1f", insight.previous14))")
                        Text("No-drink streak: \(insight.dryStreak) days")
                        Text("App-use streak: \(insight.loggingStreak) days")

                        Text("Achievements")
                            .font(AppTheme.font(.headline, weight: .semibold))
                        if insight.dryStreak >= 3 { Text("🏅 \(insight.dryStreak)-day dry streak") }
                        if insight.loggingStreak >= 7 { Text("🏅 \(insight.loggingStreak)-day app consistency") }
                        if drinks <= Double(container.profile.weeklyTarget) { Text("🏅 Weekly target met") }
                    }
                }
                .font(AppTheme.font(.callout))
                .foregroundStyle(AppTheme.text)
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

    private func progressMetric(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(title)
                .font(AppTheme.font(.caption2, weight: .medium))
                .foregroundStyle(AppTheme.text.opacity(0.7))
            Text(value)
                .font(AppTheme.font(.footnote, weight: .semibold))
                .foregroundStyle(AppTheme.text)
        }
    }

    private var topHeaderBar: some View {
        VStack(spacing: 0) {
            Text("Progress")
                .font(AppTheme.font(.headline, weight: .semibold))
                .foregroundStyle(AppTheme.text)
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
