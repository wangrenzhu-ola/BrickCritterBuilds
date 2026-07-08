import Foundation
import Combine

@MainActor
final class CritterBuildStore: ObservableObject {
    @Published private(set) var records: [CritterBuildRecord] = []
    @Published var draft: CritterBuildDraft = .blank { didSet { persistDraft() } }
    @Published var privacyChoice = PrivacyChoice() { didSet { persistPrivacy() } }
    @Published var lastErrorMessage: String?
    @Published var lastSuccessMessage: String?
    @Published var simulateNextSaveFailure = false

    private let recordsURL: URL
    private let draftKey = "BrickCritterBuilds.draft"
    private let privacyKey = "BrickCritterBuilds.privacy"

    init(fileManager: FileManager = .default) {
        let docs = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first ?? URL(fileURLWithPath: NSTemporaryDirectory())
        recordsURL = docs.appendingPathComponent("brickcritter-care-scenes.json")
        load()
    }

    var latestComparison: String {
        guard let newest = records.first else { return "No saved comparison yet. Save the first Critter Build to start a local history." }
        return CritterBuildEngine.comparisonCopy(newCue: newest.cue, previous: records.dropFirst().first)
    }

    func startNewDraft() { draft = .blank }

    func applyOptionalSuggestion() {
        draft.careNote = CritterBuildEngine.aiFallbackNote(for: draft)
    }

    @discardableResult
    func save(_ incoming: CritterBuildDraft) throws -> CritterBuildRecord {
        guard !incoming.trimmedTitle.isEmpty else { throw CritterBuildSaveError.emptyTitle }
        if simulateNextSaveFailure {
            simulateNextSaveFailure = false
            lastErrorMessage = CritterBuildSaveError.simulatedFailure.localizedDescription
            throw CritterBuildSaveError.simulatedFailure
        }
        let previous = records.first(where: { $0.id != incoming.id })
        let evaluation = CritterBuildEngine.evaluate(incoming, previous: previous)
        let now = Date()
        let record = CritterBuildRecord(
            id: incoming.id ?? UUID(),
            title: incoming.trimmedTitle,
            critterStyle: incoming.critterStyle,
            readingMode: incoming.readingMode,
            smallBricks: incoming.smallBricks,
            hingePieces: incoming.hingePieces,
            oddPieces: incoming.oddPieces,
            observation: incoming.observation,
            colorTags: incoming.colorTags,
            sizeTags: incoming.sizeTags,
            shapeTags: incoming.shapeTags,
            headIdea: incoming.headIdea,
            bodyIdea: incoming.bodyIdea,
            tailIdea: incoming.tailIdea,
            feetIdea: incoming.feetIdea,
            careNote: incoming.careNote,
            cue: evaluation.cue,
            cueReason: evaluation.reason,
            buildCueHex: evaluation.cueHex,
            createdAt: records.first(where: { $0.id == incoming.id })?.createdAt ?? now,
            updatedAt: now
        )
        if let index = records.firstIndex(where: { $0.id == record.id }) { records[index] = record } else { records.insert(record, at: 0) }
        records.sort { $0.updatedAt > $1.updatedAt }
        draft = CritterBuildDraft(record: record)
        do { try persistRecords() } catch { throw CritterBuildSaveError.storageFailure(error.localizedDescription) }
        lastErrorMessage = nil
        lastSuccessMessage = "Critter Build saved."
        return record
    }

    func delete(_ record: CritterBuildRecord) {
        records.removeAll { $0.id == record.id }
        try? persistRecords()
    }

    func exportText(for record: CritterBuildRecord) -> String {
        """
        \(record.title) — \(record.cue.rawValue): \(record.cueReason)
        Color tags: \(record.colorTags)
        Size tags: \(record.sizeTags)
        Shape tags: \(record.shapeTags)
        Head/body/tail/feet: \(record.headIdea); \(record.bodyIdea); \(record.tailIdea); \(record.feetIdea)
        """
    }

    private func load() {
        if let data = try? Data(contentsOf: recordsURL), let decoded = try? JSONDecoder.brickCritter.decode([CritterBuildRecord].self, from: data) { records = decoded.sorted { $0.updatedAt > $1.updatedAt } }
        if let data = UserDefaults.standard.data(forKey: draftKey), let decoded = try? JSONDecoder.brickCritter.decode(CritterBuildDraft.self, from: data) { draft = decoded }
        if let data = UserDefaults.standard.data(forKey: privacyKey), let decoded = try? JSONDecoder.brickCritter.decode(PrivacyChoice.self, from: data) { privacyChoice = decoded }
        if let pending = UserDefaults.standard.string(forKey: "pendingCritterBuildTitle"), !pending.isEmpty {
            draft.title = pending
            UserDefaults.standard.removeObject(forKey: "pendingCritterBuildTitle")
        }
    }

    private func persistRecords() throws {
        let data = try JSONEncoder.brickCritter.encode(records)
        try data.write(to: recordsURL, options: [.atomic])
    }

    private func persistDraft() {
        if let data = try? JSONEncoder.brickCritter.encode(draft) { UserDefaults.standard.set(data, forKey: draftKey) }
    }

    private func persistPrivacy() {
        if let data = try? JSONEncoder.brickCritter.encode(privacyChoice) { UserDefaults.standard.set(data, forKey: privacyKey) }
    }
}

struct PrivacyChoice: Codable, Hashable {
    var optionalAIRoutingAllowed = false
    var seedExamplesVisible = true
    var localExportAllowed = true
}

extension JSONEncoder {
    static var brickCritter: JSONEncoder { let encoder = JSONEncoder(); encoder.dateEncodingStrategy = .iso8601; return encoder }
}

extension JSONDecoder {
    static var brickCritter: JSONDecoder { let decoder = JSONDecoder(); decoder.dateDecodingStrategy = .iso8601; return decoder }
}
