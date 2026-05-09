import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var container: AppContainer

    @State private var isProfileExpanded = true
    @State private var isTargetsExpanded = false
    @State private var isReminderExpanded = false
    @State private var isModesExpanded = false
    @State private var showDeleteConfirmation = false
    @State private var settingsSaveMessage = ""

    private let settingsItemIndent: CGFloat = 14
    private let settingsContentIndent: CGFloat = 14
    private let settingsExtraContentIndent: CGFloat = 14
    private var isPlanLocked: Bool { !container.canEditWeeklyPlan }

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    settingsHeader
                    profileSection
                    targetsSection
                    remindersSection
                    modesSection
                    actionsSection
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(minHeight: geometry.size.height, alignment: .top)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .background(AppTheme.background)
        .safeAreaInset(edge: .top, spacing: 0) {
            topHeaderBar
        }
        .alert("Delete all data?", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                container.store.deleteAll()
                container.refresh()
            }
        } message: {
            Text("This action permanently removes your logs, profile, and app settings.")
        }
        .appFullscreenContainer()
    }

    private var settingsHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Settings")
                .pageTitleStyle()

            Text("Manage your profile, targets, reminders, and app modes from one focused place.")
                .bodyTextStyle()
                .opacity(0.82)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 16))
    }

    private var profileSection: some View {
        settingsAccordion(title: "Profile", isExpanded: $isProfileExpanded) {
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
            .padding(.leading, settingsContentIndent)
        }
    }

    private var targetsSection: some View {
        settingsAccordion(title: "Targets", isExpanded: $isTargetsExpanded) {
            VStack(spacing: 8) {
                Stepper("Weekly target: \(container.profile.weeklyTarget)", value: $container.profile.weeklyTarget, in: 0...50)
                    .appTextStyle(.body)
                    .disabled(isPlanLocked)
                    .padding(.leading, settingsExtraContentIndent)
                Stepper("Dry day target: \(container.profile.dryDaysTarget)", value: $container.profile.dryDaysTarget, in: 0...7)
                    .appTextStyle(.body)
                    .disabled(isPlanLocked)
                    .padding(.leading, settingsExtraContentIndent)
                if isPlanLocked {
                    Text("Targets are locked for this week and can be adjusted again next Monday.")
                        .appTextStyle(.caption)
                        .appTextColor(.mutedText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, settingsExtraContentIndent)
                }
            }
            .padding(.top, 4)
            .padding(.leading, settingsContentIndent)
        }
    }

    private var remindersSection: some View {
        settingsAccordion(title: "Reminders", isExpanded: $isReminderExpanded) {
            VStack(spacing: 8) {
                Toggle("Reminders enabled", isOn: $container.settings.remindersEnabled)
                    .appTextStyle(.body)
                    .padding(.leading, settingsExtraContentIndent)
                    .onChange(of: container.settings.remindersEnabled) { _ in
                        container.saveSettings()
                    }
                DatePicker("Reminder time", selection: $container.settings.reminderTime, displayedComponents: .hourAndMinute)
                    .appTextStyle(.body)
                    .padding(.leading, settingsExtraContentIndent)
                    .onChange(of: container.settings.reminderTime) { _ in
                        if container.settings.remindersEnabled {
                            container.saveSettings()
                        }
                    }
                Toggle("Avoid weekend auto dry days", isOn: $container.settings.avoidWeekendForAutoDry)
                    .appTextStyle(.body)
                    .padding(.leading, settingsExtraContentIndent)
                    .onChange(of: container.settings.avoidWeekendForAutoDry) { _ in
                        container.saveSettings()
                    }
            }
            .padding(.top, 4)
            .padding(.leading, settingsContentIndent)
        }
    }

    private var modesSection: some View {
        settingsAccordion(title: "Modes", isExpanded: $isModesExpanded) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Booze Mode lets you quick-log drinks from notifications on nights out.")
                    .appTextStyle(.caption)
                    .appTextColor(.mutedText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, settingsExtraContentIndent)

                Toggle("Enable Booze Mode", isOn: $container.settings.boozeModeEnabled)
                    .appTextStyle(.body)
                    .padding(.leading, settingsExtraContentIndent)
                    .onChange(of: container.settings.boozeModeEnabled) { _ in
                        container.saveSettings()
                    }

                if container.settings.boozeModeEnabled {
                    Text("Booze Mode active")
                        .appTextStyle(.caption)
                        .appTextColor(.accentHeading)
                        .padding(.leading, settingsExtraContentIndent)
                }

                Divider()
                    .overlay(AppTheme.highlight.opacity(0.25))
                    .padding(.horizontal, settingsExtraContentIndent)

                Text("Holiday Mode keeps tracking on while pausing goals and dry-day progress.")
                    .appTextStyle(.caption)
                    .appTextColor(.mutedText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, settingsExtraContentIndent)

                Toggle("Enable Holiday Mode", isOn: $container.settings.holidayModeEnabled)
                    .appTextStyle(.body)
                    .padding(.leading, settingsExtraContentIndent)
                    .onChange(of: container.settings.holidayModeEnabled) { _ in
                        container.saveSettings()
                    }

                DatePicker(
                    "Holiday start",
                    selection: Binding(
                        get: { container.settings.holidayStartDate ?? container.currentDate },
                        set: { container.settings.holidayStartDate = $0 }
                    ),
                    displayedComponents: .date
                )
                .appTextStyle(.body)
                .padding(.leading, settingsExtraContentIndent)
                .disabled(!container.settings.holidayModeEnabled)
                .onChange(of: container.settings.holidayStartDate) { _ in
                    container.saveSettings()
                }

                DatePicker(
                    "Holiday end",
                    selection: Binding(
                        get: {
                            container.settings.holidayEndDate
                            ?? container.settings.holidayStartDate
                            ?? container.currentDate
                        },
                        set: { container.settings.holidayEndDate = $0 }
                    ),
                    displayedComponents: .date
                )
                .appTextStyle(.body)
                .padding(.leading, settingsExtraContentIndent)
                .disabled(!container.settings.holidayModeEnabled)
                .onChange(of: container.settings.holidayEndDate) { _ in
                    container.saveSettings()
                }

                if container.isHolidayModeActive {
                    Text("Holiday Mode active — tracking only")
                        .appTextStyle(.caption)
                        .appTextColor(.primaryText)
                        .padding(.leading, settingsExtraContentIndent)
                }
            }
            .padding(.top, 4)
            .padding(.leading, settingsContentIndent)
        }
    }

    private var actionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
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
        }
        .padding(14)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 14))
    }

    private func settingsAccordion<Content: View>(title: String, isExpanded: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) -> some View {
        DisclosureGroup(isExpanded: isExpanded) {
            content()
                .padding(.top, 8)
        } label: {
            Text(title)
                .accordionTitleStyle()
        }
        .padding(14)
        .padding(.leading, settingsItemIndent)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 14))
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func showSettingsSavedFeedback() {
        settingsSaveMessage = "Settings saved"
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            settingsSaveMessage = ""
        }
    }

    private var topHeaderBar: some View {
        VStack(spacing: 0) {
            Text("Settings")
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
    SettingsView().environmentObject(AppContainer())
}
