import XCTest
@testable import HabitMonCore

final class EvolutionTests: XCTestCase {
    func testStageZeroBelowFirstThreshold() {
        XCTAssertEqual(Evolution.stage(forXP: 0), 0)
        XCTAssertEqual(Evolution.stage(forXP: 49), 0)
    }

    func testStageOneAtAndAboveFirstThreshold() {
        XCTAssertEqual(Evolution.stage(forXP: 50), 1)
        XCTAssertEqual(Evolution.stage(forXP: 149), 1)
    }

    func testStageTwoAtAndAboveSecondThreshold() {
        XCTAssertEqual(Evolution.stage(forXP: 150), 2)
        XCTAssertEqual(Evolution.stage(forXP: 10_000), 2, "Stage caps at 2 — no stage beyond the top threshold in v1")
    }
}
