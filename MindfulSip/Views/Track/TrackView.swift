import SwiftUI

struct TrackView: View {
    @EnvironmentObject var container: AppContainer

    private let calendar = DateService().calendar
    @State private var selectedDate = Date.now
    @State private var showDayCard = false
    @State private var notesDraft = ""
    @State private var dayAmountDraft: Double = 0
    @State private var noteSaveMessage = ""
    @State private var drinksSaveMessage = ""
    @State private var isAddDrinksExpanded = false

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

    private var isFutureDay: Bool {
        calendar.startOfDay(for: selectedDate) > today
    }

    private var onboardingStartDate: Date? {
        guard container.settings.hasCompletedOnboarding else { return nil }
        return calendar.startOfDay(for: container.profile.createdAt)
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
        GeometryReader { geometry in
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
                        .padding(.horizontal)
                        .padding(.bottom, (showDayCard ? 12 : 0) + 24)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: geometry.size.height, alignment: .top)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .background(AppTheme.background)

                    if showDayCard {
                        dayInfoCard
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                            .zIndex(1)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .safeAreaInset(edge: .top, spacing: 0) {
                    topHeaderBar(title: "Tracking")
                }
                .animation(.spring(response: 0.35, dampingFraction: 0.85), value: showDayCard)
                .appFullscreenContainer()
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
                legendItem(color: .mint, label: "Met goal")
                legendItem(color: .red, label: "Missed goal")
                legendItem(color: .gray, label: "Future")
            }
            Text("★ Setup completed")
                .font(AppTheme.font(.paragraph))
                .foregroundStyle(AppTheme.highlight)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 14))
    }

    private var dayInfoCard: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Capsule()
                    .fill(AppTheme.text.opacity(0.3))
                    .frame(width: 44, height: 5)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 2)

                HStack {
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

                HStack(alignment: .center, spacing: 8) {
                    Button {
                        moveSelectedDay(by: -1)
                    } label: {
                        Image(systemName: "chevron.left")
                    }
                    .buttonStyle(SecondaryButtonStyle())

                    Text(selectedDate.formatted(date: .complete, time: .omitted))
                        .font(AppTheme.font(.headline, weight: .semibold))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)

                    Button {
                        moveSelectedDay(by: 1)
                    } label: {
                        Image(systemName: "chevron.right")
                    }
                    .buttonStyle(SecondaryButtonStyle())
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

                DisclosureGroup(isExpanded: $isAddDrinksExpanded) {
                    VStack(alignment: .leading, spacing: 10) {
                        TrackDrinkQuickAddGrid { amountToAdd, type in
                            guard !isFutureDay else { return }
                            container.updateDrinkTotal(
                                date: selectedDate,
                                total: selectedLog.totalDrinks + amountToAdd,
                                type: type,
                                delta: amountToAdd
                            )
                            dayAmountDraft = container.log(for: selectedDate).totalDrinks
                            showDrinksSavedMessage()
                        }
                        .disabled(isFutureDay)

                        Stepper("Set day total: \(dayAmountDraft, specifier: "%.1f")", value: $dayAmountDraft, in: 0...20, step: 0.5)
                            .font(AppTheme.font(.body))
                            .foregroundStyle(AppTheme.text)
                            .disabled(isFutureDay)

                        Button("Save drinks") {
                            guard !isFutureDay else { return }
                            container.updateDrinkTotal(date: selectedDate, total: dayAmountDraft)
                            showDrinksSavedMessage()
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .disabled(isFutureDay)

                        if isFutureDay {
                            Text("Future dates cannot be edited yet.")
                                .font(AppTheme.font(.caption))
                                .foregroundStyle(AppTheme.text.opacity(0.75))
                        }
                    }
                    .padding(.top, 4)
                } label: {
                    Text("Add drinks")
                        .font(AppTheme.font(.footnote, weight: .semibold))
                        .foregroundStyle(AppTheme.text.opacity(0.8))
                }
                .tint(AppTheme.text)

                if !drinksSaveMessage.isEmpty {
                    Text(drinksSaveMessage)
                        .font(AppTheme.font(.caption))
                        .foregroundStyle(.green)
                        .transition(.opacity)
                }

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
                    showNoteSavedMessage()
                }
                .buttonStyle(PrimaryButtonStyle())

                if !noteSaveMessage.isEmpty {
                    Text(noteSaveMessage)
                        .font(AppTheme.font(.caption))
                        .foregroundStyle(.green)
                        .transition(.opacity)
                }
            }
            .padding(16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(
            LinearGradient(
                colors: [Color(red: 0.15, green: 0.06, blue: 0.25), Color(red: 0.09, green: 0.03, blue: 0.16)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(AppTheme.accent.opacity(0.35), lineWidth: 1)
        )
        .padding(.horizontal)
        .padding(.top, 96)
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
            loadSelectedDayDrafts()
            withAnimation { showDayCard = true }
        } label: {
            Text("\(calendar.component(.day, from: date))")
                .font(AppTheme.font(.callout, weight: .semibold))
                .foregroundStyle(AppTheme.text)
                .frame(maxWidth: .infinity)
                .frame(height: 42)
                .background(drinkColor(for: log, on: date), in: RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isSelected ? AppTheme.text : Color.clear, lineWidth: 2)
                )
                .overlay(alignment: .topTrailing) {
                    if isOnboardingStart(date) {
                        Text("★")
                            .font(AppTheme.font(.paragraph, weight: .bold))
                            .foregroundStyle(AppTheme.highlight)
                            .padding(3)
                    }
                }
        }
        .buttonStyle(.plain)
    }

    private func drinkColor(for log: DayLog, on date: Date) -> Color {
        if let onboardingStartDate, calendar.startOfDay(for: date) < onboardingStartDate {
            return .gray.opacity(0.3)
        }

        if calendar.startOfDay(for: date) > today {
            return .gray.opacity(0.45)
        }

        if log.totalDrinks == 0 {
            return .green.opacity(0.85)
        }

        let metGoal = log.totalDrinks <= log.plannedTargetDrinks
        return metGoal ? .mint.opacity(0.85) : .red.opacity(0.85)
    }

    private func showNoteSavedMessage() {
        noteSaveMessage = "Notes saved"
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            noteSaveMessage = ""
        }
    }

    private func showDrinksSavedMessage() {
        drinksSaveMessage = "Drinks saved"
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            drinksSaveMessage = ""
        }
    }

    private func moveSelectedDay(by value: Int) {
        selectedDate = calendar.date(byAdding: .day, value: value, to: selectedDate) ?? selectedDate
        loadSelectedDayDrafts()
    }

    private func loadSelectedDayDrafts() {
        let log = container.log(for: selectedDate)
        notesDraft = log.notes
        dayAmountDraft = log.totalDrinks
        noteSaveMessage = ""
        drinksSaveMessage = ""
    }

    private func isOnboardingStart(_ date: Date) -> Bool {
        guard let onboardingStartDate else { return false }
        return calendar.isDate(date, inSameDayAs: onboardingStartDate)
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

    private func topHeaderBar(title: String) -> some View {
        VStack(spacing: 0) {
            Text(title)
                .font(AppTheme.font(.headline, weight: .semibold))
                .foregroundStyle(AppTheme.text)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 16)
                .padding(.top, 6)
                .padding(.bottom, 10)

            Rectangle()
                .fill(AppTheme.highlight.opacity(0.2))
                .frame(height: 1)
        }
        .background(AppTheme.background.opacity(0.96))
    }

}

