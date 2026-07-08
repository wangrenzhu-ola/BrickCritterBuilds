import SwiftUI

struct CritterBuildDetailView: View {
    @EnvironmentObject private var store: CritterBuildStore
    @Binding var path: [AppRoute]
    let recordID: UUID
    @State private var showDeleteConfirm = false
    @State private var showExport = false

    var record: CritterBuildRecord? { store.records.first { $0.id == recordID } }

    var body: some View {
        ScrollView {
            if let record {
                VStack(alignment: .leading, spacing: 20) {
                    HeroCritterStyle(cue: record.cue, title: record.title, subtitle: record.cueReason)
                    CritterBuildCard(record: record)
                    MiniCueComparison(newText: "Newest: \(record.cue.rawValue)", previousText: CritterBuildEngine.comparisonCopy(newCue: record.cue, previous: store.records.dropFirst().first))
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Build note").font(.headline)
                        Text(record.careNote.isEmpty ? "No extra note saved." : record.careNote)
                    }
                    HStack {
                        Button("Edit") { path.append(.studio(CritterBuildDraft(record: record))) }
                        Button("Export") { showExport = true }
                        Button("Delete", role: .destructive) { showDeleteConfirm = true }
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
            } else {
                ContentUnavailableView("Critter Build unavailable", systemImage: "exclamationmark.triangle", description: Text("This Critter Build may have been deleted locally."))
            }
        }
        .navigationTitle("Critter Build Detail")
        .alert("Delete this Critter Build?", isPresented: $showDeleteConfirm, presenting: record) { record in
            Button("Delete", role: .destructive) { store.delete(record); path.removeAll() }
            Button("Cancel", role: .cancel) { }
        } message: { record in Text("Remove \(record.title) from local storage?") }
        .sheet(isPresented: $showExport) { if let record { ExportSheet(text: store.exportText(for: record)) } }
    }
}

private struct ExportSheet: View {
    @Environment(\.dismiss) private var dismiss
    let text: String
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Local export preview").font(.title2.bold())
                Text(text).padding().background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18))
                Text("Premium unlocks longer history export. This preview never uploads data.").font(.footnote).foregroundStyle(.secondary)
                Spacer()
            }
            .padding()
            .toolbar { Button("Done") { dismiss() } }
        }
    }
}
