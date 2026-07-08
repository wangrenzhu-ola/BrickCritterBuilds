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
}
