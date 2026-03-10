import SwiftUI

struct SMSSimulatorView: View {
    @EnvironmentObject var container: AppContainer
    @State private var message = ""

    var body: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()

            Form {
                Text("This simulates receiving a numeric SMS value.")
                TextField("e.g. 1.5", text: $message)
                    .keyboardType(.decimalPad)
                Button("Process message") {
                    let value = Double(message.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
                    let today = container.log(for: .now)
                    container.updateDrinkTotal(date: .now, total: today.totalDrinks + value, delta: value)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("SMS Companion Simulator")
    }
}

#Preview { SMSSimulatorView().environmentObject(AppContainer()) }
