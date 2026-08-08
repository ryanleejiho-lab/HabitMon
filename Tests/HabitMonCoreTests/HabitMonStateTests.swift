import XCTest
@testable import HabitMonCore

final class HabitMonStateTests: XCTestCase {
    func testEmptyStateHasZeroXPForEveryType() {
        let state = HabitMonState.empty
        for type in HabitType.allCases {
            XCTAssertEqual(state.xp(for: type), 0)
        }
    }

    func testAddXPAccumulates() {
        var state = HabitMonState.empty
        state.addXP(10, to: .fire)
        state.addXP(5, to: .fire)
        state.addXP(20, to: .wisdom)
        XCTAssertEqual(state.xp(for: .fire), 15)
        XCTAssertEqual(state.xp(for: .wisdom), 20)
        XCTAssertEqual(state.xp(for: .nature), 0)
    }

    func testJSONShapeMatchesDesignSpec() throws {
        var state = HabitMonState.empty
        state.addXP(10, to: .fire)
        let data = try JSONEncoder().encode(state)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let statXP = json?["statXP"] as? [String: Any]
        XCTAssertEqual(statXP?["fire"] as? Int, 10)
    }

    func testRoundTripEncodeDecode() throws {
        var state = HabitMonState.empty
        state.addXP(50, to: .storm)
        state.creditedTaskIDs.insert(UUID())
        let data = try JSONEncoder().encode(state)
        let decoded = try JSONDecoder().decode(HabitMonState.self, from: data)
        XCTAssertEqual(decoded, state)
    }
}
