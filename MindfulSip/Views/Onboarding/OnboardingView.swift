import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var container: AppContainer
    @State private var step = 0

    private let totalSteps = 3

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Welcome")
                        .font(AppTheme.font(.h1, weight: .bold))
                        .foregroundStyle(AppTheme.text)
                    Text("Step \(step + 1) of \(totalSteps)")
                        .font(AppTheme.font(.h3))
                        .foregroundStyle(AppTheme.highlight)
                    SwiftUI.ProgressView(value: Double(step + 1), total: Double(totalSteps))
                        .tint(AppTheme.highlight)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                VStack(alignment: .leading, spacing: 16) {
                    switch step {
                    case 0:
                        Text("Tell us about you")
                            .font(AppTheme.font(.h2, weight: .semibold))
                        TextField("Your name", text: $container.profile.name)
                            .textInputAutocapitalization(.words)
                        Text("What is your current goal?")
                            .font(AppTheme.font(.h2, weight: .semibold))
                        Picker("Goal type", selection: $container.profile.goalType) {
                            ForEach(GoalType.allCases) { goal in
                                Text(goal.rawValue).tag(goal)
                            }
                        }
                        .pickerStyle(.segmented)
                    case 1:
                        Text("Set your weekly plan")
                            .font(AppTheme.font(.h2, weight: .semibold))
                        Stepper("Weekly target: \(container.profile.weeklyTarget)", value: $container.profile.weeklyTarget, in: 0...50)
                        Stepper("Dry days per week: \(container.profile.dryDaysTarget)", value: $container.profile.dryDaysTarget, in: 0...7)
                    default:
                        Text("Reminder and estimates")
                            .font(AppTheme.font(.h2, weight: .semibold))
                        DatePicker("Reminder time", selection: $container.settings.reminderTime, displayedComponents: .hourAndMinute)
                        HStack {
                            Text("Cost per drink")
                            Spacer()
                            TextField("", value: $container.profile.costPerDrink, format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(maxWidth: 90)
                        }
                        HStack {
                            Text("Calories per drink")
                            Spacer()
                            TextField("", value: $container.profile.caloriesPerDrink, format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(maxWidth: 90)
                        }
                    }
                }
                .padding(16)
                .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 18))
                .foregroundStyle(AppTheme.text)

                Spacer()

                HStack(spacing: 10) {
                    if step > 0 {
                        Button("Back") { step -= 1 }
                            .buttonStyle(SecondaryButtonStyle())
                    }
                    Button(step == totalSteps - 1 ? "Finish" : "Next") {
                        if step < totalSteps - 1 {
                            step += 1
                            return
                        }
                        container.profile.name = container.profile.name.trimmingCharacters(in: .whitespacesAndNewlines)
                        if container.profile.name.isEmpty {
                            container.profile.name = "Friend"
                        }
                        container.profile.createdAt = .now
                        container.settings.hasCompletedOnboarding = true
                        container.saveProfileAndSettings()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
            }
            .padding()
            .background(AppTheme.background.ignoresSafeArea())
            .onAppear {
                if !container.settings.hasCompletedOnboarding, container.profile.name == "Friend" {
                    container.profile.name = ""
                }
            }
        }
    }
}

#Preview {
    OnboardingView().environmentObject(AppContainer())
}
