import Foundation

struct CritterBuildEngine {
    static func evaluate(_ draft: CritterBuildDraft, previous: CritterBuildRecord?) -> (cue: BuildCue, reason: String, flavorHex: String, comparison: String) {
        guard draft.readingMode == .tested else {
            return (.watch, "No tasting pass was logged today, so keep the critter build visible and retaste before serving.", "D9911A", comparisonCopy(newCue: .watch, previous: previous))
        }
        if draft.smallBricks >= 8 || draft.hingePieces <= 1 || draft.oddPieces >= 8 || draft.observation == .needsCharacter {
            return (.intervene, "One flavor balance is outside the hosting-safe band; adjust the next pour and avoid health claims.", "D9534F", comparisonCopy(newCue: .intervene, previous: previous))
        }
        if draft.smallBricks >= 7 || draft.observation == .needsWiderFeet || draft.observation == .headFallsForward || draft.observation == .tailMissing {
            return (.watch, "The drink is usable, but this note deserves a small adjustment before the next guest pour.", "D9911A", comparisonCopy(newCue: .watch, previous: previous))
        }
        return (.stable, "Build notes and guest reaction line up with a balanced zero-proof moment.", "2FA872", comparisonCopy(newCue: .stable, previous: previous))
    }

    static func comparisonCopy(newCue: BuildCue, previous: CritterBuildRecord?) -> String {
        guard let previous else { return "First saved Critter Build — the next one will compare cue changes here." }
        if previous.cue == newCue { return "Still \(newCue.rawValue): newest cue matches \(previous.title)." }
        return "Changed from \(previous.cue.rawValue) to \(newCue.rawValue) since \(previous.title)."
    }

    static func aiFallbackNote(for draft: CritterBuildDraft) -> String {
        "Manual cue: \(draft.observation.rawValue.lowercased()) in a \(draft.critterStyle.rawValue.lowercased()). Keep this note editable; no AI route or save happens without your confirmation."
    }
}
