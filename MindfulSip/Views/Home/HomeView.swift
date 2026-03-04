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
                VStack(spacing: 6) {
                    Text("Mindful Sip")
                        .font(AppTheme.font(.title, weight: .bold))
                        .foregroundStyle(AppTheme.text)
                    Text("Today: \(todayLog.totalDrinks, specifier: "%.1f") drinks")
                        .font(AppTheme.font(.title3, weight: .medium))
                        .foregroundStyle(AppTheme.highlight)
                }

                HStack {
                    ForEach([0.5, 1.0, 2.0, 3.0], id: \.self) { quick in
                        Button("+\(quick, specifier: "%.1f")") {
                            container.loggingService.update(date: .now, total: todayLog.totalDrinks + quick, delta: quick)
                            container.refresh()
                        }
                        .buttonStyle(SecondaryButtonStyle())
                        .accessibilityLabel("Add \(quick, specifier: "%.1f") drinks")
                    }
                }

                VStack(spacing: 10) {
                    Stepper("Set today total: \(amount, specifier: "%.1f")", value: $amount, in: 0...20, step: 0.5)
                        .foregroundStyle(AppTheme.text)
                    Button("Save total") {
                        container.loggingService.update(date: .now, total: amount)
                        container.refresh()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
                .padding(16)
                .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 16))

                VStack(alignment: .leading, spacing: 8) {
                    Text("Tip of the day")
                        .font(AppTheme.font(.headline, weight: .semibold))
                    Text(container.tipService.tip(for: .now))
                        .font(AppTheme.font(.body))
                        .foregroundStyle(AppTheme.text.opacity(0.9))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 16))

                if todayLog.totalDrinks > todayLog.plannedTargetDrinks, todayLog.plannedTargetDrinks > 0 {
                    Text("You are above today’s target. Try water between drinks.")
                        .font(AppTheme.font(.footnote))
                        .foregroundStyle(AppTheme.text)
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(AppTheme.highlight.opacity(0.35), in: RoundedRectangle(cornerRadius: 12))
                }
                Spacer()
            }
            .padding()
            .background(AppTheme.background.ignoresSafeArea())
            .navigationTitle("")
            .toolbar { NavigationLink("Settings", destination: SettingsView()) }
            .onAppear { amount = todayLog.totalDrinks }
        }
    }
}

#Preview {
    HomeView().environmentObject(AppContainer())
}
