import Foundation

/// Reads and writes `HabitMonState` to a JSON file on disk. Every `save(_:)` call writes
/// the FULL current state immediately — there is no batching, no history, and no separate
/// "dirty" tracking. If the file is missing (first run) or fails to decode (corrupted),
/// `load()` returns `.empty` rather than crashing; a decode failure is logged so it isn't
/// silently invisible, mirroring the same load-failure convention boring.notch's own
/// `ChecklistManager` uses. A corrupted file is renamed aside (best-effort) before returning
/// `.empty`, so a subsequent `save()` doesn't silently clobber the only trace of what broke.
///
/// `@MainActor`-bound, matching boring.notch's own `ChecklistManager` convention: this store
/// is only ever driven by `ChecklistPoller` (also `@MainActor`), so the single-writer
/// invariant is enforced by the compiler rather than merely assumed.
@MainActor
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
            print("HabitMonStateStore: failed to load state at \(fileURL.path): \(error.localizedDescription) — backing up and starting fresh")
            let backupURL = fileURL.deletingLastPathComponent()
                .appendingPathComponent("\(fileURL.lastPathComponent).corrupted-\(Int(Date().timeIntervalSince1970))")
            try? FileManager.default.moveItem(at: fileURL, to: backupURL)
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
