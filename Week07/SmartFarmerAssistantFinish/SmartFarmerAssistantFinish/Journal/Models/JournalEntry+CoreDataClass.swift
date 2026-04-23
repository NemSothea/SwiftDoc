// Journal/Models/JournalEntry+CoreDataClass.swift
import Foundation
import CoreData

@objc(JournalEntry)
public class JournalEntry: NSManagedObject {

    /// First line of `content`, used as a row title when `title` is nil.
    var displayTitle: String {
        if let title, !title.isEmpty { return title }
        let firstLine = (content ?? "")
            .split(whereSeparator: \.isNewline)
            .first
            .map(String.init) ?? ""
        return firstLine.isEmpty ? "(No title)" : firstLine
    }

    /// One-line preview for the timeline row.
    var snippet: String {
        let body = (content ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !body.isEmpty else { return "" }
        return body.count > 120 ? String(body.prefix(120)) + "…" : body
    }

    /// Typed view over the raw `weather` string.
    var weatherTag: Weather {
        Weather(rawValue: weather ?? "") ?? .sunny
    }

    /// Typed view over the `photos` transformable attribute.
    var photoDatas: [Data] {
        (photos as? [Data]) ?? []
    }
}
