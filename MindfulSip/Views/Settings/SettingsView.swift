import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var container: AppContainer
    @State private var showDeleteConfirmation = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Name")
                            .font(AppTheme.font(.subheadline, weight: .semibold))
                            .foregroundStyle(AppTheme.text.opacity(0.9))
                        TextField("user_name", text: $container.profile.name)
                            .font(AppTheme.font(.footnote))
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Goal")
                            .font(AppTheme.font(.subheadline, weight: .semibold))
                            .foregroundStyle(AppTheme.text.opacity(0.9))
                        Picker("user_goal", selection: $container.profile.goalType) {
                            ForEach(GoalType.allCases) { goal in
                                Text(goal.rawValue).tag(goal)
                            }
                        }
                        .font(AppTheme.font(.footnote))
                    }
                } header: {
                    Text("Profile")
                        .font(AppTheme.font(.headline, weight: .semibold))
                }

                Section {
                    Stepper("Weekly target: \(container.profile.weeklyTarget)", value: $container.profile.weeklyTarget, in: 0...50)
                        .font(AppTheme.font(.footnote))
                    Stepper("Dry day target: \(container.profile.dryDaysTarget)", value: $container.profile.dryDaysTarget, in: 0...7)
                        .font(AppTheme.font(.footnote))
                } header: {
                    Text("Targets")
                        .font(AppTheme.font(.headline, weight: .semibold))
                }

                Section {
                    Toggle("Reminders enabled", isOn: $container.settings.remindersEnabled)
                        .font(AppTheme.font(.footnote))
                    DatePicker("Reminder time", selection: $container.settings.reminderTime, displayedComponents: .hourAndMinute)
                        .font(AppTheme.font(.footnote))
                    Toggle("Avoid weekend auto dry days", isOn: $container.settings.avoidWeekendForAutoDry)
                        .font(AppTheme.font(.footnote))
                } header: {
                    Text("Reminders")
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
            .scrollContentBackground(.hidden)
            .background(AppTheme.background)
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
}

#Preview {
    SettingsView().environmentObject(AppContainer())
}
