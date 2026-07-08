import Foundation

struct CritterBuildEngine {
    static func evaluate(_ draft: CritterBuildDraft, previous: CritterBuildRecord?) -> (cue: BuildCue, reason: String, cueHex: String, comparison: String) {
        guard draft.readingMode == .tested else {
            return (.watch, "No build test was logged today, so keep the critter build visible and test the stance before saving.", "D9911A", comparisonCopy(newCue: .watch, previous: previous))
        }
        if draft.smallBricks >= 8 || draft.hingePieces <= 1 || draft.oddPieces >= 8 || draft.observation == .needsCharacter {
            return (.intervene, "The critter build is outside the stable stance band; adjust piece tags before saving.", "D9534F", comparisonCopy(newCue: .intervene, previous: previous))
        }
        if draft.smallBricks >= 7 || draft.observation == .needsWiderFeet || draft.observation == .headFallsForward || draft.observation == .tailMissing {
            return (.watch, "The critter can stand, but this build deserves a small stance or character adjustment before saving.", "D9911A", comparisonCopy(newCue: .watch, previous: previous))
        }
        return (.stable, "Piece tags and posture notes line up with a balanced critter build.", "2FA872", comparisonCopy(newCue: .stable, previous: previous))
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
