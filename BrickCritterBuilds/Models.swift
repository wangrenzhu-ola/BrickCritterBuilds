import Foundation
import SwiftUI

struct CritterBuildRecord: Identifiable, Codable, Hashable {
    var id: UUID
    var title: String
    var critterStyle: CritterStyle
    var readingMode: ReadingMode
    var smallBricks: Double
    var hingePieces: Double
    var oddPieces: Double
    var observation: ObservationType
    var colorTags: String
    var sizeTags: String
    var shapeTags: String
    var headIdea: String
    var bodyIdea: String
    var tailIdea: String
    var feetIdea: String
    var careNote: String
    var cue: BuildCue
    var cueReason: String
    var buildCueHex: String
    var createdAt: Date
    var updatedAt: Date
}

enum CritterStyle: String, CaseIterable, Codable, Identifiable, Hashable {
    case tinyDragon = "Tiny dragon"
    case perchedOwl = "Perched owl"
    case pocketTurtle = "Pocket turtle"
    case longTailFox = "Long-tail fox"

    var id: String { rawValue }
    var accentHex: String {
        switch self {
        case .tinyDragon: return "E9A43A"
        case .perchedOwl: return "B86B4B"
        case .pocketTurtle: return "5F9F79"
        case .longTailFox: return "48607A"
        }
    }
}

enum ReadingMode: String, CaseIterable, Codable, Identifiable, Hashable {
    case tested = "Picked pieces"
    case notTested = "Not counted"
    var id: String { rawValue }
}

enum ObservationType: String, CaseIterable, Codable, Identifiable, Hashable {
    case standsUpright = "Stands upright"
    case needsWiderFeet = "Needs wider feet"
    case headFallsForward = "Head falls forward"
    case tailMissing = "Tail missing"
    case needsCharacter = "Needs character"
    var id: String { rawValue }
}


enum BuildCue: String, CaseIterable, Codable, Identifiable, Hashable {
    case stable = "Buildable"
    case watch = "Tweak"
    case intervene = "Rebuild"

    var id: String { rawValue }
    var color: Color {
        switch self {
        case .stable: return Color(hex: "2FA872")
        case .watch: return Color(hex: "D9911A")
        case .intervene: return Color(hex: "D9534F")
        }
    }
}

struct CritterBuildDraft: Codable, Hashable {
    var id: UUID?
    var title: String
    var critterStyle: CritterStyle
    var readingMode: ReadingMode
    var smallBricks: Double
    var hingePieces: Double
    var oddPieces: Double
    var observation: ObservationType
    var colorTags: String
    var sizeTags: String
    var shapeTags: String
    var headIdea: String
    var bodyIdea: String
    var tailIdea: String
    var feetIdea: String
    var careNote: String
    var lastGeneratedCue: BuildCue?
    var lastGeneratedReason: String?

    static let blank = CritterBuildDraft(
        id: nil,
        title: "",
        critterStyle: .tinyDragon,
        readingMode: .tested,
        smallBricks: 5.0,
        hingePieces: 4.0,
        oddPieces: 2.0,
        observation: .standsUpright,
        colorTags: "green, amber, white",
        sizeTags: "1x1, 1x2, 2x2, slope, hinge",
        shapeTags: "round eyes, wedge back, clip tail",
        headIdea: "Round eye bricks and a wedge snout",
        bodyIdea: "2x2 core with slope shoulders",
        tailIdea: "Clip tail or hinge tail for character",
        feetIdea: "Four 1x2 plates widened under the body",
        careNote: "",
        lastGeneratedCue: nil,
        lastGeneratedReason: nil
    )

    init(record: CritterBuildRecord) {
        id = record.id
        title = record.title
        critterStyle = record.critterStyle
        readingMode = record.readingMode
        smallBricks = record.smallBricks
        hingePieces = record.hingePieces
        oddPieces = record.oddPieces
        observation = record.observation
        colorTags = record.colorTags
        sizeTags = record.sizeTags
        shapeTags = record.shapeTags
        headIdea = record.headIdea
        bodyIdea = record.bodyIdea
        tailIdea = record.tailIdea
        feetIdea = record.feetIdea
        careNote = record.careNote
        lastGeneratedCue = record.cue
        lastGeneratedReason = record.cueReason
    }

    init(id: UUID?, title: String, critterStyle: CritterStyle, readingMode: ReadingMode, smallBricks: Double, hingePieces: Double, oddPieces: Double, observation: ObservationType, colorTags: String, sizeTags: String, shapeTags: String, headIdea: String, bodyIdea: String, tailIdea: String, feetIdea: String, careNote: String, lastGeneratedCue: BuildCue?, lastGeneratedReason: String?) {
        self.id = id
        self.title = title
        self.critterStyle = critterStyle
        self.readingMode = readingMode
        self.smallBricks = smallBricks
        self.hingePieces = hingePieces
        self.oddPieces = oddPieces
        self.observation = observation
        self.colorTags = colorTags
        self.sizeTags = sizeTags
        self.shapeTags = shapeTags
        self.headIdea = headIdea
        self.bodyIdea = bodyIdea
        self.tailIdea = tailIdea
        self.feetIdea = feetIdea
        self.careNote = careNote
        self.lastGeneratedCue = lastGeneratedCue
        self.lastGeneratedReason = lastGeneratedReason
    }

    var trimmedTitle: String { title.trimmingCharacters(in: .whitespacesAndNewlines) }
}

enum CritterBuildSaveError: LocalizedError, Equatable {
    case emptyTitle
    case simulatedFailure
    case storageFailure(String)

    var errorDescription: String? {
        switch self {
        case .emptyTitle:
            return "Name this Critter Build before saving."
        case .simulatedFailure:
            return "Couldn’t save this Critter Build. Try again."
        case .storageFailure(let message):
            return "Couldn’t save this Critter Build: \(message)"
        }
    }
}

enum AppRoute: Hashable {
    case studio(CritterBuildDraft)
    case detail(UUID)
    case paywall
    case privacy
}

extension Color {
    init(hex: String) {
        let clean = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: clean).scanHexInt64(&value)
        let r = Double((value >> 16) & 0xFF) / 255.0
        let g = Double((value >> 8) & 0xFF) / 255.0
        let b = Double(value & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}
