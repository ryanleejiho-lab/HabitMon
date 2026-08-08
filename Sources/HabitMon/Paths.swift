import Foundation

enum Paths {
    /// boring.notch's real, live Checklist data — HabitMon only reads this, never writes it.
    static var boringNotchChecklistFile: URL {
        FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Application Support/boringNotch/Checklist/state.json")
    }

    /// HabitMon's own persisted progress.
    static var habitMonStateFile: URL {
        let support = (try? FileManager.default.url(
            for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true
        )) ?? FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Library/Application Support")
        return support
            .appendingPathComponent("HabitMon", isDirectory: true)
            .appendingPathComponent("state.json")
    }
}
