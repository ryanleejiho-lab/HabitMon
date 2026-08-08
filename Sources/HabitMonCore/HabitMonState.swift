import Foundation

/// HabitMon's own persisted progress: current XP per stat, and the set of boring.notch
/// checklist item IDs already credited (so a completed task is never double-counted).
///
/// No history is kept — current stage per stat is always derived from current XP via
/// `Evolution.stage(forXP:)` at render time, never stored separately.
///
/// `statXP` is keyed by `HabitType.rawValue` (a plain String) rather than `HabitType`
/// itself, so it encodes as a normal `{"fire": 10, ...}` JSON object — matching the design
/// doc's documented file shape — rather than Swift's array-of-pairs fallback encoding for
/// dictionaries with non-String/Int keys.
public struct HabitMonState: Codable, Equatable, Sendable {
    public var statXP: [String: Int]
    public var creditedTaskIDs: Set<UUID>

    public init(statXP: [String: Int] = [:], creditedTaskIDs: Set<UUID> = []) {
        self.statXP = statXP
        self.creditedTaskIDs = creditedTaskIDs
    }

    public static let empty = HabitMonState()

    public func xp(for type: HabitType) -> Int {
        statXP[type.rawValue] ?? 0
    }

    public mutating func addXP(_ amount: Int, to type: HabitType) {
        statXP[type.rawValue, default: 0] += amount
    }
}
