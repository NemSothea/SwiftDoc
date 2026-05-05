// Journal/ViewModels/JournalViewModel.swift
import Foundation
import Combine

class JournalViewModel: ObservableObject {

    @Published var searchText: String = ""
    @Published var weatherFilter: Weather? = nil

    /// Pure function — takes already-fetched entries and returns the subset
    /// that matches both the search text and the weather chip.
    /// Keep the view declarative: it only renders what this returns.
    func filter(_ entries: [JournalEntry]) -> [JournalEntry] {
        var result = entries

        if let weatherFilter {
            result = result.filter { $0.weatherTag == weatherFilter }
        }

        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !query.isEmpty {
            result = result.filter { entry in
                contains(entry.title, query) || contains(entry.content, query)
            }
        }

        return result
    }

    /// Group a list of entries by day — used to render section headers in the
    /// timeline. Returns `[(day, [entry])]` ordered newest day first.
    func groupByDay(_ entries: [JournalEntry]) -> [(Date, [JournalEntry])] {
        let calendar = Calendar.current
        let groups = Dictionary(grouping: entries) { entry -> Date in
            calendar.startOfDay(for: entry.date ?? Date.distantPast)
        }
        return groups
            .map { ($0.key, $0.value.sorted { ($0.date ?? .distantPast) > ($1.date ?? .distantPast) }) }
            .sorted { $0.0 > $1.0 }
    }

    private func contains(_ haystack: String?, _ needle: String) -> Bool {
        haystack?.localizedCaseInsensitiveContains(needle) ?? false
    }
}
