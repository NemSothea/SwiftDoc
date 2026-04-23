//
//  JournalTabView.swift
//  SmartFarmerAssistantFinish
//
//  Created by sothea007 on 17/3/26.
//

import SwiftUI
import CoreData

struct JournalTabView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        entity: JournalEntry.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \JournalEntry.date, ascending: false)]
    ) var entries: FetchedResults<JournalEntry>

    @State private var showingAddEntry = false

    var body: some View {
        NavigationView {
            List {
                ForEach(entries, id: \.self) { entry in
                    NavigationLink(destination: JournalDetailView(entry: entry)) {
                        JournalRowView(entry: entry)
                    }
                }
                .onDelete(perform: deleteEntries)
            }
            .navigationTitle("កំណត់ហេតុកសិកម្ម")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddEntry = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddEntry) {
                AddJournalEntryView()
                    .environment(\.managedObjectContext, viewContext)
            }
        }
    }

    private func deleteEntries(offsets: IndexSet) {
        for index in offsets {
            viewContext.delete(entries[index])
        }
        try? viewContext.save()
    }
}

struct JournalRowView: View {
    let entry: JournalEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                if let date = entry.date {
                    Text(date.formattedMedium)
                        .font(.headline)
                }
                Spacer()
                if let weather = entry.weather, !weather.isEmpty {
                    Text(weather)
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }

            if let content = entry.content, !content.isEmpty {
                Text(content)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }

            if let location = entry.location, !location.isEmpty {
                Label(location, systemImage: "mappin.circle")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 4)
    }
}

struct JournalDetailView: View {
    let entry: JournalEntry

    var body: some View {
        List {
            if let date = entry.date {
                Section(header: Text("កាលបរិច្ឆេទ")) {
                    Text(date.formattedMedium)
                }
            }

            if let weather = entry.weather {
                Section(header: Text("អាកាសធាតុ")) {
                    Text(weather)
                }
            }

            if let location = entry.location {
                Section(header: Text("ទីតាំង")) {
                    Text(location)
                }
            }

            if let content = entry.content {
                Section(header: Text("មាតិកា")) {
                    Text(content)
                }
            }
        }
        .navigationTitle("កំណត់ហេតុ")
    }
}

struct AddJournalEntryView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var viewContext

    @State private var content = ""
    @State private var weather = ""
    @State private var location = ""
    @State private var date = Date()

    let weatherOptions = ["☀️ ថ្ងៃរះ", "🌤 មេឃពាក់កណ្ដាល", "🌧 ភ្លៀង", "⛅ មេឃច្រើនពពក", "🌩 ព្យុះ"]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("កាលបរិច្ឆេទ")) {
                    DatePicker("", selection: $date, displayedComponents: .date)
                        .labelsHidden()
                }

                Section(header: Text("អាកាសធាតុ")) {
                    Picker("អាកាសធាតុ", selection: $weather) {
                        Text("ជ្រើសរើស").tag("")
                        ForEach(weatherOptions, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }
                }

                Section(header: Text("ទីតាំង")) {
                    TextField("ឧ. វាលស្រែ ១", text: $location)
                }

                Section(header: Text("មាតិកា")) {
                    ZStack(alignment: .topLeading) {
                        if content.isEmpty {
                            Text("សរសេរកំណត់ហេតុរបស់អ្នក...")
                                .foregroundColor(.gray)
                                .padding(.top, 8)
                        }
                        TextEditor(text: $content)
                            .frame(minHeight: 120)
                    }
                }
            }
            .navigationTitle("បន្ថែមកំណត់ហេតុ")
            .navigationBarItems(
                leading: Button("បោះបង់") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("រក្សាទុក") {
                    saveEntry()
                }
                .disabled(content.isEmpty)
            )
        }
    }

    private func saveEntry() {
        let entry = JournalEntry(context: viewContext)
        entry.id = UUID()
        entry.date = date
        entry.content = content
        entry.weather = weather
        entry.location = location

        try? viewContext.save()
        presentationMode.wrappedValue.dismiss()
    }
}
