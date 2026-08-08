/// Each stat has 3 stages (0, 1, 2), gated by XP thresholds. These are a v1 starting
/// guess (per the design doc) — tune freely once the pacing can actually be felt in play.
public enum Evolution {
    public static let stage1Threshold = 50
    public static let stage2Threshold = 150

    /// Returns the current stage (0, 1, or 2) for a given XP total.
    public static func stage(forXP xp: Int) -> Int {
        if xp >= stage2Threshold { return 2 }
        if xp >= stage1Threshold { return 1 }
        return 0
    }
}
