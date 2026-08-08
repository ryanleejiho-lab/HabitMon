import XCTest
@testable import HabitMonCore

final class ChecklistCreditorTests: XCTestCase {
    func testCreditsNewDoneTaggedItem() {
        let id = UUID()
        let items = [ChecklistSourceItem(id: id, isDone: true, type: .fire)]
        let result = ChecklistCreditor.apply(sourceItems: items, to: .empty)
        XCTAssertEqual(result.xp(for: .fire), 10)
        XCTAssertTrue(result.creditedTaskIDs.contains(id))
    }

    func testDoesNotCreditAlreadyCreditedItem() {
        let id = UUID()
        var state = HabitMonState.empty
        state.addXP(10, to: .fire)
        state.creditedTaskIDs.insert(id)
        let items = [ChecklistSourceItem(id: id, isDone: true, type: .fire)]

        let result = ChecklistCreditor.apply(sourceItems: items, to: state)
        XCTAssertEqual(result.xp(for: .fire), 10, "Re-processing the same completed task must not double-award XP")
    }

    func testDoesNotCreditDoneButUntaggedItem() {
        let items = [ChecklistSourceItem(id: UUID(), isDone: true, type: nil)]
        let result = ChecklistCreditor.apply(sourceItems: items, to: .empty)
        XCTAssertEqual(result.creditedTaskIDs.count, 0)
        for type in HabitType.allCases {
            XCTAssertEqual(result.xp(for: type), 0)
        }
    }

    func testDoesNotCreditUndoneTaggedItem() {
        let items = [ChecklistSourceItem(id: UUID(), isDone: false, type: .wisdom)]
        let result = ChecklistCreditor.apply(sourceItems: items, to: .empty)
        XCTAssertEqual(result.xp(for: .wisdom), 0)
        XCTAssertEqual(result.creditedTaskIDs.count, 0)
    }

    func testMultipleItemsCreditDifferentStatsIndependently() {
        let items = [
            ChecklistSourceItem(id: UUID(), isDone: true, type: .fire),
            ChecklistSourceItem(id: UUID(), isDone: true, type: .fire),
            ChecklistSourceItem(id: UUID(), isDone: true, type: .wisdom),
        ]
        let result = ChecklistCreditor.apply(sourceItems: items, to: .empty)
        XCTAssertEqual(result.xp(for: .fire), 20)
        XCTAssertEqual(result.xp(for: .wisdom), 10)
        XCTAssertEqual(result.xp(for: .nature), 0)
    }

    func testPrunesCreditedIDNoLongerPresentInSource() {
        // Simulates boring.notch's own daily rollover deleting a checked-off item —
        // once it's gone from the source entirely, its credited ID can never reappear,
        // so it's safe (and correct) to drop from creditedTaskIDs.
        let goneID = UUID()
        var state = HabitMonState.empty
        state.addXP(10, to: .fire)
        state.creditedTaskIDs.insert(goneID)

        let result = ChecklistCreditor.apply(sourceItems: [], to: state)
        XCTAssertFalse(result.creditedTaskIDs.contains(goneID))
        XCTAssertEqual(result.xp(for: .fire), 10, "Pruning a credited ID must not claw back already-earned XP")
    }

    func testDoesNotPruneCreditedIDStillPresentEvenIfNowUnchecked() {
        // Design spec: pruning is based on the ID's mere presence in the source file,
        // regardless of isDone — only actual deletion (rollover) should prune it.
        let id = UUID()
        var state = HabitMonState.empty
        state.creditedTaskIDs.insert(id)
        let items = [ChecklistSourceItem(id: id, isDone: false, type: .fire)]

        let result = ChecklistCreditor.apply(sourceItems: items, to: state)
        XCTAssertTrue(result.creditedTaskIDs.contains(id))
    }

    func testApplyingSameSnapshotTwiceIsIdempotent() {
        let items = [ChecklistSourceItem(id: UUID(), isDone: true, type: .storm)]
        let once = ChecklistCreditor.apply(sourceItems: items, to: .empty)
        let twice = ChecklistCreditor.apply(sourceItems: items, to: once)
        XCTAssertEqual(once, twice)
    }

    func testCustomXPPerTaskIsRespected() {
        let items = [ChecklistSourceItem(id: UUID(), isDone: true, type: .fire)]
        let result = ChecklistCreditor.apply(sourceItems: items, to: .empty, xpPerTask: 25)
        XCTAssertEqual(result.xp(for: .fire), 25)
    }

    func testAlreadyCreditedGuardIgnoresTypeChanges() {
        // If a future refactor ever compared on (id, type) instead of id alone, this is the
        // test that would catch a partial re-credit into the new stat.
        let id = UUID()
        var state = HabitMonState.empty
        state.addXP(10, to: .fire)
        state.creditedTaskIDs.insert(id)
        // Same ID reappears done again, but now tagged wisdom instead of fire.
        let items = [ChecklistSourceItem(id: id, isDone: true, type: .wisdom)]

        let result = ChecklistCreditor.apply(sourceItems: items, to: state)
        XCTAssertEqual(result.xp(for: .fire), 10, "Original credit untouched")
        XCTAssertEqual(result.xp(for: .wisdom), 0, "Must not re-credit into the new type — guard is ID-based, not (id, type)-based")
    }
}
