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
        let logs = (0..<7).map { i in DayLog(date: Calendar.current.date(byAdding: .day, value: i, to: start)!, plannedTargetDrinks: 1, isDryPlanned: false, totalDrinks: i == 0 ? 0 : 1, updatedAt: .now) }
        XCTAssertEqual(service.weeklyTotal(logs: logs, weekStart: start), 6)
        XCTAssertEqual(service.weeklyDryDays(logs: logs, weekStart: start), 1)
    }

    func testInsightsAndStreaks() {
        let today = DateService().startOfDay(.now)
        let logs = (0..<20).map { i in
            DayLog(date: Calendar.current.date(byAdding: .day, value: -i, to: today)!, plannedTargetDrinks: 1, isDryPlanned: false, totalDrinks: i < 3 ? 0 : 1, updatedAt: .now)
        }
        let insights = service.insights(logs: logs, today: today)
        XCTAssertGreaterThan(insights.last14, 0)
        XCTAssertEqual(insights.dryStreak, 3)
        XCTAssertEqual(insights.loggingStreak, 20)
    }
}
