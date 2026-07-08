import AppIntents
import Foundation

struct DraftCritterBuildIntent: AppIntent {
    static var title: LocalizedStringResource = "Draft Critter Build"
    static var description = IntentDescription("Creates an editable BrickCritter Critter Build draft title and opens the app. It never saves autonomously.")
    static var openAppWhenRun: Bool = true

    @Parameter(title: "Critter Build Title") var title: String

    init() { self.title = "" }
    init(title: String) { self.title = title }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        UserDefaults.standard.set(title, forKey: "pendingCritterBuildTitle")
        return .result(dialog: "Editable Critter Build draft ready. Review it before saving.")
    }
}

struct BrickCritterShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(intent: DraftCritterBuildIntent(), phrases: ["Draft a \(.applicationName) critter build"], shortTitle: "Draft Critter Build", systemImageName: "pawprint")
    }
}
