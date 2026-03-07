import SwiftUI

struct PlanView: View {
    @EnvironmentObject var container: AppContainer
    private let dateService = DateService()

    @State private var dryDays: Set<Int> = []
    @State private var targets: [Double] = Array(repeating: 0, count: 7)

    private var weekDates: [Date] { dateService.weekDates(from: container.currentDate) }

    private var plannedTotal: Double { targets.reduce(0, +) }
    private var remaining: Double { max(0, Double(container.profile.weeklyTarget) - plannedTotal) }

    private var displayName: String {
        let trimmed = container.profile.name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Friend" : trimmed
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    planHeader
                    weeklySummary
                    dailyTargetsSection
                }
                .padding()
            }
            .background(AppTheme.background.ignoresSafeArea())
            .navigationTitle("\(displayName)'s Plan")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear(perform: loadWeek)
        }
    }

    private var planHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Weekly planning")
                .font(AppTheme.font(.title2, weight: .bold))
                .foregroundStyle(AppTheme.text)

            Text("Set daily limits and dry days. Your total is auto-capped to your weekly target.")
                .font(AppTheme.font(.body))
                .foregroundStyle(AppTheme.text.opacity(0.9))

            Button("Auto-distribute my target") {
                targets = container.planService.distributeTarget(weeklyTarget: container.profile.weeklyTarget, dryDayIndexes: dryDays)
                persist()
            }
            .buttonStyle(SecondaryButtonStyle())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 16))
    }

    private var weeklySummary: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                planStat(title: "Weekly target", value: "\(container.profile.weeklyTarget)")
                planStat(title: "Dry day goal", value: "\(container.profile.dryDaysTarget)")
            }
            HStack(spacing: 10) {
                planStat(title: "Planned", value: String(format: "%.1f", plannedTotal))
                planStat(title: "Remaining", value: String(format: "%.1f", remaining))
            }
        }
    }

    private var dailyTargetsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Daily targets")
                .font(AppTheme.font(.headline, weight: .semibold))
                .foregroundStyle(AppTheme.text)

            ForEach(Array(weekDates.enumerated()), id: \.offset) { index, date in
                dayRow(index: index, date: date)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func dayRow(index: Int, date: Date) -> some View {
        let dayLog = container.log(for: date)

        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(date.formatted(.dateTime.weekday(.wide)))
                        .font(AppTheme.font(.subheadline, weight: .semibold))
                    Text(date.formatted(date: .abbreviated, time: .omitted))
                        .font(AppTheme.font(.caption))
                        .foregroundStyle(AppTheme.text.opacity(0.75))
                }
                Spacer()
                Toggle("Dry", isOn: Binding(get: { dryDays.contains(index) }, set: { isDry in
                    if isDry {
                        dryDays.insert(index)
                        targets[index] = 0
                    } else {
                        dryDays.remove(index)
                    }
                    persist(index)
                }))
                .labelsHidden()
                .tint(AppTheme.highlight)
            }

            HStack(spacing: 10) {
                planStat(title: "Logged", value: String(format: "%.1f", dayLog.totalDrinks))
                planStat(title: "Target", value: String(format: "%.1f", targets[index]))
            }

            Stepper(value: Binding(get: { targets[index] }, set: { newValue in
                targets[index] = max(0, newValue)
                if targets[index] > 0 {
                    dryDays.remove(index)
                }
                persist(index)
            }), in: 0 ... 20, step: 0.5) {
                Text("Adjust daily target")
                    .font(AppTheme.font(.body, weight: .medium))
                    .foregroundStyle(AppTheme.text)
            }
        }
        .padding(14)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 14))
    }

    private func planStat(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(AppTheme.font(.footnote))
                .foregroundStyle(AppTheme.text.opacity(0.8))
            Text(value)
                .font(AppTheme.font(.headline, weight: .bold))
                .foregroundStyle(AppTheme.highlight)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(AppTheme.background.opacity(0.45), in: RoundedRectangle(cornerRadius: 12))
    }

    private func loadWeek() {
        let currentDryDays = weekDates.enumerated().compactMap { index, date in
            container.log(for: date).isDryPlanned ? index : nil
        }
        dryDays = Set(currentDryDays)
        targets = weekDates.map { container.log(for: $0).plannedTargetDrinks }
        if targets.allSatisfy({ $0 == 0 }) {
            targets = container.planService.distributeTarget(weeklyTarget: container.profile.weeklyTarget, dryDayIndexes: dryDays)
        }
    }

    private func persist(_ changedIndex: Int? = nil) {
        let sum = targets.reduce(0, +)
        if sum > Double(container.profile.weeklyTarget), let changedIndex {
            let overflow = sum - Double(container.profile.weeklyTarget)
            targets[changedIndex] = max(0, targets[changedIndex] - overflow)
        }

        for (index, date) in weekDates.enumerated() {
            var log = container.log(for: date)
            log.isDryPlanned = dryDays.contains(index)
            log.plannedTargetDrinks = targets[index]
            container.saveLog(log)
        }
    }
}

#Preview {
    PlanView().environmentObject(AppContainer())
}
