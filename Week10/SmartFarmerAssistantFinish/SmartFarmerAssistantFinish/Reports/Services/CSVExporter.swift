// Reports/Services/CSVExporter.swift
import Foundation

struct CSVExporter {

    // MARK: - Build CSV string

    static func makeTransactionCSV(_ transactions: [Transaction]) -> String {
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .none

        var lines = ["Date,Type,Category,Amount,Note"]
        for t in transactions {
            let date     = df.string(from: t.date ?? Date())
            let type_    = t.isIncome ? "Income" : "Expense"
            let category = escape(t.category)
            let amount   = String(format: "%.2f", t.amount)
            let note     = escape(t.note)
            lines.append("\(date),\(type_),\(category),\(amount),\(note)")
        }
        return lines.joined(separator: "\n")
    }

    // MARK: - Write to temp file

    /// Writes `csv` to the system temp directory and returns the file URL.
    /// Returns `nil` only if the write fails.
    static func writeToTempFile(_ csv: String, named filename: String) -> URL? {
        let url = FileManager.default
            .temporaryDirectory
            .appendingPathComponent(filename + ".csv")
        do {
            try csv.write(to: url, atomically: true, encoding: .utf8)
            return url
        } catch {
            return nil
        }
    }

    // MARK: - Private

    /// Wraps values that contain commas in double-quotes (RFC 4180).
    private static func escape(_ value: String?) -> String {
        guard let v = value, !v.isEmpty else { return "" }
        if v.contains(",") || v.contains("\"") || v.contains("\n") {
            let escaped = v.replacingOccurrences(of: "\"", with: "\"\"")
            return "\"\(escaped)\""
        }
        return v
    }
}
