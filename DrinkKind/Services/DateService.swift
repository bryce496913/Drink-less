import Foundation

struct DateService {
    let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2 // Monday
        return calendar
    }()

    func startOfDay(_ date: Date) -> Date { calendar.startOfDay(for: date) }

    func startOfWeek(_ date: Date) -> Date {
        let comps = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return calendar.date(from: comps) ?? startOfDay(date)
    }

    func weekDates(from date: Date) -> [Date] {
        let start = startOfWeek(date)
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: start) }
    }
}
