// Journal/Views/JournalTabView.swift
import SwiftUI
import CoreData

struct JournalTabView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        entity: JournalEntry.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \JournalEntry.date, ascending: false)]
    ) private var entries: FetchedResults<JournalEntry>

    @StateObject private var viewModel = JournalViewModel()
    @State private var showingAdd = false

    private var filteredEntries: [JournalEntry] {
        viewModel.filter(Array(entries))
    }

    private var dayGroups: [(Date, [JournalEntry])] {
        viewModel.groupByDay(filteredEntries)
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                SearchBar(text: $viewModel.searchText,
                          placeholder: "ស្វែងរកចំណងជើង ឬមាតិកា…")

                weatherChips
                    .padding(.horizontal)
                    .padding(.bottom, 6)

                if dayGroups.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(dayGroups, id: \.0) { day, entriesInDay in
                            Section(header: Text(sectionHeader(for: day))) {
                                ForEach(entriesInDay, id: \.self) { entry in
                                    NavigationLink(destination: JournalDetailView(entry: entry)) {
                                        JournalRowView(entry: entry)
                                    }
                                }
                                .onDelete { indices in
                                    delete(indices, from: entriesInDay)
                                }
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("កំណត់ហេតុ")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAdd = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddJournalEntryView()
                    .environment(\.managedObjectContext, viewContext)
            }
        }
    }

    // MARK: - Weather filter chips
    @ViewBuilder
    private var weatherChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                chip(for: nil, label: "ទាំងអស់", symbol: "line.3.horizontal.decrease.circle")
                ForEach(Weather.allCases) { weather in
                    chip(for: weather, label: weather.label, symbol: weather.symbolName)
                }
            }
        }
    }

    private func chip(for weather: Weather?, label: String, symbol: String) -> some View {
        let isSelected = viewModel.weatherFilter == weather
        let tint = weather?.tint ?? .blue
        return Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                viewModel.weatherFilter = isSelected ? nil : weather
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: symbol)
                Text(label).font(.footnote.bold())
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(isSelected ? tint : Color(.systemGray6))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(14)
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Empty state
    @ViewBuilder
    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "book.closed")
                .font(.system(size: 44))
                .foregroundColor(.gray)
            Text(viewModel.searchText.isEmpty && viewModel.weatherFilter == nil
                 ? "មិនទាន់មានកំណត់ហេតុ — ចុច + ដើម្បីចាប់ផ្តើម"
                 : "រកមិនឃើញលទ្ធផល")
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Spacer()
        }
    }

    // MARK: - Helpers
    private func sectionHeader(for day: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "EEEE, MMMM d"
        return f.string(from: day)
    }

    private func delete(_ indices: IndexSet, from entriesInDay: [JournalEntry]) {
        for idx in indices {
            let entry = entriesInDay[idx]
            viewContext.delete(entry)
        }
        do {
            try viewContext.save()
        } catch {
            print("JournalTabView.delete failed — \(error)")
        }
    }
}
