//
//  SearchView.swift
//  PestDisease
//

import SwiftUI

struct SearchView: View {
    @EnvironmentObject private var catalog: GuideCatalog
    @State private var query = ""

    private var results: [GuideProblem] {
        catalog.search(query: query)
    }

    var body: some View {
        List {
            if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                ContentUnavailableView(
                    "Search",
                    systemImage: "magnifyingglass",
                    description: Text("Enter a pest, disease, or symptom keyword.")
                )
                .listRowBackground(Color.clear)
            } else if results.isEmpty {
                ContentUnavailableView(
                    "No matches",
                    systemImage: "questionmark.circle",
                    description: Text("Try another word or browse by crop from Home.")
                )
                .listRowBackground(Color.clear)
            } else {
                ForEach(results) { problem in
                    NavigationLink(value: problem) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(problem.name)
                                .font(.headline)
                            Text(problem.summary)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                        }
                        .padding(.vertical, 2)
                    }
                }
            }
        }
        .navigationTitle("Search")
        .searchable(text: $query, prompt: "Name or symptom")
        .navigationDestination(for: GuideProblem.self) { problem in
            ProblemDetailView(problem: problem, cropID: problem.cropIds.first)
        }
    }
}
