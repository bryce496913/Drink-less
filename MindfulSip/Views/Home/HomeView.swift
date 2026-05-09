import SwiftUI

struct HomeView: View {
    @EnvironmentObject var container: AppContainer
    @State private var showStats = true
    @State private var showAddDrinks = false
    @State private var showTip = false
    @State private var showMondaySetupPrompt = false
    @State private var showWeeklyCelebration = false
    @State private var pendingMondaySetupPrompt = false
    @State private var drinkSupportMessage: DrinkSupportMessage?

    @AppStorage("lastWeeklySetupPromptWeekStart") private var lastWeeklySetupPromptWeekStart = ""
    @AppStorage("lastWeeklyCelebrationWeekStart") private var lastWeeklyCelebrationWeekStart = ""

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

    private var previousWeekStart: Date {
        Calendar.current.date(byAdding: .day, value: -7, to: weekStart) ?? weekStart
    }

    private var weekTotal: Double {
        analytics.weeklyTotal(logs: container.logs, weekStart: weekStart, shouldIgnoreGoals: container.shouldIgnoreGoals(for:))
    }

    private var previousWeekTotal: Double {
        analytics.weeklyTotal(logs: container.logs, weekStart: previousWeekStart, shouldIgnoreGoals: container.shouldIgnoreGoals(for:))
    }

    private var previousWeekHadActivity: Bool {
        let previousWeekDays = Set(analytics.dateService.weekDates(from: previousWeekStart).map(analytics.dateService.startOfDay))
        return container.logs.contains { log in
            previousWeekDays.contains(analytics.dateService.startOfDay(log.date)) && (log.totalDrinks > 0 || log.plannedTargetDrinks > 0)
        }
    }

    private var dryStreak: Int {
        analytics.dryStreak(logs: container.logs, shouldIgnoreDryDayPenalty: container.shouldIgnoreDryDayPenalty(for:))
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

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 14) {
                    VStack(spacing: 8) {
                        Text("Welcome, \(displayName)")
                            .pageTitleStyle()
                        Text("Today: \(todayLog.totalDrinks, specifier: "%.1f") drinks")
                            .appTextStyle(.body)
                            .appTextColor(.secondaryText)

                        HStack(spacing: 8) {
                            if container.settings.boozeModeEnabled {
                                modePill(text: "Booze Mode active", color: AppTheme.highlight)
                            }
                            if container.isHolidayModeActive {
                                modePill(text: "Holiday Mode active — tracking only", color: AppTheme.holiday)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)


                    if container.settings.boozeModeEnabled {
                        HStack(spacing: 10) {
                            Text("Quick logging for a big night out")
                                .appTextStyle(.body)
                                .appTextColor(.primaryText)
                            Spacer()
                            Button("Add Drink") {
                                addDrink(amount: 1, type: .other)
                            }
                            .buttonStyle(SecondaryButtonStyle())
                        }
                        .padding(12)
                        .background(AppTheme.highlight.opacity(0.25), in: RoundedRectangle(cornerRadius: 12))
                    }

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
                            .accordionTitleStyle()
                    }
                    .padding(16)
                    .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 16))

