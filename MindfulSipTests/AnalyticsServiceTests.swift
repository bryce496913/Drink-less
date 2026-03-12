import XCTest
@testable import MindfulSip

final class AnalyticsServiceTests: XCTestCase {
    let service = AnalyticsService()

    func testSavedClampsToZero() {
        XCTAssertEqual(service.saved(actualWeekly: 12, baselineWeekly: 10, perDrink: 5), 0)
        XCTAssertEqual(service.saved(actualWeekly: 6, baselineWeekly: 10, perDrink: 5), 20)
    }

    func testWeeklyTotalsAndDryDays() {
        let d = DateService()
        let start = d.startOfWeek(.now)
        let logs = (0..<7).map { i in DayLog(date: Calendar.current.date(byAdding: .day, value: i, to: start)!, plannedTargetDrinks: 1, isDryPlanned: false, totalDrinks: i == 0 ? 0 : 1, updatedAt: .now, notes: "") }
        XCTAssertEqual(service.weeklyTotal(logs: logs, weekStart: start), 6)
        XCTAssertEqual(service.weeklyDryDays(logs: logs, weekStart: start), 1)
    }

    func testInsightsAndStreaks() {
        let today = DateService().startOfDay(.now)
        let logs = (0..<20).map { i in
            DayLog(date: Calendar.current.date(byAdding: .day, value: -i, to: today)!, plannedTargetDrinks: 1, isDryPlanned: false, totalDrinks: i < 3 ? 0 : 1, updatedAt: .now, notes: "")
        }
        let insights = service.insights(logs: logs, today: today)
        XCTAssertGreaterThan(insights.last14, 0)
        XCTAssertEqual(insights.dryStreak, 3)
        XCTAssertEqual(insights.loggingStreak, 20)
    }

    func testWeeklyGoalSuccessStreakCountsCompletedWeeksInARow() {
        let dateService = DateService()
        let today = dateService.startOfDay(.now)
        let currentWeekStart = dateService.startOfWeek(today)

        let lastWeek = Calendar.current.date(byAdding: .day, value: -7, to: currentWeekStart)!
        let twoWeeksAgo = Calendar.current.date(byAdding: .day, value: -14, to: currentWeekStart)!
        let threeWeeksAgo = Calendar.current.date(byAdding: .day, value: -21, to: currentWeekStart)!

        let logs = [
            DayLog(date: lastWeek, plannedTargetDrinks: 2, isDryPlanned: false, totalDrinks: 2, updatedAt: .now, notes: ""),
            DayLog(date: twoWeeksAgo, plannedTargetDrinks: 2, isDryPlanned: false, totalDrinks: 1, updatedAt: .now, notes: ""),
            DayLog(date: threeWeeksAgo, plannedTargetDrinks: 2, isDryPlanned: false, totalDrinks: 5, updatedAt: .now, notes: "")
        ]

        XCTAssertEqual(service.weeklyGoalSuccessStreak(logs: logs, weeklyTarget: 3, setupDate: threeWeeksAgo, asOf: today), 2)
    }
    func testWeeklyGoalSuccessStreakStartsAtSetupWeek() {
        let dateService = DateService()
        let today = dateService.startOfDay(.now)
        let currentWeekStart = dateService.startOfWeek(today)

        let lastWeek = Calendar.current.date(byAdding: .day, value: -7, to: currentWeekStart)!
        let setupDate = Calendar.current.date(byAdding: .day, value: -3, to: lastWeek)!

        let logs = [
            DayLog(date: lastWeek, plannedTargetDrinks: 2, isDryPlanned: false, totalDrinks: 2, updatedAt: .now, notes: "")
        ]

        XCTAssertEqual(service.weeklyGoalSuccessStreak(logs: logs, weeklyTarget: 3, setupDate: setupDate, asOf: today), 1)
    }

}
