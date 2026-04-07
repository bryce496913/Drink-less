import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var container: AppContainer
    @State private var showDeleteConfirmation = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background

                Form {
                    Section {
                        Stepper("Weekly target: \(container.profile.weeklyTarget)", value: $container.profile.weeklyTarget, in: 0...50)
                            .font(AppTheme.font(.footnote))
                            .disabled(container.areWeeklyTargetsLocked)
                        Stepper("Dry day target: \(container.profile.dryDaysTarget)", value: $container.profile.dryDaysTarget, in: 0...7)
                            .font(AppTheme.font(.footnote))
                            .disabled(container.areWeeklyTargetsLocked)
                        if container.areWeeklyTargetsLocked {
                            Text("Weekly targets are locked for this week and can be changed again next Monday.")
                                .font(AppTheme.font(.caption))
                                .foregroundStyle(AppTheme.text.opacity(0.75))
                        }
                    } header: {
                        Text("Targets")
                            .font(AppTheme.font(.headline, weight: .semibold))
                    }

                    Section {
                        Stepper(
                            "Price per drink: $\(container.profile.costPerDrink, specifier: "%.2f")",
                            value: $container.profile.costPerDrink,
                            in: 0...100,
                            step: 0.5
                        )
                        .font(AppTheme.font(.footnote))

                        Stepper(
                            "Calories per drink: \(container.profile.caloriesPerDrink, specifier: "%.0f")",
                            value: $container.profile.caloriesPerDrink,
                            in: 0...1500,
                            step: 5
                        )
                        .font(AppTheme.font(.footnote))
                    } header: {
                        Text("Drink defaults")
                            .font(AppTheme.font(.headline, weight: .semibold))
                    }

                    Section {
                        Toggle("Reminders enabled", isOn: $container.settings.remindersEnabled)
                            .font(AppTheme.font(.footnote))
                            .onChange(of: container.settings.remindersEnabled) { _ in
                                container.saveSettings()
                            }
                        DatePicker("Reminder time", selection: $container.settings.reminderTime, displayedComponents: .hourAndMinute)
                            .font(AppTheme.font(.footnote))
                            .onChange(of: container.settings.reminderTime) { _ in
                                if container.settings.remindersEnabled {
                                    container.saveSettings()
                                }
                            }
                        Toggle("Avoid weekend auto dry days", isOn: $container.settings.avoidWeekendForAutoDry)
                            .font(AppTheme.font(.footnote))
                    } header: {
                        Text("Reminders")
                            .font(AppTheme.font(.subheadline, weight: .semibold))
                    }

                    Section {
                        Text("Quick logging for a big night out. Add drinks fast without opening the full app.")
                            .font(AppTheme.font(.caption))
                            .foregroundStyle(AppTheme.text.opacity(0.75))

                        Toggle("Enable Booze Mode", isOn: $container.settings.boozeModeEnabled)
                            .font(AppTheme.font(.footnote))

                        if container.settings.boozeModeEnabled {
                            Text("Booze Mode active")
                                .font(AppTheme.font(.caption, weight: .semibold))
                                .foregroundStyle(AppTheme.highlight)
                        }
                    } header: {
                        Text("Booze Mode")
                            .font(AppTheme.font(.headline, weight: .semibold))
                    }

                    Section {
                        Text("Keep tracking during time away, without affecting dry days or daily targets.")
                            .font(AppTheme.font(.caption))
                            .foregroundStyle(AppTheme.text.opacity(0.75))

                        Toggle("Enable Holiday Mode", isOn: $container.settings.holidayModeEnabled)
                            .font(AppTheme.font(.footnote))

                        DatePicker(
                            "Holiday start",
                            selection: Binding(
                                get: { container.settings.holidayStartDate ?? container.currentDate },
                                set: { container.settings.holidayStartDate = $0 }
                            ),
                            displayedComponents: .date
                        )
                        .disabled(!container.settings.holidayModeEnabled)

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
                        .disabled(!container.settings.holidayModeEnabled)

                        if container.isHolidayModeActive {
                            Text("Holiday Mode active — tracking only")
                                .font(AppTheme.font(.caption, weight: .semibold))
                                .foregroundStyle(AppTheme.holiday)
                            Text("You’re still tracking, but your goals are paused for now.")
                                .font(AppTheme.font(.caption))
                                .foregroundStyle(AppTheme.text.opacity(0.75))
                        }
                    } header: {
                        Text("Holiday Mode")
                            .font(AppTheme.font(.headline, weight: .semibold))
                    }

                    Section {
                        Button("Save settings") {
                            container.saveProfileAndSettings()
                        }
                        .buttonStyle(PrimaryButtonStyle())

                        Button("Delete all data", role: .destructive) {
                            showDeleteConfirmation = true
                        }
                        .font(AppTheme.font(.footnote, weight: .semibold))
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .scrollContentBackground(.hidden)
                .foregroundStyle(AppTheme.text)
                .navigationTitle("Settings")
                .alert("Delete all data?", isPresented: $showDeleteConfirmation) {
                    Button("Cancel", role: .cancel) { }
                    Button("Delete", role: .destructive) {
                        container.store.deleteAll()
                        container.refresh()
                    }
                } message: {
                    Text("This action permanently removes your logs, profile, and app settings.")
                }
            }
        }
        .onChange(of: container.settings.boozeModeEnabled) { _ in container.saveSettings() }
        .onChange(of: container.settings.holidayModeEnabled) { _ in container.saveSettings() }
        .onChange(of: container.settings.holidayStartDate) { _ in container.saveSettings() }
        .onChange(of: container.settings.holidayEndDate) { _ in container.saveSettings() }
        .appFullscreenContainer()
    }
}

#Preview {
    SettingsView().environmentObject(AppContainer())
}
