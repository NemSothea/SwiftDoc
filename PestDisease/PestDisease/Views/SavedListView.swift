//
//  SavedListView.swift
//  PestDisease
//

import SwiftUI
import CoreData

struct SavedListView: View {
    @Environment(\.managedObjectContext) private var context
    @EnvironmentObject private var catalog: GuideCatalog
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \SavedProblem.savedAt, ascending: false)],
        animation: .default
    )
    private var saved: FetchedResults<SavedProblem>

    var body: some View {
        Group {
            if saved.isEmpty {
                ContentUnavailableView(
                    "Nothing saved",
                    systemImage: "bookmark",
                    description: Text("Open a pest or disease and tap the bookmark to save it here.")
                )
            } else {
                List {
                    ForEach(saved, id: \.objectID) { item in
                        if let problemId = item.problemID {
                            if let problem = catalog.problem(id: problemId) {
                                NavigationLink(value: problem) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(problem.name)
                                            .font(.headline)
                                        if let date = item.savedAt {
                                            Text(date.formatted(date: .abbreviated, time: .omitted))
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                }
                            } else {
                                Text("Missing: \(problemId)")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Saved")
        .navigationDestination(for: GuideProblem.self) { problem in
            ProblemDetailView(problem: problem, cropID: problem.cropIds.first)
        }
    }
}
