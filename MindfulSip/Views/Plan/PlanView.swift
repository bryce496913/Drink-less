import SwiftUI

struct PlanView: View {
    @EnvironmentObject var container: AppContainer
    let dateService = DateService()

    @State private var dryDays: Set<Int> = []
    @State private var targets: [Double] = Array(repeating: 0, count: 7)

    var weekDates: [Date] { dateService.weekDates(from: container.currentDate) }

    private var totalPlanned: Double {
        targets.reduce(0, +)
    }

    private var remaining: Double {
        max(0, Double(container.profile.weeklyTarget) - totalPlanned)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    VStack(spacing: 10) {
                        HStack(spacing: 10) {
                            planStat(title: "Weekly target", value: "\(container.profile.weeklyTarget)")
                            planStat(title: "Dry days goal", value: "\(container.profile.dryDaysTarget)")
                        }

                        HStack(spacing: 10) {
                            planStat(title: "Planned this week", value: String(format: "%.1f", totalPlanned))
                            planStat(title: "Remaining", value: String(format: "%.1f", remaining))
                        }
                    }

                    HStack(spacing: 8) {
                        Button("Auto-pick dry days") {
                            dryDays = container.planService.autoPickDryDays(count: container.profile.dryDaysTarget, avoidWeekend: container.settings.avoidWeekendForAutoDry)
                            targets = container.planService.distributeTarget(weeklyTarget: container.profile.weeklyTarget, dryDayIndexes: dryDays)
                            persist()
                        }
                        .buttonStyle(PrimaryButtonStyle())

                        Button("Even split") {
                            targets = container.planService.distributeTarget(weeklyTarget: container.profile.weeklyTarget, dryDayIndexes: dryDays)
                            persist()
                        }
                        .buttonStyle(SecondaryButtonStyle())
                    }

                    VStack(spacing: 10) {
                        ForEach(Array(weekDates.enumerated()), id: \.offset) { index, date in
                            dayRow(index: index, date: date)
                        }
                    }
                }
                .padding()
            }
            .background(AppTheme.background.ignoresSafeArea())
            .navigationTitle("Weekly Plan")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                let currentDryDays = weekDates.enumerated().compactMap { idx, date in
                    container.log(for: date).isDryPlanned ? idx : nil
                }
                dryDays = Set(currentDryDays)
                targets = weekDates.map { container.log(for: $0).plannedTargetDrinks }
                if targets.allSatisfy({ $0 == 0 }) {
                    targets = container.planService.distributeTarget(weeklyTarget: container.profile.weeklyTarget, dryDayIndexes: dryDays)
                }
            }
        }
    }

    private func dayRow(index: Int, date: Date) -> some View {
        let dayLog = container.log(for: date)

        return HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                VStack(alignment: .leading, spacing: 1) {
                    Text(date.formatted(.dateTime.weekday(.wide)))
                        .font(AppTheme.font(.subheadline, weight: .semibold))
                    Text(date.formatted(date: .abbreviated, time: .omitted))
                        .font(AppTheme.font(.caption2))
                        .foregroundStyle(AppTheme.text.opacity(0.7))
                }

                VStack(alignment: .leading, spacing: 1) {
                    Text("Logged")
                        .font(AppTheme.font(.caption2, weight: .medium))
                        .foregroundStyle(AppTheme.text.opacity(0.65))
                    Text("\(dayLog.totalDrinks, specifier: "%.1f")")
                        .font(AppTheme.font(.callout, weight: .semibold))
                        .foregroundStyle(AppTheme.highlight)
                }

                Toggle("Dry", isOn: Binding(get: { dryDays.contains(index) }, set: { newValue in
                    if newValue {
                        dryDays.insert(index)
                        targets[index] = 0
                    } else {
                        dryDays.remove(index)
                    }
                    persist(index)
                }))
                .font(AppTheme.font(.caption, weight: .semibold))
                .tint(AppTheme.highlight)
                .labelsHidden()

                Text("Dry")
                    .font(AppTheme.font(.caption2, weight: .medium))
                    .foregroundStyle(AppTheme.text.opacity(0.7))
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .leading, spacing: 8) {
                Text("Target")
                    .font(AppTheme.font(.caption, weight: .semibold))
                    .foregroundStyle(AppTheme.text.opacity(0.75))

                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(targets[index], specifier: "%.1f")")
                        .font(AppTheme.font(.title3, weight: .bold))
                        .foregroundStyle(AppTheme.highlight)
                    Text("drinks")
                        .font(AppTheme.font(.caption2))
                        .foregroundStyle(AppTheme.text.opacity(0.7))
                }

                Stepper(value: Binding(get: { targets[index] }, set: {
                    targets[index] = max(0, $0)
                    if targets[index] > 0 {
                        dryDays.remove(index)
                    }
                    persist(index)
                }), in: 0 ... 20, step: 0.5) {
                    Text("Adjust")
                        .font(AppTheme.font(.caption, weight: .medium))
                        .foregroundStyle(AppTheme.text)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(10)
            .background(AppTheme.background.opacity(0.55), in: RoundedRectangle(cornerRadius: 12))
        }
        .padding(12)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 14))
    }

    private func planStat(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(AppTheme.font(.footnote))
                .foregroundStyle(AppTheme.text.opacity(0.8))
            Text(value)
                .font(AppTheme.font(.title3, weight: .bold))
                .foregroundStyle(AppTheme.highlight)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 14))
    }

    private func persist(_ changedIndex: Int? = nil) {
        let sum = targets.reduce(0, +)
        if sum > Double(container.profile.weeklyTarget), let changedIndex {
            let overflow = sum - Double(container.profile.weeklyTarget)
            targets[changedIndex] = max(0, targets[changedIndex] - overflow)
        }
        for (idx, date) in weekDates.enumerated() {
            var log = container.log(for: date)
            log.isDryPlanned = dryDays.contains(idx)
            log.plannedTargetDrinks = targets[idx]
            container.saveLog(log)
        }
    }
}

#Preview {
    PlanView().environmentObject(AppContainer())
}
