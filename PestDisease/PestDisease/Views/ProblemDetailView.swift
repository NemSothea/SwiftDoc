//
//  ProblemDetailView.swift
//  PestDisease
//

import SwiftUI
import CoreData

struct ProblemDetailView: View {
    let problem: GuideProblem
    let cropID: String?

    @Environment(\.managedObjectContext) private var context
    @State private var isFavorite = false
    @State private var noteText = ""
    @State private var noteSnapshot = ""
    @State private var showDisclaimer = false

    var body: some View {
        List {
            Section {
                Text(problem.summary)
                    .font(.body)
            } header: {
                Text("Overview")
            }

            if !problem.symptoms.isEmpty {
                Section("Symptoms") {
                    ForEach(Array(problem.symptoms.enumerated()), id: \.offset) { _, line in
                        Text(line)
                            .font(.body)
                    }
                }
            }

            Section("Causes") {
                Text(problem.causes)
            }

            if !problem.remedies.isEmpty {
                Section("Remedies") {
                    ForEach(problem.remedies, id: \.self) { line in
                        Text("• \(line)")
                    }
                }
            }

            if !problem.prevention.isEmpty {
                Section("Prevention") {
                    ForEach(problem.prevention, id: \.self) { line in
                        Text("• \(line)")
                    }
                }
            }

            Section("Your note") {
                TextField("Add a short field note…", text: $noteText, axis: .vertical)
                    .lineLimit(3...8)
            }

            Section {
                Button("About remedies & safety") {
                    showDisclaimer = true
                }
                .font(.footnote)
            }
        }
        .navigationTitle(problem.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    toggleFavorite()
                } label: {
                    Image(systemName: isFavorite ? "bookmark.fill" : "bookmark")
                }
                .accessibilityLabel(isFavorite ? "Remove from saved" : "Save")
            }
        }
        .onAppear {
            refreshFromStore()
        }
        .onDisappear {
            persistNoteIfNeeded()
        }
        .alert("General information", isPresented: $showDisclaimer) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(
                "Remedies are general guidance. Always follow local regulations, " +
                "product labels, and advice from agricultural extension services."
            )
        }
    }

    private func refreshFromStore() {
        isFavorite = UserDataActions.isFavorite(problemID: problem.id, context: context)
        let loaded = UserDataActions.noteBody(problemID: problem.id, context: context) ?? ""
        noteText = loaded
        noteSnapshot = loaded
    }

    private func toggleFavorite() {
        do {
            try UserDataActions.toggleFavorite(
                problemID: problem.id,
                cropID: cropID,
                context: context
            )
            refreshFromStore()
        } catch {}
    }

    private func persistNoteIfNeeded() {
        guard noteText != noteSnapshot else { return }
        do {
            try UserDataActions.saveNote(problemID: problem.id, body: noteText, context: context)
        } catch {}
    }
}
