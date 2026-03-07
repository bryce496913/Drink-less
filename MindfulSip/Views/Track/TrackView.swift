import SwiftUI

struct TrackView: View {
    @EnvironmentObject var container: AppContainer

    private let calendar = Calendar.current
    @State private var selectedDate = Date()

    private var monthDates: [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: selectedDate),
              let firstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start),
              let lastMoment = calendar.date(byAdding: .day, value: -1, to: monthInterval.end),
              let lastWeek = calendar.dateInterval(of: .weekOfMonth, for: lastMoment)
        else {
            return []
        }

        var dates: [Date] = []
        var cursor = firstWeek.start
        while cursor < lastWeek.end {
            dates.append(cursor)
            guard let next = calendar.date(byAdding: .day, value: 1, to: cursor) else { break }
            cursor = next
        }
        return dates
    }

    private var monthTitle: String {
        selectedDate.formatted(.dateTime.month(.wide).year())
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    HStack {
                        Button {
                            selectedDate = calendar.date(byAdding: .month, value: -1, to: selectedDate) ?? selectedDate
                        } label: {
                            Image(systemName: "chevron.left")
                        }
                        .buttonStyle(SecondaryButtonStyle())

                        Spacer()
                        Text(monthTitle)
                            .font(AppTheme.font(.headline, weight: .semibold))
                            .foregroundStyle(AppTheme.text)
                        Spacer()

                        Button {
                            selectedDate = calendar.date(byAdding: .month, value: 1, to: selectedDate) ?? selectedDate
                        } label: {
                            Image(systemName: "chevron.right")
                        }
                        .buttonStyle(SecondaryButtonStyle())
                    }

                    weekHeader

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 8) {
                        ForEach(monthDates, id: \.self) { date in
                            if calendar.isDate(date, equalTo: selectedDate, toGranularity: .month) {
                                calendarCell(for: date)
                            } else {
                                Color.clear.frame(height: 42)
                            }
                        }
                    }

                    legend

                    let log = container.log(for: selectedDate)
                    NavigationLink {
                        DayEditorView(date: selectedDate, log: log)
                    } label: {
                        HStack {
                            Text("Selected: \(selectedDate.formatted(date: .abbreviated, time: .omitted))")
                            Spacer()
                            Text("\(log.totalDrinks, specifier: "%.1f") drinks")
                                .foregroundStyle(AppTheme.highlight)
                        }
                        .font(AppTheme.font(.body))
                        .padding(12)
                        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 14))
                    }
                }
                .padding()
            }
            .background(AppTheme.background.ignoresSafeArea())
            .navigationTitle("Tracking")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var weekHeader: some View {
        let days = calendar.shortWeekdaySymbols
        return HStack {
            ForEach(days, id: \.self) { day in
                Text(day)
                    .font(AppTheme.font(.caption, weight: .semibold))
                    .foregroundStyle(AppTheme.text.opacity(0.75))
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var legend: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Color key")
                .font(AppTheme.font(.footnote, weight: .semibold))
                .foregroundStyle(AppTheme.text.opacity(0.8))
            HStack {
                legendItem(color: .green, label: "0 drinks")
                legendItem(color: .yellow, label: "0.5 - 2")
                legendItem(color: .orange, label: "2.5 - 4")
                legendItem(color: .red, label: "4+")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 14))
    }

    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 5) {
            Circle().fill(color).frame(width: 9, height: 9)
            Text(label)
                .font(AppTheme.font(.caption2))
                .foregroundStyle(AppTheme.text)
        }
    }

    private func calendarCell(for date: Date) -> some View {
        let log = container.log(for: date)
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)

        return Button {
            selectedDate = date
        } label: {
            Text("\(calendar.component(.day, from: date))")
                .font(AppTheme.font(.callout, weight: .semibold))
                .foregroundStyle(AppTheme.text)
                .frame(maxWidth: .infinity)
                .frame(height: 42)
                .background(drinkColor(for: log.totalDrinks), in: RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isSelected ? AppTheme.text : Color.clear, lineWidth: 2)
                )
        }
        .buttonStyle(.plain)
    }

    private func drinkColor(for total: Double) -> Color {
        switch total {
        case 0: return .green.opacity(0.85)
        case 0.5 ... 2: return .yellow.opacity(0.8)
        case 2.5 ... 4: return .orange.opacity(0.85)
        default: return .red.opacity(0.85)
        }
    }
}

struct DayEditorView: View {
    @EnvironmentObject var container: AppContainer
    let date: Date
    @State var log: DayLog

    var body: some View {
        Form {
            Stepper("Total drinks: \(log.totalDrinks, specifier: "%.1f")", value: $log.totalDrinks, in: 0 ... 30, step: 0.5)
            if log.isDryPlanned && log.totalDrinks > 0 {
                Text("This is marked as a dry day.").foregroundStyle(AppTheme.highlight)
            }
            Button("Save") { container.saveLog(log) }
                .buttonStyle(PrimaryButtonStyle())
                .listRowBackground(AppTheme.surface)
        }
        .scrollContentBackground(.hidden)
        .background(AppTheme.background)
        .navigationTitle(date.formatted(date: .abbreviated, time: .omitted))
    }
}

#Preview {
    TrackView().environmentObject(AppContainer())
}