                    DisclosureGroup(isExpanded: $showAddDrinks) {
                        VStack(spacing: 12) {
                            DrinkQuickAddGrid { amountToAdd, type in
                                addDrink(amount: amountToAdd, type: type)
                            }
                        }
                        .padding(.top, 8)
                    } label: {
                        Text("Add Drinks")
                            .accordionTitleStyle()
                    }
                    .padding(16)
                    .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 16))

                    DisclosureGroup(isExpanded: $showTip) {
                        Text(container.tipService.tip(for: container.currentDate))
                            .appTextStyle(.body)
                            .appTextColor(.secondaryText)
                            .padding(.top, 8)
                    } label: {
                        Text("Tip of The Day")
                            .accordionTitleStyle()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 16))

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Daily guidance")
                            .sectionTitleStyle()
                        Text("Supportive coaching for today, moved here so it is available alongside your daily summary.")
                            .appTextStyle(.caption)
                            .appTextColor(.mutedText)
                        GuidanceAccordionsView(date: container.currentDate)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    if let reminderMessage = container.todaysReminderMessage {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Today’s reminder")
                                .sectionTitleStyle()
                            Text(reminderMessage)
                                .appTextStyle(.body)
                        }
                        .appTextColor(.primaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        .background(AppTheme.highlight.opacity(0.18), in: RoundedRectangle(cornerRadius: 12))
                    }

                    if container.isHolidayModeActive {
                        Text("Holiday Mode active — tracking only. Goals are paused during your holiday.")
                            .appTextStyle(.secondary)
                            .appTextColor(.primaryText)
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(AppTheme.holiday.opacity(0.35), in: RoundedRectangle(cornerRadius: 12))
                    } else if todayLog.totalDrinks > todayLog.plannedTargetDrinks, todayLog.plannedTargetDrinks > 0 {
                        Text("You are above today’s target. Try water between drinks, \(displayName).")
                            .appTextStyle(.secondary)
                            .appTextColor(.primaryText)
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
                .background(AppTheme.background)
                .onAppear {
                    handleMondayExperience()
                }
                .alert("Weekly planning time", isPresented: $showMondaySetupPrompt) {
                    Button("Go to Plan tab") {
                        NotificationCenter.default.post(name: .openPlanTab, object: nil)
                    }
                    Button("Later", role: .cancel) { }
                } message: {
                    Text("It is Monday. Set your weekly goal and assign daily drink targets for Monday through Sunday.")
                }
                .overlay(alignment: .top) {
                    VStack(spacing: 8) {
                        if let drinkSupportMessage {
                            InAppSupportBanner(message: drinkSupportMessage)
                                .transition(.move(edge: .top).combined(with: .opacity))
                        }

                        if showWeeklyCelebration {
                            bannerCard(
                                message: "Amazing work last week. You stayed on plan and gave your future self a strong start.",
                                title: "🎉 Weekly goal complete!",
                                systemImage: "sparkles",
                                background: AppTheme.highlight
                            )
                            .transition(.move(edge: .top).combined(with: .opacity))
                        }
                    }
                }
                .appFullscreenContainer()
        }
    }

    private func handleMondayExperience() {
        let currentDay = analytics.dateService.startOfDay(container.currentDate)
        let thisWeekKey = analytics.dateService.startOfDay(weekStart).formatted(date: .numeric, time: .omitted)
        let isMonday = Calendar.current.component(.weekday, from: currentDay) == 2
        guard isMonday else { return }

        let shouldPromptForSetup = lastWeeklySetupPromptWeekStart != thisWeekKey

        let previousWeekComplete = previousWeekTotal <= Double(container.profile.weeklyTarget)
        if lastWeeklyCelebrationWeekStart != thisWeekKey, previousWeekHadActivity, previousWeekComplete {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                showWeeklyCelebration = true
            }
            lastWeeklyCelebrationWeekStart = thisWeekKey

            if shouldPromptForSetup {
                pendingMondaySetupPrompt = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                withAnimation(.easeOut(duration: 0.25)) {
                    showWeeklyCelebration = false
                }

                if pendingMondaySetupPrompt {
                    showMondaySetupPrompt = true
                    lastWeeklySetupPromptWeekStart = thisWeekKey
                    pendingMondaySetupPrompt = false
                }
            }
        } else if shouldPromptForSetup {
            showMondaySetupPrompt = true
            lastWeeklySetupPromptWeekStart = thisWeekKey
        }
    }

    private func addDrink(amount: Double, type: DrinkType) {
        let currentLog = todayLog
        let previousTotal = currentLog.totalDrinks
        container.updateDrinkTotal(
            date: container.currentDate,
            total: previousTotal + amount,
            type: type,
            delta: amount
        )
        let updatedLog = container.log(for: container.currentDate)
        showDrinkSupportMessageIfNeeded(previousLog: currentLog, updatedTotal: updatedLog.totalDrinks)
    }

    private func showDrinkSupportMessageIfNeeded(previousLog: DayLog, updatedTotal: Double) {
        guard !container.shouldIgnoreGoals(for: previousLog.date),
              let message = DrinkSupportMessageProvider.message(
                previousTotal: previousLog.totalDrinks,
                updatedTotal: updatedTotal,
                target: previousLog.plannedTargetDrinks,
                isDryDay: previousLog.isDryPlanned
              ) else { return }

        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
            drinkSupportMessage = message
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) {
            withAnimation(.easeOut(duration: 0.25)) {
                drinkSupportMessage = nil
            }
        }
    }

    private func modePill(text: String, color: Color) -> some View {
        Text(text)
            .appTextStyle(.caption)
            .appTextColor(.primaryText)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(color.opacity(0.35), in: Capsule())
    }

    private func bannerCard(message: String, title: String? = nil, systemImage: String, background: Color) -> some View {
        VStack(spacing: 8) {
            if let title {
                Label(title, systemImage: systemImage)
                    .appTextStyle(.sectionTitle)
            } else {
                Label("Target reached", systemImage: systemImage)
                    .appTextStyle(.sectionTitle)
            }
            Text(message)
                .appTextStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .appTextColor(.primaryText)
        .padding(14)
        .background(background, in: RoundedRectangle(cornerRadius: 14))
        .padding(.top, 12)
        .padding(.horizontal, 20)
    }
}

