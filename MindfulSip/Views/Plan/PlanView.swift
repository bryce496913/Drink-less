import SwiftUI

struct PlanView: View {
    @EnvironmentObject var container: AppContainer
    private let dateService = DateService()

    @State private var dryDays: Set<Int> = []
    @State private var targets: [Double] = Array(repeating: 0, count: 7)
    @State private var isProfileExpanded = false
    @State private var isTargetsExpanded = false
    @State private var isReminderExpanded = false
    @State private var isDailyTargetsExpanded = false
    @State private var isSettingsExpanded = false
    @State private var showDeleteConfirmation = false
    @State private var settingsSaveMessage = ""

    private var weekDates: [Date] { dateService.weekDates(from: container.currentDate) }

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
                        settingsSection
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
            HStack(spacing: 10) {
                planStat(title: "Weekly target", value: "\(container.profile.weeklyTarget)")
                planStat(title: "Dry day goal", value: "\(container.profile.dryDaysTarget)")
            }
            HStack(spacing: 10) {
                planStat(title: "Planned", value: String(format: "%.1f", plannedTotal))
                planStat(title: "Remaining", value: String(format: "%.1f", remaining))
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
                .disabled(isPlanLocked)
            }

            HStack(spacing: 10) {
                planStat(title: "Logged", value: String(format: "%.1f", dayLog.totalDrinks))
                planStat(title: "Target", value: String(format: "%.1f", targets[index]))
            }

            Stepper(value: Binding(get: { targets[index] }, set: { newValue in
                targets[index] = max(0, newValue)
                if targets[index] > 0 {
                    dryDays.remove(index)
                }
                persist(index)
            }), in: 0 ... 20, step: 0.5) {
                Text("Adjust daily target")
                    .bodyTextStyle()
            }
            .disabled(isPlanLocked)
        }
        .padding(14)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 14))
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

    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isSettingsExpanded.toggle()
                }
            } label: {
                HStack {
                    Text("Settings")
                        .sectionTitleStyle()
                    Spacer()
                    Image(systemName: isSettingsExpanded ? "chevron.up" : "chevron.down")
                        .font(AppTheme.font(.caption, weight: .semibold))
                        .foregroundStyle(AppTheme.highlight)
                }
            }
            .buttonStyle(.plain)

            if isSettingsExpanded {
                Divider()
                    .overlay(AppTheme.highlight.opacity(0.3))

                DisclosureGroup(isExpanded: $isProfileExpanded) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Text("Name:")
                                .appTextStyle(.body)
                                .appTextColor(.secondaryText)
                            TextField("user_name", text: $container.profile.name)
                                .appTextStyle(.body)
                                .appTextColor(.highlightValue)
                                .textInputAutocapitalization(.words)
                        }

                        HStack(spacing: 8) {
                            Text("Goal:")
                                .appTextStyle(.body)
                                .appTextColor(.secondaryText)
                            Picker("user_goal", selection: $container.profile.goalType) {
                                ForEach(GoalType.allCases) { goal in
                                    Text(goal.rawValue).tag(goal)
                                }
                            }
                            .appTextStyle(.body)
                        }

                        HStack(spacing: 8) {
                            Text("Price per drink:")
                                .appTextStyle(.body)
                                .appTextColor(.secondaryText)
                            Spacer()
                            TextField("", value: $container.profile.costPerDrink, format: .number)
                                .appTextStyle(.body)
                                .appTextColor(.highlightValue)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(maxWidth: 90)
                        }

                        HStack(spacing: 8) {
                            Text("Calories per drink:")
                                .appTextStyle(.body)
                                .appTextColor(.secondaryText)
                            Spacer()
                            TextField("", value: $container.profile.caloriesPerDrink, format: .number)
                                .appTextStyle(.body)
                                .appTextColor(.highlightValue)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(maxWidth: 90)
                        }
                    }
                    .padding(.top, 4)
                } label: {
                    Text("Profile")
                        .accordionTitleStyle()
                }

                DisclosureGroup(isExpanded: $isTargetsExpanded) {
                    VStack(spacing: 8) {
                        Stepper("Weekly target: \(container.profile.weeklyTarget)", value: $container.profile.weeklyTarget, in: 0...50)
                            .appTextStyle(.body)
                            .disabled(isPlanLocked)
                        Stepper("Dry day target: \(container.profile.dryDaysTarget)", value: $container.profile.dryDaysTarget, in: 0...7)
                            .appTextStyle(.body)
                            .disabled(isPlanLocked)
                        if isPlanLocked {
                            Text("Targets are locked for this week and can be adjusted again next Monday.")
                                .appTextStyle(.caption)
                                .appTextColor(.mutedText)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding(.top, 4)
                } label: {
                    Text("Targets")
                        .accordionTitleStyle()
                }

                DisclosureGroup(isExpanded: $isReminderExpanded) {
                    VStack(spacing: 8) {
                        Toggle("Reminders enabled", isOn: $container.settings.remindersEnabled)
                            .appTextStyle(.body)
                            .onChange(of: container.settings.remindersEnabled) { _ in
                                container.saveSettings()
                            }
                        DatePicker("Reminder time", selection: $container.settings.reminderTime, displayedComponents: .hourAndMinute)
                            .appTextStyle(.body)
                            .onChange(of: container.settings.reminderTime) { _ in
                                if container.settings.remindersEnabled {
                                    container.saveSettings()
                                }
                            }
                        Toggle("Avoid weekend auto dry days", isOn: $container.settings.avoidWeekendForAutoDry)
                            .appTextStyle(.body)
                            .onChange(of: container.settings.avoidWeekendForAutoDry) { _ in
                                container.saveSettings()
                            }
                    }
                    .padding(.top, 4)
                } label: {
                    Text("Reminders")
                        .accordionTitleStyle()
                }

                Button("Save settings") {
                    container.profile.name = container.profile.name.trimmingCharacters(in: .whitespacesAndNewlines)
                    if container.profile.name.isEmpty {
                        container.profile.name = "Friend"
                    }
                    container.saveProfileAndSettings()
                    showSettingsSavedFeedback()
                }
                .buttonStyle(PrimaryButtonStyle())

                if !settingsSaveMessage.isEmpty {
                    Label(settingsSaveMessage, systemImage: "checkmark.circle.fill")
                        .appTextStyle(.caption)
                        .appTextColor(.accentHeading)
                        .transition(.opacity)
                }

                Button("Delete all data", role: .destructive) {
                    showDeleteConfirmation = true
                }
                .buttonStyle(SecondaryButtonStyle())
                .padding(.top, 2)
            }
        }
        .padding(.top, 4)
        .padding(14)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 14))
        .alert("Delete all data?", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                container.store.deleteAll()
                container.refresh()
                loadWeek()
            }
        } message: {
            Text("This action permanently removes your logs, profile, and app settings.")
        }
    }

    private func showSettingsSavedFeedback() {
        settingsSaveMessage = "Settings saved"
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            settingsSaveMessage = ""
        }
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
