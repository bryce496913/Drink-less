import SwiftUI

struct GuidanceView: View {
    @EnvironmentObject var container: AppContainer

    @State private var showDailySupport = false
    @State private var showAdvice = false
    @State private var showPraise = false
    @State private var showRecommendation = false

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
        "Try a reset routine: 1) hydrate 2) take a short walk 3) check your plan target for today."
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
                    Text("Guidance for \(container.profile.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Friend" : container.profile.name)")
                        .font(AppTheme.font(.title2, weight: .bold))
                        .foregroundStyle(AppTheme.text)

                    Text("Daily support and practical coaching based on your recent progress.")
                        .font(AppTheme.font(.footnote))
                        .foregroundStyle(AppTheme.text.opacity(0.9))

                    guidanceAccordion(title: "Daily Support", message: dailySupport, icon: "sun.max", isExpanded: $showDailySupport)
                    guidanceAccordion(title: "Advice", message: advice, icon: "lightbulb", isExpanded: $showAdvice)
                    guidanceAccordion(title: "Praise", message: praiseMessage, icon: "hands.clap", isExpanded: $showPraise)
                    guidanceAccordion(title: "Recommendation", message: recommendation, icon: "target", isExpanded: $showRecommendation)
                }
                .padding()
            }
            .background(AppTheme.background.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func guidanceAccordion(title: String, message: String, icon: String, isExpanded: Binding<Bool>) -> some View {
        DisclosureGroup(isExpanded: isExpanded) {
            Text(message)
                .font(AppTheme.font(.footnote))
                .foregroundStyle(AppTheme.text.opacity(0.95))
                .padding(.top, 8)
        } label: {
            Label(title, systemImage: icon)
                .font(AppTheme.font(.subheadline, weight: .semibold))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    GuidanceView().environmentObject(AppContainer())
}
