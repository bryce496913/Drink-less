import SwiftUI

struct TrackView: View {
    @EnvironmentObject var container: AppContainer

    var body: some View {
        NavigationStack {
            List {
                ForEach((0..<30), id: \.self) { offset in
                    let date = Calendar.current.date(byAdding: .day, value: -offset, to: .now) ?? .now
                    let log = container.loggingService.log(for: date)
                    NavigationLink {
                        DayEditorView(date: date, log: log)
                    } label: {
                        HStack {
                            Text(date.formatted(date: .abbreviated, time: .omitted))
                            Spacer()
                            Text("\(log.totalDrinks, specifier: "%.1f")")
                        }
                    }
                }
            }
            .navigationTitle("Edit Past Days")
            .toolbar { NavigationLink("SMS Sim", destination: SMSSimulatorView()) }
        }
    }
}

struct DayEditorView: View {
    @EnvironmentObject var container: AppContainer
    let date: Date
    @State var log: DayLog

    var body: some View {
        Form {
            Stepper("Total drinks: \(log.totalDrinks, specifier: "%.1f")", value: $log.totalDrinks, in: 0...30, step: 0.5)
            if log.isDryPlanned && log.totalDrinks > 0 {
                Text("This is marked as a dry day.").foregroundStyle(.orange)
            }
            Button("Save") { container.saveLog(log) }
        }
        .navigationTitle(date.formatted(date: .abbreviated, time: .omitted))
    }
}

#Preview {
    TrackView().environmentObject(AppContainer())
}
