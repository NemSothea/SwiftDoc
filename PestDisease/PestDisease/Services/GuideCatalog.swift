//
//  GuideCatalog.swift
//  PestDisease
//

import Combine
import Foundation

@MainActor
final class GuideCatalog: ObservableObject {
    static let shared = GuideCatalog()

    private(set) var crops: [GuideCrop] = []
    private(set) var problemsById: [String: GuideProblem] = [:]
    private var problemsByCropId: [String: [GuideProblem]] = [:]

    private init() {
        reloadFromBundle()
    }

    func reloadFromBundle() {
        guard let url = Bundle.main.url(forResource: "guide", withExtension: "json") else {
            crops = []
            problemsById = [:]
            problemsByCropId = [:]
            return
        }
        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode(GuideBundle.self, from: data)
            crops = decoded.crops.sorted { $0.sortOrder < $1.sortOrder }
            var byId: [String: GuideProblem] = [:]
            var byCrop: [String: [GuideProblem]] = [:]
            for problem in decoded.problems {
                byId[problem.id] = problem
                for cropId in problem.cropIds {
                    byCrop[cropId, default: []].append(problem)
                }
            }
            for key in byCrop.keys {
                byCrop[key]?.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
            }
            problemsById = byId
            problemsByCropId = byCrop
        } catch {
            crops = []
            problemsById = [:]
            problemsByCropId = [:]
        }
    }

    func problems(forCropId cropId: String) -> [GuideProblem] {
        problemsByCropId[cropId] ?? []
    }

    func problem(id: String) -> GuideProblem? {
        problemsById[id]
    }

    func search(query: String) -> [GuideProblem] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }
        let q = trimmed.lowercased()
        return problemsById.values.filter { problem in
            if problem.name.lowercased().contains(q) { return true }
            if problem.summary.lowercased().contains(q) { return true }
            return problem.symptoms.contains { $0.lowercased().contains(q) }
        }
        .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }
}
