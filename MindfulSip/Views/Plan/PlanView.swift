import SwiftUI

struct PlanView: View {
    @EnvironmentObject var container: AppContainer
    let dateService = DateService()

    @State private var dryDays: Set<Int> = []
    @State private var targets: [Double] = Array(repeating: 0, count: 7)

    var weekDates: [Date] { dateService.weekDates(from: .now) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    HStack(spacing: 10) {
                        planStat(title: "Weekly target", value: "\(container.profile.weeklyTarget)")
                        planStat(title: "Dry days goal", value: "\(container.profile.dryDaysTarget)")
                    }

                    Button("Auto-pick dry days") {
                        dryDays = container.planService.autoPickDryDays(count: container.profile.dryDaysTarget, avoidWeekend: container.settings.avoidWeekendForAutoDry)
                        targets = container.planService.distributeTarget(weeklyTarget: container.profile.weeklyTarget, dryDayIndexes: dryDays)
                        persist()
                    }
                    .buttonStyle(PrimaryButtonStyle())

                    ForEach(Array(weekDates.enumerated()), id: \.offset) { index, date in
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(date.formatted(.dateTime.weekday(.wide)))
                                        .font(AppTheme.font(.headline, weight: .semibold))
                                    Text(date.formatted(date: .abbreviated, time: .omitted))
                                        .font(AppTheme.font(.caption))
                                        .foregroundStyle(AppTheme.text.opacity(0.7))
                                }
                                Spacer()
                                Text("Logged \(container.log(for: date).totalDrinks, specifier: "%.1f")")
                                    .font(AppTheme.font(.footnote))
                                    .foregroundStyle(AppTheme.highlight)
                            }

                            Toggle("Dry day", isOn: Binding(get: { dryDays.contains(index) }, set: { newValue in
                                if newValue { dryDays.insert(index) } else { dryDays.remove(index) }
                                targets = container.planService.distributeTarget(weeklyTarget: container.profile.weeklyTarget, dryDayIndexes: dryDays)
                                persist()
                            }))
                            .tint(AppTheme.highlight)

                            Stepper(value: Binding(get: { targets[index] }, set: {
                                targets[index] = max(0, $0)
                                persist(index)
                            }), in: 0 ... 20, step: 0.5) {
                                Text("Target drinks: \(targets[index], specifier: "%.1f")")
                                    .foregroundStyle(AppTheme.text)
                            }
                        }
                        .padding(14)
                        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 16))
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
