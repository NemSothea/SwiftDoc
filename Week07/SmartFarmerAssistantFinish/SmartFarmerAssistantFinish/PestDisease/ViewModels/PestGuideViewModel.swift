//
//  PestGuideViewModel.swift
//  SmartFarmerAssistantFinish
//
//  Created by sothea007 on 17/3/26.
//

import Foundation
import SwiftUI

/// Owns the search-bar text and filters a list of `Pest` against it.
/// Kept intentionally small — CRUD is not needed in a read-only reference
/// library. `@FetchRequest` in the view supplies the raw list.
class PestGuideViewModel: ObservableObject {

    @Published var searchText: String = ""

    /// Filter a pest list by the current `searchText`.
    /// Matches against name, symptoms, and treatment (case-insensitive).
    func filter(_ pests: [Pest]) -> [Pest] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return pests }
        return pests.filter { pest in
            contains(pest.name, query) ||
            contains(pest.symptoms, query) ||
            contains(pest.treatment, query) ||
            contains(pest.pestType, query)
        }
    }

    private func contains(_ haystack: String?, _ needle: String) -> Bool {
        guard let haystack, !haystack.isEmpty else { return false }
        return haystack.localizedCaseInsensitiveContains(needle)
    }
}
