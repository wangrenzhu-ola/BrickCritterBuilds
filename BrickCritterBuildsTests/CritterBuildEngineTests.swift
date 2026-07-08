import XCTest
@testable import BrickCritterBuilds

final class CritterBuildEngineTests: XCTestCase {
    func testInterveneCueForUnstableBuild() {
        var draft = CritterBuildDraft.blank
        draft.title = "Wobbly dragon"
        draft.oddPieces = 9
        let result = CritterBuildEngine.evaluate(draft, previous: nil)
        XCTAssertEqual(result.cue, .intervene)
        XCTAssertTrue(result.reason.contains("outside"))
    }

    func testNotBuiltStaysWatchAndManual() {
        var draft = CritterBuildDraft.blank
        draft.readingMode = .notTested
        let result = CritterBuildEngine.evaluate(draft, previous: nil)
        XCTAssertEqual(result.cue, .watch)
        XCTAssertTrue(result.reason.contains("No build test"))
    }

    func testDraftCarriesPMBrickTagAndBuildCardFields() throws {
        let draft = CritterBuildDraft.blank
        XCTAssertTrue(draft.colorTags.contains("green"))
        XCTAssertTrue(draft.sizeTags.contains("1x2"))
        XCTAssertTrue(draft.shapeTags.contains("tail"))
        XCTAssertFalse(draft.headIdea.isEmpty)
        XCTAssertFalse(draft.bodyIdea.isEmpty)
        XCTAssertFalse(draft.tailIdea.isEmpty)
        XCTAssertFalse(draft.feetIdea.isEmpty)
        _ = try JSONEncoder.brickCritter.encode(draft)
    }
}
