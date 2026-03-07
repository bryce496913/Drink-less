import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var container: AppContainer

    var body: some View {
        NavigationStack {
            Form {
                Section("Profile") {
                    TextField("Your name", text: $container.profile.name)
                    Picker("Goal", selection: $container.profile.goalType) {
                        ForEach(GoalType.allCases) { goal in
                            Text(goal.rawValue).tag(goal)
                        }
                    }
                }

                Section("Targets") {
                    Stepper("Weekly target: \(container.profile.weeklyTarget)", value: $container.profile.weeklyTarget, in: 0...50)
                    Stepper("Dry day target: \(container.profile.dryDaysTarget)", value: $container.profile.dryDaysTarget, in: 0...7)
                }

                Section("Reminders") {
                    Toggle("Reminders enabled", isOn: $container.settings.remindersEnabled)
                    DatePicker("Reminder time", selection: $container.settings.reminderTime, displayedComponents: .hourAndMinute)
                    Toggle("Avoid weekend auto dry days", isOn: $container.settings.avoidWeekendForAutoDry)
                }

                Section("Device") {
                    TextField("Device ID", text: $container.settings.deviceId)
                }

                Section {
                    Button("Save settings") {
                        container.saveProfileAndSettings()
                    }
                    .buttonStyle(PrimaryButtonStyle())

                    Button("Delete all data", role: .destructive) {
                        container.store.deleteAll()
                        container.refresh()
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppTheme.background)
            .foregroundStyle(AppTheme.text)
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView().environmentObject(AppContainer())
}
