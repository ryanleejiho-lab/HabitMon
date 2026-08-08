import Foundation

/// The core crediting algorithm: given the latest snapshot of boring.notch's checklist
/// items and HabitMon's current state, returns the updated state.
///
/// - Newly-completed (`isDone == true`), tagged (`type != nil`) items not yet in
///   `creditedTaskIDs` get `xpPerTask` XP awarded to their stat, and their ID is recorded.
/// - Any previously-credited ID no longer present in `sourceItems` AT ALL (regardless of
///   isDone) is pruned from `creditedTaskIDs` — once boring.notch's own daily rollover
///   deletes a checked-off item, that ID can never reappear in the source file, so nothing
///   is lost by dropping it, and this keeps HabitMon's state file from growing forever.
///
/// Callers must never invoke `apply` with a `sourceItems` snapshot that failed to load or
/// parse completely — an ID's mere absence is read as "permanently deleted" and will cause
/// re-crediting if that item reappears later. (Task 8's `ChecklistPoller` respects this by
/// skipping the call entirely on a failed read, rather than substituting an empty array.)
///
/// This is a pure function — no I/O. The caller (HabitMon's polling layer) is responsible
/// for persisting the result.
public enum ChecklistCreditor {
    public static func apply(
        sourceItems: [ChecklistSourceItem],
        to state: HabitMonState,
        xpPerTask: Int = 10
    ) -> HabitMonState {
        var newState = state

        for item in sourceItems where item.isDone {
            guard let type = item.type else { continue }
            guard !newState.creditedTaskIDs.contains(item.id) else { continue }
            newState.addXP(xpPerTask, to: type)
            newState.creditedTaskIDs.insert(item.id)
        }

        let sourceIDs = Set(sourceItems.map(\.id))
        newState.creditedTaskIDs = newState.creditedTaskIDs.intersection(sourceIDs)

        return newState
    }
}
