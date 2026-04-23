// Journal/Views/JournalRowView.swift
import SwiftUI

struct JournalRowView: View {
    let entry: JournalEntry

    private var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: entry.date ?? Date())
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(timeString)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(entry.displayTitle)
                    .font(.headline)
                    .lineLimit(1)
                if !entry.snippet.isEmpty {
                    Text(entry.snippet)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 6) {
                Image(systemName: entry.weatherTag.symbolName)
                    .foregroundColor(entry.weatherTag.tint)
                    .font(.system(size: 18, weight: .semibold))

                if !entry.photoDatas.isEmpty {
                    HStack(spacing: 3) {
                        Image(systemName: "photo")
                            .font(.system(size: 10))
                        Text("\(entry.photoDatas.count)")
                            .font(.caption2)
                    }
                    .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 6)
    }
}
