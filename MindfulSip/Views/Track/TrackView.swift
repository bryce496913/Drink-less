import SwiftUI

struct TrackView: View {
    @EnvironmentObject var container: AppContainer

    private let calendar = DateService().calendar
    @State private var selectedDate = Date.now
    @State private var showDayCard = false
    @State private var notesDraft = ""

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

    private var dayMoneySpent: Double {
        selectedLog.totalDrinks * container.profile.costPerDrink
    }

    private var dayCalories: Double {
        selectedLog.totalDrinks * container.profile.caloriesPerDrink
    }

    private var targetStatus: (text: String, color: Color) {
        if selectedLog.plannedTargetDrinks == 0 {
            return selectedLog.totalDrinks == 0 ? ("On target", .green) : ("Above target", .red)
        }
        if selectedLog.totalDrinks < selectedLog.plannedTargetDrinks {
            return ("Below target", .green)
        }
        if selectedLog.totalDrinks == selectedLog.plannedTargetDrinks {
            return ("On target", .green)
        }
        return ("Above target", .red)
    }

    private var drinkTypesSummary: String {
        let typedEntries = selectedLog.entries.compactMap(\.type)
        guard !typedEntries.isEmpty else {
            return "No drink types logged for this day."
        }

        let counts = Dictionary(grouping: typedEntries, by: { $0 }).mapValues(\.count)
        let ordered: [DrinkType] = [.wine, .beer, .spirits, .cocktail, .other]

        return ordered.compactMap { type in
            guard let count = counts[type] else { return nil }
            return "\(emoji(for: type)) x\(count)"
        }
        .joined(separator: "  ")
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
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
                    }
                    .padding()
                    .padding(.bottom, showDayCard ? 390 : 0)
                }
                .background(AppTheme.background.ignoresSafeArea())
                .navigationTitle("Tracking")
                .navigationBarTitleDisplayMode(.inline)

                if showDayCard {
                    dayInfoCard
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .zIndex(1)
                }
            }
            .animation(.spring(response: 0.35, dampingFraction: 0.85), value: showDayCard)
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

    private var dayInfoCard: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .center) {
                    Text(selectedDate.formatted(date: .complete, time: .omitted))
                        .font(AppTheme.font(.headline, weight: .semibold))
                    Spacer()
                    Button {
                        withAnimation {
                            showDayCard = false
                        }
                    } label: {
                        Image(systemName: "xmark")
                            .font(AppTheme.font(.caption, weight: .semibold))
                            .foregroundStyle(AppTheme.text)
                            .padding(7)
                            .background(AppTheme.background.opacity(0.7), in: Circle())
                    }
                    .buttonStyle(.plain)
                }

                HStack(spacing: 10) {
                    detailPill(title: "Money spent", value: "$\(String(format: "%.0f", dayMoneySpent))")
                    detailPill(title: "Calories", value: "\(String(format: "%.0f", dayCalories))")
                }

                HStack(alignment: .top, spacing: 10) {
                    detailPill(title: "Target", value: "\(String(format: "%.1f", selectedLog.plannedTargetDrinks))")
                        .frame(maxWidth: 130)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Status")
                            .font(AppTheme.font(.caption2))
                            .foregroundStyle(AppTheme.text.opacity(0.75))

                        Label(targetStatus.text, systemImage: targetStatus.text == "Above target" ? "arrow.up.circle.fill" : "checkmark.circle.fill")
                            .font(AppTheme.font(.body, weight: .semibold))
                            .foregroundStyle(targetStatus.color)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(8)
                    .background(AppTheme.background.opacity(0.6), in: RoundedRectangle(cornerRadius: 10))
                }

                detailPill(title: "Types", value: drinkTypesSummary)

                Text("Notes")
                    .font(AppTheme.font(.footnote, weight: .semibold))
                    .foregroundStyle(AppTheme.text.opacity(0.8))

                TextEditor(text: $notesDraft)
                    .font(AppTheme.font(.body))
                    .frame(minHeight: 72, maxHeight: 110)
                    .padding(6)
                    .background(AppTheme.background.opacity(0.55), in: RoundedRectangle(cornerRadius: 10))

                Button("Save notes") {
                    var updated = selectedLog
                    updated.notes = notesDraft
                    container.saveLog(updated)
                }
                .buttonStyle(PrimaryButtonStyle())
            }
            .padding(16)
        }
        .frame(maxHeight: 370)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 18))
        .padding(.horizontal)
        .padding(.bottom, 12)
    }

    private func detailPill(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(AppTheme.font(.caption2))
                .foregroundStyle(AppTheme.text.opacity(0.75))
            Text(value)
                .font(AppTheme.font(.footnote, weight: .semibold))
                .foregroundStyle(AppTheme.highlight)
                .multilineTextAlignment(.leading)
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
            notesDraft = container.log(for: date).notes
            withAnimation {
                showDayCard = true
            }
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

    private func emoji(for type: DrinkType) -> String {
        switch type {
        case .wine: return "🍷"
        case .beer: return "🍺"
        case .spirits: return "🥃"
        case .cocktail: return "🍸"
        case .other: return "🍹"
        }
    }
}

#Preview {
    TrackView().environmentObject(AppContainer())
}
