//
//  ProblemListView.swift
//  PestDisease
//

import SwiftUI

struct ProblemListView: View {
    let crop: GuideCrop
    @EnvironmentObject private var catalog: GuideCatalog

    private var problems: [GuideProblem] {
        catalog.problems(forCropId: crop.id)
    }

    var body: some View {
        Group {
            if problems.isEmpty {
                ContentUnavailableView(
                    "No entries",
                    systemImage: "doc.text",
                    description: Text("No pests or diseases listed for this crop yet.")
                )
            } else {
                List(problems) { problem in
                    NavigationLink(value: problem) {
                        ProblemRowView(problem: problem)
                    }
                }
            }
        }
        .navigationTitle(crop.name)
        .navigationDestination(for: GuideProblem.self) { problem in
            ProblemDetailView(problem: problem, cropID: crop.id)
        }
    }
}

private struct ProblemRowView: View {
    let problem: GuideProblem

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(problem.name)
                .font(.headline)
            Text(kindLabel)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }

    private var kindLabel: String {
        switch problem.kind {
        case .pest: return "Pest"
        case .disease: return "Disease"
        }
    }
}
