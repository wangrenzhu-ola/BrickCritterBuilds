import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: CritterBuildStore
    @EnvironmentObject private var premium: PremiumStore
    @Binding var path: [AppRoute]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                HeroCritterStyle(cue: store.records.first?.cue ?? .watch, title: "BrickCritter", subtitle: store.latestComparison)
                    .accessibilityLabel("Miniature critter build with build cue color and saved Critter Build comparison")

                if store.records.isEmpty {
                    EmptyCritterBuildView(create: startCritterBuild)
                } else {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent Critter Builds").font(.title2.bold())
                        ForEach(store.records) { record in
                            Button { path.append(.detail(record.id)) } label: { CritterBuildCard(record: record) }
                                .buttonStyle(.plain)
                                .accessibilityLabel("Open Critter Build \(record.title), cue \(record.cue.rawValue)")
                        }
                    }
                }

                PremiumPreviewCard(isUnlocked: premium.isPremiumUnlocked) { path.append(.paywall) }
                Button("Start your first Critter Build.", action: startCritterBuild)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .accessibilityLabel("Start your first Critter Build")
                Button("Privacy and AI boundary") { path.append(.privacy) }
                    .accessibilityLabel("Open Privacy and AI boundary sheet")
            }
            .padding()
        }
        .navigationTitle("Critter Builds")
        .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("New") { startCritterBuild() } } }
        .task { await premium.loadProducts() }
    }

    private func startCritterBuild() {
        store.startNewDraft()
        path.append(.studio(.blank))
    }
}

private struct EmptyCritterBuildView: View {
    let create: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Start your first Critter Build.").font(.title2.bold())
            Text("Select 5–8 color, size, and shape brick tags, then save a head/body/tail/feet build card. BrickCritter will render Buildable, Tweak, or Rebuild without making LEGO affiliation or live database claims.")
            MiniCueComparison(newText: "No saved cue yet", previousText: "Comparison appears after your first save")
            Button("Create Critter Build", action: create).buttonStyle(.borderedProminent)
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 24))
        .accessibilityElement(children: .combine)
    }
}
