import SwiftUI

struct PlanView: View {
    @EnvironmentObject var container: AppContainer
    let dateService = DateService()

    @State private var dryDays: Set<Int> = []
    @State private var targets: [Double] = Array(repeating: 0, count: 7)

    var weekDates: [Date] { dateService.weekDates(from: .now) }

    var body: some View {
        NavigationStack {
            List {
                Button("Auto-pick dry days") {
                    dryDays = container.planService.autoPickDryDays(count: container.profile.dryDaysTarget, avoidWeekend: container.settings.avoidWeekendForAutoDry)
                    targets = container.planService.distributeTarget(weeklyTarget: container.profile.weeklyTarget, dryDayIndexes: dryDays)
                    persist()
                }
                .buttonStyle(.plain)
                .foregroundStyle(AppTheme.highlight)

                ForEach(Array(weekDates.enumerated()), id: \.offset) { index, date in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(date.formatted(.dateTime.weekday(.wide)))
                                .font(AppTheme.font(.headline, weight: .semibold))
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
                        Stepper(value: Binding(get: { targets[index] }, set: { targets[index] = max(0, $0); persist(index) }), in: 0...20, step: 0.5) {
                            Text("Target: \(targets[index], specifier: "%.1f")")
                        }
                    }
                    .padding(.vertical, 6)
                    .listRowBackground(AppTheme.surface)
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppTheme.background)
            .navigationTitle("Weekly Plan")
            .onAppear {
                targets = container.planService.distributeTarget(weeklyTarget: container.profile.weeklyTarget, dryDayIndexes: dryDays)
            }
        }
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
