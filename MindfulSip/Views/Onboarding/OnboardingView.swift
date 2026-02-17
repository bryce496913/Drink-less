import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var container: AppContainer
    @State private var step = 0

    var body: some View {
        NavigationStack {
            Form {
                switch step {
                case 0:
                    Picker("Goal type", selection: $container.profile.goalType) {
                        ForEach(GoalType.allCases) { Text($0.rawValue).tag($0) }
                    }
                case 1:
                    Stepper("Weekly target: \(container.profile.weeklyTarget)", value: $container.profile.weeklyTarget, in: 0...50)
                case 2:
                    Stepper("Dry days per week: \(container.profile.dryDaysTarget)", value: $container.profile.dryDaysTarget, in: 0...7)
                case 3:
                    DatePicker("Reminder time", selection: $container.settings.reminderTime, displayedComponents: .hourAndMinute)
                default:
                    Section("Optional estimates") {
                        HStack { Text("Cost per drink"); Spacer(); TextField("", value: $container.profile.costPerDrink, format: .number).keyboardType(.decimalPad).multilineTextAlignment(.trailing) }
                        HStack { Text("Calories per drink"); Spacer(); TextField("", value: $container.profile.caloriesPerDrink, format: .number).keyboardType(.decimalPad).multilineTextAlignment(.trailing) }
                    }
                }
            }
            .navigationTitle("Welcome")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(step == 4 ? "Finish" : "Next") {
                        if step < 4 { step += 1 } else {
                            container.settings.hasCompletedOnboarding = true
                            container.saveProfile()
                            container.saveSettings()
                        }
                    }
                    .accessibilityLabel(step == 4 ? "Finish onboarding" : "Go to next onboarding step")
                }
            }
        }
    }
}

#Preview {
    OnboardingView().environmentObject(AppContainer())
}
