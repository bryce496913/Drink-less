import SwiftUI

struct TrackView: View {
    @EnvironmentObject var container: AppContainer

    private let calendar = DateService().calendar
    @State private var selectedDate = Date.now

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

    private var today: Date {
        calendar.startOfDay(for: container.currentDate)
    }

    private var selectedLog: DayLog {
        container.log(for: selectedDate)
    }

    private var metGoal: Bool {
        selectedLog.totalDrinks <= selectedLog.plannedTargetDrinks
    }

    private var isPastSelectedDate: Bool {
        calendar.startOfDay(for: selectedDate) < today
    }

    private var hasLoggedInfo: Bool {
        selectedLog.totalDrinks > 0 || !selectedLog.notes.isEmpty || selectedLog.plannedTargetDrinks > 0 || selectedLog.isDryPlanned
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
                    selectedDateMetricsSection

                    NavigationLink {
                        DayEditorView(date: selectedDate, log: selectedLog)
                    } label: {
                        Label("Edit selected day", systemImage: "square.and.pencil")
                            .font(AppTheme.font(.body, weight: .semibold))
                            .foregroundStyle(AppTheme.text)
                            .frame(maxWidth: .infinity)
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
        let mondayFirst = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        return HStack {
            ForEach(mondayFirst, id: \.self) { day in
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
                legendItem(color: .gray, label: "Future")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 14))
    }

    @ViewBuilder
    private var selectedDateMetricsSection: some View {
        if isPastSelectedDate, hasLoggedInfo {
            dateDetailCard
        } else {
            Text("Select a past day with logged data to view complete metrics.")
                .font(AppTheme.font(.footnote))
                .foregroundStyle(AppTheme.text.opacity(0.75))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 14))
        }
    }

    private var dateDetailCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(selectedDate.formatted(date: .complete, time: .omitted))
                .font(AppTheme.font(.headline, weight: .semibold))

            HStack(spacing: 10) {
                detailPill(title: "Drinks", value: String(format: "%.1f", selectedLog.totalDrinks))
                detailPill(title: "Target", value: String(format: "%.1f", selectedLog.plannedTargetDrinks))
                detailPill(title: "Diff", value: String(format: "%+.1f", selectedLog.totalDrinks - selectedLog.plannedTargetDrinks))
            }

            HStack(spacing: 10) {
                detailPill(title: "Cost", value: "$" + String(format: "%.0f", selectedLog.totalDrinks * container.profile.costPerDrink))
                detailPill(title: "Calories", value: String(format: "%.0f", selectedLog.totalDrinks * container.profile.caloriesPerDrink))
                detailPill(title: "Dry planned", value: selectedLog.isDryPlanned ? "Yes" : "No")
            }

            Text("Notes")
                .font(AppTheme.font(.footnote, weight: .semibold))
                .foregroundStyle(AppTheme.text.opacity(0.8))
            Text(selectedLog.notes.isEmpty ? "No notes for this day." : selectedLog.notes)
                .font(AppTheme.font(.body))
                .foregroundStyle(AppTheme.text)

            Label(metGoal ? "Met goal" : "Goal missed", systemImage: metGoal ? "checkmark.circle" : "xmark.circle")
                .font(AppTheme.font(.body, weight: .semibold))
                .foregroundStyle(metGoal ? .green : .red)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 14))
    }

    private func detailPill(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(AppTheme.font(.caption2))
                .foregroundStyle(AppTheme.text.opacity(0.75))
            Text(value)
                .font(AppTheme.font(.footnote, weight: .semibold))
                .foregroundStyle(AppTheme.highlight)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(8)
        .background(AppTheme.background.opacity(0.6), in: RoundedRectangle(cornerRadius: 10))
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
                .background(drinkColor(for: log.totalDrinks, on: date), in: RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isSelected ? AppTheme.text : Color.clear, lineWidth: 2)
                )
        }
        .buttonStyle(.plain)
    }

    private func drinkColor(for total: Double, on date: Date) -> Color {
        if calendar.startOfDay(for: date) > today {
            return .gray.opacity(0.45)
        }

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
            Section("Notes") {
                TextField("How did today go?", text: $log.notes, axis: .vertical)
                    .lineLimit(3...6)
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
