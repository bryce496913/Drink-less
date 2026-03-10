import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var container: AppContainer
    @State private var step = 0

    private let totalSteps = 3

    private var isNameValid: Bool {
        !container.profile.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        onboardingHeader
                        onboardingForm
                        actionButtons
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if !container.settings.hasCompletedOnboarding, container.profile.name == "Friend" {
                    container.profile.name = ""
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private var onboardingHeader: some View {
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
    }

    private var onboardingForm: some View {
        VStack(alignment: .leading, spacing: 16) {
            switch step {
            case 0:
                Text("Tell us about you")
                    .font(AppTheme.font(.h2, weight: .semibold))
                TextField("Your name", text: $container.profile.name)
                    .textInputAutocapitalization(.words)
                if !isNameValid {
                    Text("Name is required to continue.")
                        .font(AppTheme.font(.h3))
                        .foregroundStyle(AppTheme.highlight)
                }
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
                Stepper("Weekly target: \(container.profile.weeklyTarget)", value: $container.profile.weeklyTarget, in: 0 ... 50)
                Stepper("Dry days per week: \(container.profile.dryDaysTarget)", value: $container.profile.dryDaysTarget, in: 0 ... 7)
            default:
                Text("Reminder and estimates")
                    .font(AppTheme.font(.h2, weight: .semibold))
                DatePicker("Reminder time", selection: $container.settings.reminderTime, displayedComponents: .hourAndMinute)

                HStack {
                    Text("Cost per drink")
                    Spacer(minLength: 8)
                    TextField("", value: $container.profile.costPerDrink, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: 90)
                }

                HStack {
                    Text("Calories per drink")
                    Spacer(minLength: 8)
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
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var actionButtons: some View {
        HStack(spacing: 10) {
            if step > 0 {
                Button("Back") { step -= 1 }
                    .buttonStyle(SecondaryButtonStyle())
            }

            Button(step == totalSteps - 1 ? "Finish" : "Next") {
                if step == 0, !isNameValid {
                    return
                }
                if step < totalSteps - 1 {
                    step += 1
                    return
                }
                container.profile.name = container.profile.name.trimmingCharacters(in: .whitespacesAndNewlines)
                container.profile.createdAt = .now
                container.settings.hasCompletedOnboarding = true
                container.saveProfileAndSettings()
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(step == 0 && !isNameValid)
            .opacity(step == 0 && !isNameValid ? 0.6 : 1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 4)
    }
}

#Preview {
    OnboardingView().environmentObject(AppContainer())
}
