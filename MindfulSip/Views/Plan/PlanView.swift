import SwiftUI

struct PlanView: View {
    @EnvironmentObject var container: AppContainer
    private let dateService = DateService()

    @State private var dryDays: Set<Int> = []
    @State private var targets: [Double] = Array(repeating: 0, count: 7)
    @State private var isDailyTargetsExpanded = true

    private var weekDates: [Date] { dateService.weekDates(from: container.currentDate) }
    private var today: Date { dateService.startOfDay(container.currentDate) }

    private var plannedTotal: Double { targets.reduce(0, +) }
    private var remaining: Double { max(0, Double(container.profile.weeklyTarget) - plannedTotal) }
    private var isPlanLocked: Bool { !canEditPlan }
    private var canEditPlan: Bool { container.canEditWeeklyPlan }
    private var weekRangeLabel: String {
        guard let weekStart = weekDates.first, let weekEnd = weekDates.last else {
            return "Monday - Sunday"
        }
        return "Monday - Sunday • \(weekStart.formatted(date: .abbreviated, time: .omitted)) to \(weekEnd.formatted(date: .abbreviated, time: .omitted))"
    }

    private var displayName: String {
        let trimmed = container.profile.name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Friend" : trimmed
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 14) {
                    planHeader
                    weeklySummary
                    dailyTargetsSection
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
                .frame(maxWidth: .infinity)
                .frame(minHeight: geometry.size.height, alignment: .top)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .background(AppTheme.background)
        .safeAreaInset(edge: .top, spacing: 0) {
            planHeaderBar
        }
        .onAppear(perform: loadWeek)
        .appFullscreenContainer()
    }

    private var planHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Weekly planning")
                .pageTitleStyle()

            Text("Set daily limits and dry days. Your total is auto-capped to your weekly target.")
                .bodyTextStyle()
                .opacity(0.82)
                .fixedSize(horizontal: false, vertical: true)

            Text(weekRangeLabel)
                .appTextStyle(.caption)
                .appTextColor(.accentHeading)

            if container.isHolidayModeActive {
                Text("Holiday Mode active — tracking only. Goals are paused during your holiday.")
                    .appTextStyle(.caption)
                    .appTextColor(.primaryText)
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppTheme.holiday.opacity(0.3), in: RoundedRectangle(cornerRadius: 10))
            }

            Button("Auto-distribute my target") {
                targets = container.planService.distributeTarget(weeklyTarget: container.profile.weeklyTarget, dryDayIndexes: dryDays)
                persist()
            }
            .buttonStyle(SecondaryButtonStyle())
            .disabled(isPlanLocked)

            if isPlanLocked {
                Text("Your weekly plan is locked until next Monday to help you stay accountable.")
                    .appTextStyle(.caption)
                    .appTextColor(.mutedText)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 16))
    }

    private var weeklySummary: some View {
        VStack(spacing: 10) {
            if container.isHolidayModeActive {
                Text("Tracking only — goals paused")
                    .appTextStyle(.caption)
                    .appTextColor(.primaryText)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(AppTheme.holiday.opacity(0.3), in: Capsule())
            }

            HStack(spacing: 10) {
                planStat(title: "Weekly target", value: "\(container.profile.weeklyTarget)")
                planStat(title: "Dry day goal", value: "\(container.profile.dryDaysTarget)")
            }
            HStack(spacing: 10) {
                planStat(title: "Planned", value: "\(Int(plannedTotal))")
                planStat(title: "Remaining", value: "\(Int(remaining))")
            }
        }
    }

    private var dailyTargetsSection: some View {
        DisclosureGroup(isExpanded: $isDailyTargetsExpanded) {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(Array(weekDates.enumerated()), id: \.offset) { index, date in
                    dayRow(index: index, date: date)
                    if index < weekDates.count - 1 {
                        Divider()
                            .overlay(AppTheme.highlight.opacity(0.3))
                            .padding(.horizontal, 8)
                    }
                }
            }
            .padding(.top, 8)
        } label: {
            Text("Daily targets")
                .accordionTitleStyle()
        }
        .padding(14)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 14))
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func dayRow(index: Int, date: Date) -> some View {
        let dayLog = container.log(for: date)
        let isHolidayDate = container.isDateInHolidayRange(date)

        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(date.formatted(.dateTime.weekday(.wide)))
                        .sectionTitleStyle()
                    Text(date.formatted(date: .abbreviated, time: .omitted))
                        .appTextStyle(.caption)
                        .appTextColor(.mutedText)
                }
                Spacer()
                Toggle("Dry", isOn: Binding(get: { dryDays.contains(index) }, set: { isDry in
                    if isDry {
                        dryDays.insert(index)
                        targets[index] = 0
                    } else {
                        dryDays.remove(index)
                    }
                    persist(index)
                }))
                .labelsHidden()
                .tint(AppTheme.highlight)
                .disabled(isPlanLocked || isHolidayDate)
            }

            if isHolidayDate {
                Text("Tracking only — goals paused")
                    .appTextStyle(.caption)
                    .appTextColor(.primaryText)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(AppTheme.holiday.opacity(0.3), in: Capsule())
            }

            HStack(spacing: 10) {
                planStat(title: "Logged", value: "\(Int(dayLog.totalDrinks))")
                planStat(title: "Target", value: "\(Int(targets[index]))")
            }

            if isFutureDate(date) {
                Text("Future dates can be planned now and logged later.")
                    .appTextStyle(.caption)
                    .appTextColor(.mutedText)
            }

            Stepper(value: Binding(get: { targets[index] }, set: { newValue in
                targets[index] = max(0, newValue)
                if targets[index] > 0 {
                    dryDays.remove(index)
                }
                persist(index)
            }), in: 0 ... 20, step: 1) {
                Text("Adjust daily target")
                    .bodyTextStyle()
            }
            .disabled(isPlanLocked || isHolidayDate)
        }
        .padding(14)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 14))
    }

    private func isFutureDate(_ date: Date) -> Bool {
        dateService.startOfDay(date) > today
    }

    private func planStat(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .statLabelStyle()
            Text(value)
                .statValueStyle()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(AppTheme.background.opacity(0.45), in: RoundedRectangle(cornerRadius: 12))
    }

    private func loadWeek() {
        let currentDryDays = weekDates.enumerated().compactMap { index, date in
            container.log(for: date).isDryPlanned ? index : nil
        }
        dryDays = Set(currentDryDays)
        targets = weekDates.map { container.log(for: $0).plannedTargetDrinks }
        if targets.allSatisfy({ $0 == 0 }) {
            targets = container.planService.distributeTarget(weeklyTarget: container.profile.weeklyTarget, dryDayIndexes: dryDays)
        }
    }

    private func persist(_ changedIndex: Int? = nil) {
        guard canEditPlan else { return }
        let sum = targets.reduce(0, +)
        if sum > Double(container.profile.weeklyTarget), let changedIndex {
            let overflow = sum - Double(container.profile.weeklyTarget)
            targets[changedIndex] = max(0, targets[changedIndex] - overflow)
        }

        for (index, date) in weekDates.enumerated() {
            var log = container.log(for: date)
            log.isDryPlanned = dryDays.contains(index)
            log.plannedTargetDrinks = targets[index]
            container.saveLog(log)
        }
        container.registerWeeklyPlanSavedIfNeeded()
    }

    private var planHeaderBar: some View {
        VStack(spacing: 0) {
            Text("\(displayName)'s Plan")
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
    PlanView().environmentObject(AppContainer())
}
