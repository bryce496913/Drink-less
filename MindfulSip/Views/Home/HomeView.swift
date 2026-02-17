import SwiftUI

struct HomeView: View {
    @EnvironmentObject var container: AppContainer
    @State private var amount: Double = 1

    private var todayLog: DayLog {
        container.loggingService.log(for: .now)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Today: \(todayLog.totalDrinks, specifier: "%.1f") drinks")
                    .font(.title2)
                HStack {
                    ForEach([0.5, 1.0, 2.0, 3.0], id: \.self) { quick in
                        Button("+\(quick, specifier: "%.1f")") {
                            container.loggingService.update(date: .now, total: todayLog.totalDrinks + quick, delta: quick)
                            container.refresh()
                        }
                        .buttonStyle(.borderedProminent)
                        .accessibilityLabel("Add \(quick, specifier: "%.1f") drinks")
                    }
                }
                Stepper("Set today total: \(amount, specifier: "%.1f")", value: $amount, in: 0...20, step: 0.5)
                Button("Save total") {
                    container.loggingService.update(date: .now, total: amount)
                    container.refresh()
                }
                .buttonStyle(.bordered)

                Text("Tip of the day")
                    .font(.headline)
                Text(container.tipService.tip(for: .now))
                    .foregroundStyle(.secondary)
                    .padding()
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))

                if todayLog.totalDrinks > todayLog.plannedTargetDrinks, todayLog.plannedTargetDrinks > 0 {
                    Text("You are above today’s target. Consider spacing drinks with water.")
                        .padding(8)
                        .background(Color.orange.opacity(0.2), in: RoundedRectangle(cornerRadius: 8))
                }
                Spacer()
            }
            .padding()
            .navigationTitle("Mindful Sip")
            .toolbar { NavigationLink("Settings", destination: SettingsView()) }
            .onAppear { amount = todayLog.totalDrinks }
        }
    }
}

#Preview {
    HomeView().environmentObject(AppContainer())
}