#Preview {
    TrackView().environmentObject(AppContainer())
}

private struct TrackDrinkQuickAddGrid: View {
    let onAdd: (Double, DrinkType) -> Void

    private let options: [(title: String, icon: String, amount: Double)] = [
        ("Wine", "🍷", 1.0),
        ("Beer", "🍺", 1.0),
        ("Shot", "🥃", 0.5),
        ("Large Beer", "🍺", 1.5),
        ("Cocktail", "🍸", 1.5),
        ("Double Shot", "🥃", 2.0)
    ]

    private func drinkType(for title: String) -> DrinkType {
        switch title {
        case "Wine":
            return .wine
        case "Beer", "Large Beer":
            return .beer
        case "Shot", "Double Shot":
            return .spirits
        case "Cocktail":
            return .cocktail
        default:
            return .other
        }
    }

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
            ForEach(options, id: \.title) { option in
                Button {
                    onAdd(option.amount, drinkType(for: option.title))
                } label: {
                    VStack(spacing: 4) {
                        Text(option.icon)
                            .font(.system(size: 18))
                        Text(option.title)
                            .font(AppTheme.font(.caption2, weight: .semibold))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(AppTheme.text)
                        Text("+\(option.amount, specifier: "%.1f")")
                            .font(AppTheme.font(.caption2))
                            .foregroundStyle(AppTheme.highlight)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(AppTheme.background.opacity(0.55), in: RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
            }
        }
    }
}
