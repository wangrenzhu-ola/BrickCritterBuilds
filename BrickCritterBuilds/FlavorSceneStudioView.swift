import SwiftUI

struct CritterBuildStudioView: View {
    @EnvironmentObject private var store: CritterBuildStore
    @Binding var path: [AppRoute]
    @State private var draft: CritterBuildDraft
    @State private var showSuggestionSheet = false
    @State private var localError: String?
    @State private var savedRecordID: UUID?

    init(path: Binding<[AppRoute]>, initialDraft: CritterBuildDraft) {
        _path = path
        _draft = State(initialValue: initialDraft)
    }

    var body: some View {
        Form {
            if let localError {
                Section { ErrorBanner(message: localError, retry: save) }
            }
            Section("Critter Build identity") {
                TextField("Critter Build name", text: $draft.title)
                    .textInputAutocapitalization(.words)
                    .accessibilityLabel("Critter Build name")
                Picker("Flavor scene style", selection: $draft.critterStyle) {
                    ForEach(CritterStyle.allCases) { Text($0.rawValue).tag($0) }
                }
                CritterBuildGlass(stage: draft.critterStyle, cue: previewCue)
                    .frame(height: 150)
                    .accessibilityLabel("Miniature critter build preview")
            }
            Section("Flavor cue") {
                Picker("Tasting mode", selection: $draft.readingMode) {
                    ForEach(ReadingMode.allCases) { Text($0.rawValue).tag($0) }
                }.pickerStyle(.segmented)
                if draft.readingMode == .tested {
                    Stepper("Small bricks: \(draft.smallBricks, specifier: "%.0f")", value: $draft.smallBricks, in: 0...10, step: 1)
                    Stepper("Hinge pieces: \(draft.hingePieces, specifier: "%.0f")", value: $draft.hingePieces, in: 0...10, step: 1)
                    Stepper("Odd pieces: \(draft.oddPieces, specifier: "%.0f")", value: $draft.oddPieces, in: 0...10, step: 1)
                } else {
                    Text("Manual not-tasted state keeps the Critter Build usable and reminds you to retaste before serving.")
                }
            }
            Section("Living-scene observation") {
                Picker("Observation", selection: $draft.observation) {
                    ForEach(ObservationType.allCases) { Text($0.rawValue).tag($0) }
                }
                TextEditor(text: $draft.careNote)
                    .frame(minHeight: 96)
                    .accessibilityLabel("Critter Build note")
                Button("Optional editable note cleanup") { showSuggestionSheet = true }
                    .accessibilityLabel("Open optional AI/manual fallback suggestion")
            }
            Section("Cue preview") {
                let preview = CritterBuildEngine.evaluate(draft, previous: store.records.first)
                CuePill(cue: preview.cue, reason: preview.reason)
                Text(preview.comparison).font(.footnote).foregroundStyle(.secondary)
            }
            Section {
                Button("Save this Critter Build.", action: save)
                    .buttonStyle(.borderedProminent)
                    .accessibilityLabel("Save this Critter Build")
                Button("Simulate save failure for recovery") { store.simulateNextSaveFailure = true; save() }
                    .accessibilityLabel("Simulate Critter Build save failure")
            }
        }
        .navigationTitle(draft.id == nil ? "Critter Build Studio" : "Review your Critter Build changes.")
        .sheet(isPresented: $showSuggestionSheet) { SuggestionSheet(draft: $draft) }
        .onDisappear { store.draft = draft }
    }

    private var previewCue: BuildCue { CritterBuildEngine.evaluate(draft, previous: store.records.first).cue }

    private func save() {
        do {
            let record = try store.save(draft)
            savedRecordID = record.id
            localError = nil
            path.append(.detail(record.id))
        } catch {
            localError = error.localizedDescription
        }
    }
}

private struct SuggestionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var draft: CritterBuildDraft

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 18) {
                Text("AI unavailable or declined? Manual flow still works.").font(.title2.bold())
                Text("This local suggestion is editable and skipped unless you tap Apply. No factory Kimi key, secret, or autonomous save is used.")
                Text(CritterBuildEngine.aiFallbackNote(for: draft)).padding().background(Color(hex: "EAF7F3"), in: RoundedRectangle(cornerRadius: 18))
                Spacer()
                Button("Apply editable note") { draft.careNote = CritterBuildEngine.aiFallbackNote(for: draft); dismiss() }
                    .buttonStyle(.borderedProminent)
                Button("Keep manual note") { dismiss() }
            }
            .padding()
            .navigationTitle("Manual fallback")
        }
    }
}
