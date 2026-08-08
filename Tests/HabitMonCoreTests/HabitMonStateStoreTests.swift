import XCTest
@testable import HabitMonCore

final class HabitMonStateStoreTests: XCTestCase {
    private var tempFileURL: URL!

    override func setUp() {
        super.setUp()
        tempFileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("HabitMonStateStoreTests-\(UUID().uuidString)")
            .appendingPathComponent("state.json")
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: tempFileURL.deletingLastPathComponent())
        super.tearDown()
    }

    func testLoadReturnsEmptyWhenFileDoesNotExist() {
        let store = HabitMonStateStore(fileURL: tempFileURL)
        XCTAssertEqual(store.load(), .empty)
    }

    func testSaveThenLoadRoundTrips() {
        let store = HabitMonStateStore(fileURL: tempFileURL)
        var state = HabitMonState.empty
        state.addXP(30, to: .nature)
        state.creditedTaskIDs.insert(UUID())
        store.save(state)

        let loaded = store.load()
        XCTAssertEqual(loaded, state)
    }

    func testSaveCreatesIntermediateDirectories() {
        let store = HabitMonStateStore(fileURL: tempFileURL)
        XCTAssertFalse(FileManager.default.fileExists(atPath: tempFileURL.deletingLastPathComponent().path))
        store.save(.empty)
        XCTAssertTrue(FileManager.default.fileExists(atPath: tempFileURL.path))
    }

    func testLoadReturnsEmptyOnCorruptedFile() throws {
        try FileManager.default.createDirectory(at: tempFileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        try "not valid json".data(using: .utf8)!.write(to: tempFileURL)
        let store = HabitMonStateStore(fileURL: tempFileURL)
        XCTAssertEqual(store.load(), .empty)
    }
}
