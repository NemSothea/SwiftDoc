// Journal/Views/JournalDetailView.swift
import SwiftUI
import CoreData

struct JournalDetailView: View {
    @ObservedObject var entry: JournalEntry
    @Environment(\.managedObjectContext) private var viewContext

    @State private var showingEdit = false

    private var headerDateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        return formatter.string(from: entry.date ?? Date())
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                weatherBadge

                Text(headerDateString)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                if let title = entry.title, !title.isEmpty {
                    Text(title)
                        .font(.title2.bold())
                }

                Text(entry.content ?? "")
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Divider()

                ExpandableSection(title: "រូបភាព", icon: "photo.on.rectangle") {
                    PhotoGalleryView(images: JournalPhotoStore.images(for: entry))
                }

                ExpandableSection(title: "ព័ត៌មានលម្អិត",
                                  icon: "info.circle",
                                  initiallyExpanded: false) {
                    metadataRows
                }
            }
            .padding()
        }
        .navigationTitle(entry.displayTitle)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("កែប្រែ") { showingEdit = true }
            }
        }
        .sheet(isPresented: $showingEdit) {
            EditJournalEntryView(entry: entry)
                .environment(\.managedObjectContext, viewContext)
        }
    }

    @ViewBuilder
    private var weatherBadge: some View {
        HStack(spacing: 6) {
            Image(systemName: entry.weatherTag.symbolName)
            Text(entry.weatherTag.label)
                .font(.subheadline.bold())
        }
        .foregroundColor(.white)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(entry.weatherTag.tint)
        .cornerRadius(12)
    }

    @ViewBuilder
    private var metadataRows: some View {
        VStack(alignment: .leading, spacing: 6) {
            metadataRow("Created", entry.date.map(formatFull) ?? "—")
            metadataRow("Weather", entry.weatherTag.label)
            metadataRow("Photos", "\(entry.photoDatas.count)")
            metadataRow("ID", entry.id?.uuidString ?? "—")
        }
        .font(.footnote)
    }

    private func metadataRow(_ key: String, _ value: String) -> some View {
        HStack(alignment: .top) {
            Text(key)
                .foregroundColor(.secondary)
                .frame(width: 80, alignment: .leading)
            Text(value)
                .foregroundColor(.primary)
            Spacer()
        }
    }

    private func formatFull(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f.string(from: date)
    }
}
