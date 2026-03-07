import SwiftUI

struct GuidanceView: View {
    @EnvironmentObject var container: AppContainer
    @State private var feeling = ""

    private var todayDrinks: Double {
        container.log(for: container.currentDate).totalDrinks
    }

    private var dailySupport: String {
        if todayDrinks == 0 {
            return "You’re on track today. Keep momentum by planning a relaxing evening without alcohol."
        }
        if todayDrinks <= 2 {
            return "You’re still in control today. Switch to water now and set a simple stop point for tonight."
        }
        return "Today has been tough, but you can still recover. Pause now and choose one healthy action for the next hour."
    }

    private var advice: String {
        feeling.isEmpty
            ? "Try a reset routine: 1) hydrate 2) take a short walk 3) check your plan target for today."
            : "You shared '\(feeling)'. Name the trigger, then replace the next drink decision with a 10-minute delay."
    }

    private var praiseMessage: String {
        let dryStreak = AnalyticsService().dryStreak(logs: container.logs)
        if dryStreak >= 3 {
            return "Amazing work — \(dryStreak) dry days in a row is real progress."
        }
        if todayDrinks == 0 {
            return "Great job staying alcohol-free today so far."
        }
        return "You showed up to track today, and that consistency matters."
    }

    private var recommendation: String {
        let weekly = AnalyticsService().weeklyTotal(logs: container.logs, weekStart: DateService().startOfWeek(container.currentDate))
        return weekly > Double(container.profile.weeklyTarget)
            ? "Recommendation: plan two alcohol-free days next week and enable evening reminders."
            : "Recommendation: keep your current plan and reward yourself with a healthy treat this weekend."
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    Text("Guidance")
                        .font(AppTheme.font(.title2, weight: .bold))
                        .foregroundStyle(AppTheme.text)

                    Text("Daily support and practical coaching based on your recent progress.")
                        .font(AppTheme.font(.body))
                        .foregroundStyle(AppTheme.text.opacity(0.9))

                    guidanceCard(title: "Daily support", message: dailySupport, icon: "sun.max")
                    guidanceCard(title: "Advice", message: advice, icon: "lightbulb")
                    guidanceCard(title: "Praise", message: praiseMessage, icon: "hands.clap")
                    guidanceCard(title: "Recommendation", message: recommendation, icon: "target")

                    VStack(alignment: .leading, spacing: 8) {
                        Text("How are you feeling?")
                            .font(AppTheme.font(.headline, weight: .semibold))
                        TextField("e.g. stressed, social pressure, craving", text: $feeling)
                            .textFieldStyle(.roundedBorder)
                    }
                    .padding(14)
                    .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 16))
                }
                .padding()
            }
            .background(AppTheme.background.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func guidanceCard(title: String, message: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon)
                .font(AppTheme.font(.headline, weight: .semibold))
            Text(message)
                .font(AppTheme.font(.body))
                .foregroundStyle(AppTheme.text.opacity(0.95))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    GuidanceView().environmentObject(AppContainer())
}
