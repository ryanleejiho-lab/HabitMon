import Foundation

/// The 5 habit categories a checklist task can be tagged with. Raw values are the shared
/// JSON contract with boring.notch's own `HabitType` enum (`ChecklistItem.type`) — they
/// MUST stay in sync, since HabitMon reads boring.notch's persisted checklist data directly.
public enum HabitType: String, Codable, CaseIterable, Identifiable, Equatable, Hashable, Sendable {
    case fire
    case wisdom
    case nature
    case water
    case storm

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .fire: return "Fire"
        case .wisdom: return "Wisdom"
        case .nature: return "Nature"
        case .water: return "Water"
        case .storm: return "Storm"
        }
    }
}