private struct DrinkQuickAddGrid: View {
    let onAdd: (Double, DrinkType) -> Void

    private let options: [(title: String, icon: String)] = [
        ("Wine", "🍷"),
        ("Beer", "🍺"),
        ("Shot", "🥃"),
        ("Large Beer", "🍺"),
        ("Cocktail", "🍸"),
        ("Double Shot", "🥃")
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
                    onAdd(1, drinkType(for: option.title))
                } label: {
                    VStack(spacing: 4) {
                        Text(option.icon)
                            .font(.system(size: 21))
                        Text(option.title)
                            .statLabelStyle()
                            .multilineTextAlignment(.center)
                        Text("+1")
                            .appTextStyle(.caption)
                            .appTextColor(.highlightValue)
                    }
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
                .statLabelStyle()
            Text(value)
                .statValueStyle()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(AppTheme.background.opacity(0.45), in: RoundedRectangle(cornerRadius: 14))
    }
}


struct DrinkSupportMessage {
    let title: String
    let body: String
    let systemImage: String
    let background: Color
}

enum DrinkSupportMessageProvider {
    private static let resetMessages: [String] = [
        "This was planned as a dry day. That’s okay — the next choice still matters.",
        "Today was meant to be a dry day. Be kind to yourself and try to reset from here.",
        "A dry day did not go to plan, and that happens. You can still make the rest of today count.",
        "No shame, just awareness. Try to make your next choice one that supports you.",
        "This was a dry day goal, but the day is not lost. One mindful choice can still change the tone of the night.",
        "It did not go exactly to plan today. Take a breath and see if you can steady things from here.",
        "A tough moment does not undo your progress. Try to get back to your goal with the next decision.",
        "This was meant to be a dry day. Be gentle with yourself and aim for a better next step.",
        "One off-plan drink does not define the day. You still have time to make today better.",
        "You are still allowed to reset. Let this be a pause, not a reason to give up on the day."
    ]

    private static let limitReachedMessages: [String] = [
        "You’ve hit your plan for today — a great place to pause and protect tomorrow.",
        "Nice work sticking to your number so far. This is your moment to hold the line.",
        "You’ve reached today’s limit. Staying here is a win.",
        "You planned this number for a reason — trust that choice.",
        "You’re exactly where you meant to be today. Keep that momentum going by stopping here.",
        "Goal reached. A pause now can turn a good night into a proud one.",
        "You’ve met your plan for today — now is a strong time to stop.",
        "This is a solid stopping point. You’re doing what you said you would do.",
        "You made a plan and followed it. That kind of consistency matters.",
        "Today’s limit is reached. Take a breath, check in, and back your goal."
    ]

    static func message(previousTotal: Double, updatedTotal: Double, target: Double, isDryDay: Bool) -> DrinkSupportMessage? {
        if isDryDay {
            return resetMessage(title: "Dry day reset")
        }

        if target > 0, previousTotal <= target, updatedTotal > target {
            return resetMessage(title: "Reset from here")
        }

        if target > 0, previousTotal < target, updatedTotal == target {
            return DrinkSupportMessage(
                title: "Limit reached",
                body: limitReachedMessages.randomElement() ?? limitReachedMessages[0],
                systemImage: "checkmark.seal.fill",
                background: AppTheme.accent.opacity(0.9)
            )
        }

        return nil
    }

    private static func resetMessage(title: String) -> DrinkSupportMessage {
        DrinkSupportMessage(
            title: title,
            body: resetMessages.randomElement() ?? resetMessages[0],
            systemImage: "heart.circle.fill",
            background: AppTheme.highlight.opacity(0.9)
        )
    }
}

struct InAppSupportBanner: View {
    let message: DrinkSupportMessage

    var body: some View {
        VStack(spacing: 8) {
            Label(message.title, systemImage: message.systemImage)
                .appTextStyle(.sectionTitle)
            Text(message.body)
                .appTextStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .appTextColor(.primaryText)
        .padding(14)
        .background(message.background, in: RoundedRectangle(cornerRadius: 14))
        .padding(.top, 12)
        .padding(.horizontal, 20)
    }
}

#Preview {
    HomeView().environmentObject(AppContainer())
}
