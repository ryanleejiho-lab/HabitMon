import Foundation

/// Mirrors the subset of boring.notch's persisted Checklist item fields that HabitMon
/// actually needs. Deliberately minimal: fields present in the real source JSON but not
/// declared here (text, createdAt) are silently ignored by Codable's default behavior.
///
/// Decoding is defensive on `type`: a missing key OR an unrecognized raw value both decode
/// to `nil` (untagged) rather than throwing, so a future new HabitType added to boring.notch
/// before HabitMon is updated to match can't break decoding of the whole checklist file.
public struct ChecklistSourceItem: Equatable, Sendable {
    public let id: UUID
    public let isDone: Bool
    public let type: HabitType?

    public init(id: UUID, isDone: Bool, type: HabitType?) {
        self.id = id
        self.isDone = isDone
        self.type = type
    }
}

extension ChecklistSourceItem: Decodable {
    private enum CodingKeys: String, CodingKey {
        case id, isDone, type
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        isDone = try container.decode(Bool.self, forKey: .isDone)
        type = (try? container.decodeIfPresent(HabitType.self, forKey: .type)) ?? nil
    }
}

/// The top-level shape of boring.notch's `state.json`. Only `items` is needed —
/// `lastSeenDate` (used for boring.notch's own daily-rollover logic) is irrelevant here
/// and, like every other undeclared field, is ignored automatically by Codable.
public struct ChecklistSourceFile: Decodable, Sendable {
    public let items: [ChecklistSourceItem]
}
