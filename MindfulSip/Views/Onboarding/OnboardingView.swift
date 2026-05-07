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

                GeometryReader { geometry in
                    ScrollView {
                        VStack(spacing: 20) {
                            onboardingHeader
                            onboardingForm
                            actionButtons
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(minHeight: geometry.size.height, alignment: .top)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                }
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
        .appFullscreenContainer()
    }

    private var onboardingHeader: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Welcome")
                .appTextStyle(.pageTitle)
                .appTextColor(.primaryText)
            Text("Step \(step + 1) of \(totalSteps)")
                .appTextStyle(.caption)
                .appTextColor(.accentHeading)
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
                    .appTextStyle(.sectionTitle)
                    .appTextColor(.accentHeading)
                TextField("Your name", text: $container.profile.name)
                    .appTextStyle(.body)
                    .appTextColor(.primaryText)
                    .textInputAutocapitalization(.words)
                if !isNameValid {
                    Text("Name is required to continue.")
                        .appTextStyle(.caption)
                        .appTextColor(.highlightValue)
                }
                Text("What is your current goal?")
                    .appTextStyle(.cardTitle)
                    .appTextColor(.accentHeading)
                Picker("Goal type", selection: $container.profile.goalType) {
                    ForEach(GoalType.allCases) { goal in
                        Text(goal.rawValue).tag(goal)
                    }
                }
                .pickerStyle(.segmented)
            case 1:
                Text("Set your weekly plan")
                    .appTextStyle(.sectionTitle)
                    .appTextColor(.accentHeading)
                Stepper("Weekly target: \(container.profile.weeklyTarget)", value: $container.profile.weeklyTarget, in: 0 ... 50)
                    .appTextStyle(.body)
                Stepper("Dry days per week: \(container.profile.dryDaysTarget)", value: $container.profile.dryDaysTarget, in: 0 ... 7)
                    .appTextStyle(.body)
            default:
                Text("Notifications and estimates")
                    .appTextStyle(.sectionTitle)
                    .appTextColor(.accentHeading)

                Toggle("Turn on system notifications", isOn: $container.settings.remindersEnabled)
                    .appTextStyle(.body)
                    .tint(AppTheme.highlight)
                    .onChange(of: container.settings.remindersEnabled) { enabled in
                        guard enabled else { return }
                        Task {
                            await container.notificationService.requestIfNeeded()
                        }
                    }

                Text("We’ll ask iOS for permission and send your mindful check-in at the time below.")
                    .appTextStyle(.caption)
                    .appTextColor(.mutedText)

                DatePicker("Reminder time", selection: $container.settings.reminderTime, displayedComponents: .hourAndMinute)
                    .appTextStyle(.body)
                    .disabled(!container.settings.remindersEnabled)
                    .opacity(container.settings.remindersEnabled ? 1 : 0.6)

                HStack {
                    Text("Cost per drink")
                        .appTextStyle(.secondary)
                    Spacer(minLength: 8)
                    TextField("", value: $container.profile.costPerDrink, format: .number)
                        .appTextStyle(.body)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: 90)
                }

                HStack {
                    Text("Calories per drink")
                        .appTextStyle(.secondary)
                    Spacer(minLength: 8)
                    TextField("", value: $container.profile.caloriesPerDrink, format: .number)
                        .appTextStyle(.body)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: 90)
                }
            }
        }
        .padding(16)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 18))
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
