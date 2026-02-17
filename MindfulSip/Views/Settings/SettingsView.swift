import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var container: AppContainer
    @Environment(\.dismiss) var dismiss

    var body: some View {
        Form {
            Stepper("Weekly target: \(container.profile.weeklyTarget)", value: $container.profile.weeklyTarget, in: 0...50)
            Stepper("Dry day target: \(container.profile.dryDaysTarget)", value: $container.profile.dryDaysTarget, in: 0...7)
            Toggle("Reminders enabled", isOn: $container.settings.remindersEnabled)
            DatePicker("Reminder time", selection: $container.settings.reminderTime, displayedComponents: .hourAndMinute)
            Toggle("Avoid weekend auto dry days", isOn: $container.settings.avoidWeekendForAutoDry)
            Toggle("Backend sync enabled", isOn: $container.settings.backendSyncEnabled)
            TextField("Backend base URL", text: $container.settings.backendBaseURL)
            TextField("Device ID", text: $container.settings.deviceId)
            Button("Delete all data", role: .destructive) { container.store.deleteAll(); container.refresh() }
            Button("Save") { container.saveProfile(); container.saveSettings(); dismiss() }
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    SettingsView().environmentObject(AppContainer())
}
