import XCTest
@testable import HabitMonCore

final class HabitTypeTests: XCTestCase {
    func testRawValuesMatchBoringNotchChecklist() {
        // These raw values MUST match boring.notch's HabitType enum exactly —
        // that's the shared JSON contract between the two apps.
        XCTAssertEqual(HabitType.fire.rawValue, "fire")
        XCTAssertEqual(HabitType.wisdom.rawValue, "wisdom")
        XCTAssertEqual(HabitType.nature.rawValue, "nature")
        XCTAssertEqual(HabitType.water.rawValue, "water")
        XCTAssertEqual(HabitType.storm.rawValue, "storm")
    }

    func testAllCasesHasExactlyFiveTypes() {
        XCTAssertEqual(HabitType.allCases.count, 5)
    }

    func testDisplayNames() {
        XCTAssertEqual(HabitType.fire.displayName, "Fire")
        XCTAssertEqual(HabitType.wisdom.displayName, "Wisdom")
        XCTAssertEqual(HabitType.nature.displayName, "Nature")
        XCTAssertEqual(HabitType.water.displayName, "Water")
        XCTAssertEqual(HabitType.storm.displayName, "Storm")
    }

    func testDecodesFromRawStringJSON() throws {
        let json = "\"fire\"".data(using: .utf8)!
        let decoded = try JSONDecoder().decode(HabitType.self, from: json)
        XCTAssertEqual(decoded, .fire)
    }
}
