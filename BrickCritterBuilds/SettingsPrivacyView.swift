import SwiftUI

struct SettingsPrivacyView: View {
    @EnvironmentObject private var store: CritterBuildStore
    @EnvironmentObject private var premium: PremiumStore

    var body: some View {
        Form {
            Section("Privacy") {
                Toggle("Allow optional AI routing after review", isOn: $store.privacyChoice.optionalAIRoutingAllowed)
                Toggle("Show labeled local starter examples", isOn: $store.privacyChoice.seedExamplesVisible)
                Toggle("Allow local export previews", isOn: $store.privacyChoice.localExportAllowed)
                NavigationLink("Read Privacy / AI boundary") { PrivacyBoundaryView() }
            }
            Section("Premium boundary") {
                LabeledContent("Premium unlocked", value: premium.isPremiumUnlocked ? "Yes" : "No")
                Text("The first Critter Build loop is never paywalled. Premium only adds local critter packs, extra shelf slots, export, and themes.")
            }
            Section("Data controls") {
                Text("Critter Builds, drafts, privacy choices, and entitlement flags are stored on this device. Delete controls are available on each Critter Build detail.")
            }
        }
        .navigationTitle("Settings")
    }
}

struct PrivacyBoundaryView: View {
    var body: some View {
        List {
            Section("Local-first storage") {
                Text("Critter Builds, readings, observations, drafts, premium state, and privacy choices stay on device unless you export them.")
            }
            Section("Optional AI boundary") {
                Text("Manual rules fully deliver v0. Optional note cleanup is Kimi-ready for a future user-supplied route, but this app contains no API keys and never saves AI text automatically.")
            }
            Section("Review notes") {
                Text("BrickCritter does not claim LEGO affiliation, live brick recognition, a public community feed, or automatic build guarantees.")
            }
        }
        .navigationTitle("Privacy / AI")
    }
}
