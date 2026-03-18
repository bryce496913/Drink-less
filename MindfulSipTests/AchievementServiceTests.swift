import XCTest
@testable import MindfulSip

final class AchievementServiceTests: XCTestCase {
    let service = AchievementService()
    let dateService = DateService()

    func testCatalogContainsThirtyAchievementsInRequestedOrder() {
        XCTAssertEqual(AchievementService.catalog.count, 30)
        XCTAssertEqual(AchievementService.catalog.first?.title, "First Step")
        XCTAssertEqual(AchievementService.catalog.last?.title, "Mindful Legend")
    }

    func testStatsUnlockAchievementsWhenRequirementsAreExceeded() {
        let today = dateService.startOfDay(.now)
        let logs = (0..<12).map { offset in
            DayLog(
                date: Calendar.current.date(byAdding: .day, value: -offset, to: today)!,
                plannedTargetDrinks: 2,
                isDryPlanned: false,
                totalDrinks: offset < 5 ? 0 : 1,
                updatedAt: .now,
                notes: ""
            )
        }

        let achievements = service.achievements(logs: logs, today: today)

        XCTAssertTrue(achievements.first(where: { $0.id == "first-step" })?.isUnlocked == true)
        XCTAssertTrue(achievements.first(where: { $0.id == "clear-day-duo" })?.isUnlocked == true)
        XCTAssertTrue(achievements.first(where: { $0.id == "goal-streaker" })?.isUnlocked == true)
        XCTAssertFalse(achievements.first(where: { $0.id == "daily-anchor" })?.isUnlocked == true)
        XCTAssertFalse(achievements.first(where: { $0.id == "clear-horizon" })?.isUnlocked == true)
    }

    func testGoalMetDaysCountsPastLogsThatStayedWithinDailyTarget() {
        let today = dateService.startOfDay(.now)
        let logs = [
            DayLog(date: today, plannedTargetDrinks: 0, isDryPlanned: true, totalDrinks: 0, updatedAt: .now, notes: ""),
            DayLog(date: Calendar.current.date(byAdding: .day, value: -1, to: today)!, plannedTargetDrinks: 2, isDryPlanned: false, totalDrinks: 2, updatedAt: .now, notes: ""),
            DayLog(date: Calendar.current.date(byAdding: .day, value: -2, to: today)!, plannedTargetDrinks: 1, isDryPlanned: false, totalDrinks: 3, updatedAt: .now, notes: ""),
            DayLog(date: Calendar.current.date(byAdding: .day, value: 1, to: today)!, plannedTargetDrinks: 1, isDryPlanned: false, totalDrinks: 0, updatedAt: .now, notes: "")
        ]

        XCTAssertEqual(service.goalMetDays(logs: logs, today: today), 2)
    }
}
