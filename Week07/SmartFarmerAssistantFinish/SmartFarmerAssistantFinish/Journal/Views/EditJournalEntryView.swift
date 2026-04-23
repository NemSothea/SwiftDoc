// Journal/Views/EditJournalEntryView.swift
import SwiftUI
import CoreData
import UIKit

struct EditJournalEntryView: View {
    @ObservedObject var entry: JournalEntry
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode

    @State private var title: String
    @State private var content: String
    @State private var weather: Weather
    @State private var images: [UIImage]
    @State private var showingPicker = false

    init(entry: JournalEntry) {
        self.entry = entry
        _title   = State(initialValue: entry.title ?? "")
        _content = State(initialValue: entry.content ?? "")
        _weather = State(initialValue: entry.weatherTag)
        _images  = State(initialValue: JournalPhotoStore.images(for: entry))
    }

    private var canSave: Bool {
        !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("ចំណងជើង")) {
                    TextField("ចំណងជើង (ស្រេចចិត្ត)", text: $title)
                }

                Section(header: Text("អាកាសធាតុ")) {
                    WeatherPickerView(selection: $weather)
                }

                Section(header: Text("មាតិកា")) {
                    ZStack(alignment: .topLeading) {
                        if content.isEmpty {
                            Text("សរសេរកំណត់ហេតុ…")
                                .foregroundColor(.gray)
                                .padding(.top, 8)
                                .padding(.leading, 4)
                        }
                        TextEditor(text: $content)
                            .frame(minHeight: 140)
                    }
                }

                Section(header: Text("រូបភាព")) {
                    Button {
                        showingPicker = true
                    } label: {
                        HStack {
                            Image(systemName: "camera")
                            Text("បន្ថែមរូបភាព")
                        }
                    }

                    if !images.isEmpty {
                        PhotoGalleryView(images: images)
                            .frame(height: 100)
                    }
                }
            }
            .navigationTitle("កែប្រែកំណត់ហេតុ")
            .navigationBarItems(
                leading: Button("បោះបង់") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("រក្សាទុក") {
                    save()
                }
                .disabled(!canSave)
            )
            .sheet(isPresented: $showingPicker) {
                PhotoPicker { image in
                    if let image { images.append(image) }
                }
            }
        }
    }

    private func save() {
        entry.title = title.isEmpty ? nil : title
        entry.content = content
        entry.weather = weather.rawValue
        let datas = images.compactMap { JournalPhotoStore.encode($0) }
        entry.photos = datas as NSArray

        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("EditJournalEntryView.save failed — \(error)")
        }
    }
}
