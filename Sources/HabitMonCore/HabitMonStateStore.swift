import Foundation

/// Reads and writes `HabitMonState` to a JSON file on disk. Every `save(_:)` call writes
/// the FULL current state immediately — there is no batching, no history, and no separate
/// "dirty" tracking. If the file is missing (first run) or fails to decode (corrupted),
/// `load()` returns `.empty` rather than crashing; a decode failure is logged so it isn't
/// silently invisible, mirroring the same load-failure convention boring.notch's own
/// `ChecklistManager` uses.
public final class HabitMonStateStore {
    private let fileURL: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    public init(fileURL: URL) {
        self.fileURL = fileURL
        self.encoder = JSONEncoder()
        self.decoder = JSONDecoder()
    }

    public func load() -> HabitMonState {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return .empty
        }
        do {
            let data = try Data(contentsOf: fileURL)
            return try decoder.decode(HabitMonState.self, from: data)
        } catch {
            print("HabitMonStateStore: failed to load state at \(fileURL.path): \(error.localizedDescription) — starting fresh")
            return .empty
        }
    }

    public func save(_ state: HabitMonState) {
        do {
            try FileManager.default.createDirectory(
                at: fileURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            let data = try encoder.encode(state)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("HabitMonStateStore: failed to save state to \(fileURL.path): \(error.localizedDescription)")
        }
    }
}
