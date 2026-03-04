import Charts
import SwiftUI

struct ProgressView: View {
    @EnvironmentObject var container: AppContainer
    let analytics = AnalyticsService()
    let dateService = DateService()

    var body: some View {
        ScrollView {
            let weekStart = dateService.startOfWeek(.now)
            let drinks = analytics.weeklyTotal(logs: container.logs, weekStart: weekStart)
            let dryDays = analytics.weeklyDryDays(logs: container.logs, weekStart: weekStart)
            VStack(alignment: .leading, spacing: 16) {
                Text("This week: \(drinks, specifier: "%.1f") / \(container.profile.weeklyTarget)")
                Text("Dry days: \(dryDays) / \(container.profile.dryDaysTarget)")
                Text("Estimated money saved: $\(analytics.saved(actualWeekly: drinks, baselineWeekly: container.profile.baselineWeeklyDrinks, perDrink: container.profile.costPerDrink), specifier: "%.0f")")

                Chart {
                    ForEach(dateService.weekDates(from: .now), id: \.self) { date in
                        let log = container.loggingService.log(for: date)
                        BarMark(x: .value("Day", date, unit: .day), y: .value("Drinks", log.totalDrinks))
                            .foregroundStyle(AppTheme.highlight)
                    }
                }
                .frame(height: 180)

                if container.logs.count >= 14 {
                    let insight = analytics.insights(logs: container.logs)
                    Text("Last 14 days: \(insight.last14, specifier: "%.1f"), previous: \(insight.previous14, specifier: "%.1f")")
                    Text("Dry streak: \(insight.dryStreak) days")
                    Text("Logging streak: \(insight.loggingStreak) days")
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
