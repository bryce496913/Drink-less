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
                        Stepper("Dry day target: \(container.profile.dryDaysTarget)", value: $container.profile.dryDaysTarget, in: 0...7)
                            .font(AppTheme.font(.footnote))
                    } header: {
                        Text("Targets")
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
        .appFullscreenContainer()
    }
}

#Preview {
    SettingsView().environmentObject(AppContainer())
}
