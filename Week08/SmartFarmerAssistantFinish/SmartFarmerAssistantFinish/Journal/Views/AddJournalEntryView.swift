// Journal/Views/AddJournalEntryView.swift
import SwiftUI
import CoreData
import UIKit

struct AddJournalEntryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode

    @State private var title: String = ""
    @State private var content: String = ""
    @State private var weather: Weather = .sunny
    @State private var pickedImages: [UIImage] = []
    @State private var showingPicker = false

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
                            Text("សរសេរកំណត់ហេតុថ្ងៃនេះ…")
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

                    if !pickedImages.isEmpty {
                        PhotoGalleryView(images: pickedImages)
                            .frame(height: 100)
                    }
                }
            }
            .navigationTitle("បន្ថែមកំណត់ហេតុ")
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
                    if let image { pickedImages.append(image) }
                }
            }
        }
    }

    private func save() {
        let entry = JournalEntry(context: viewContext)
        entry.id = UUID()
        entry.date = Date()
        entry.title = title.isEmpty ? nil : title
        entry.content = content
        entry.weather = weather.rawValue
        let datas = pickedImages.compactMap { JournalPhotoStore.encode($0) }
        entry.photos = datas as NSArray

        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("AddJournalEntryView.save failed — \(error)")
        }
    }
}
