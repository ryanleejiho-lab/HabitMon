import Foundation
import HabitMonCore

/// Polls boring.notch's checklist file every 3 seconds, credits any newly-completed
/// tagged tasks via `ChecklistCreditor`, and immediately persists the result if it changed.
/// If boring.notch's file is missing or unreadable, this silently does nothing and retries
/// on the next tick rather than crashing.
@MainActor
final class ChecklistPoller: ObservableObject {
    /// One poller for the whole app's lifetime — started once at launch (`HabitMonApp.init`)
    /// and kept alive regardless of whether any window is open, so progress tracking
    /// continues in the background (menu-bar-only) the same way boring.notch itself does.
    static let shared = ChecklistPoller()

    @Published private(set) var state: HabitMonState

    private let store: HabitMonStateStore
    private let sourceFileURL: URL
    private var timer: Timer?
    private let decoder = JSONDecoder()

    init(
        sourceFileURL: URL = Paths.boringNotchChecklistFile,
        stateFileURL: URL = Paths.habitMonStateFile
    ) {
        self.sourceFileURL = sourceFileURL
        self.store = HabitMonStateStore(fileURL: stateFileURL)
        self.state = store.load()
    }

    func start() {
        guard timer == nil else { return } // idempotent — safe to call more than once
        pollOnce()
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.pollOnce() }
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    /// Exposed (not private) so it can be triggered manually during development/verification
    /// without waiting up to 3 seconds for the timer to fire.
    func pollOnce() {
        guard let data = try? Data(contentsOf: sourceFileURL) else { return }
        guard let sourceFile = try? decoder.decode(ChecklistSourceFile.self, from: data) else { return }

        let newState = ChecklistCreditor.apply(sourceItems: sourceFile.items, to: state)
        guard newState != state else { return }

        state = newState
        store.save(newState)
    }
}
