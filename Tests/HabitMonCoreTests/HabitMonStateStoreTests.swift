import XCTest
@testable import HabitMonCore

@MainActor
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

    func testLoadBacksUpCorruptedFileInsteadOfLeavingItToBeClobbered() throws {
        let directory = tempFileURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try "not valid json".data(using: .utf8)!.write(to: tempFileURL)
        let store = HabitMonStateStore(fileURL: tempFileURL)

        _ = store.load()

        // The corrupted content must no longer sit at the original path...
        if FileManager.default.fileExists(atPath: tempFileURL.path) {
            let remaining = try String(contentsOf: tempFileURL, encoding: .utf8)
            XCTAssertNotEqual(remaining, "not valid json", "corrupted content should have been moved aside, not left in place")
        }

        // ...and a backup file matching the `.corrupted-<timestamp>` pattern must exist alongside it.
        let siblingNames = try FileManager.default.contentsOfDirectory(atPath: directory.path)
        let backupName = siblingNames.first { $0.hasPrefix("\(tempFileURL.lastPathComponent).corrupted-") }
        XCTAssertNotNil(backupName, "expected a backup file matching '\(tempFileURL.lastPathComponent).corrupted-<timestamp>' in \(directory.path), found: \(siblingNames)")

        if let backupName {
            let backupContent = try String(contentsOf: directory.appendingPathComponent(backupName), encoding: .utf8)
            XCTAssertEqual(backupContent, "not valid json")
        }
    }
}
