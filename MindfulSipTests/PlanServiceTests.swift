import XCTest
@testable import MindfulSip

final class PlanServiceTests: XCTestCase {
    let service = PlanService()

    func testAutoPickDryDaysCount() {
        XCTAssertEqual(service.autoPickDryDays(count: 3, avoidWeekend: false).count, 3)
        XCTAssertEqual(service.autoPickDryDays(count: 0, avoidWeekend: false).count, 0)
    }

    func testDistributionSumsAndDryDaysZero() {
        let dry: Set<Int> = [1, 4]
        let result = service.distributeTarget(weeklyTarget: 11, dryDayIndexes: dry)
        XCTAssertEqual(result.reduce(0,+), 11, accuracy: 0.001)
        XCTAssertEqual(result[1], 0)
        XCTAssertEqual(result[4], 0)
    }
}
