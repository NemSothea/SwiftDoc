//
//  EditCategoryView.swift
//  personaltaskmanager
//
//  Created by sothea007 on 2/11/25.
//
import SwiftUI
import SwiftData

struct EditCategoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var category: Category
    
    @State private var editedName: String
    @State private var editedColor: String
    
    let colors = [
        ("Blue", "007AFF"),
        ("Green", "34C759"),
        ("Red", "FF3B30"),
        ("Orange", "FF9500"),
        ("Purple", "AF52DE"),
        ("Pink", "FC0FC0"),
        ("Yellow", "FFCC00")
    ]
    
    init(category: Category) {
        self.category = category
        self._editedName = State(initialValue: category.name)
        self._editedColor = State(initialValue: category.color)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Category Details") {
                    TextField("Name", text: $editedName)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 15) {
                        ForEach(colors, id: \.1) { colorName, colorHex in
                            VStack {
                                Circle()
                                    .fill(Color(hex: colorHex))
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Circle()
                                            .stroke(editedColor == colorHex ? Color.primary : Color.clear, lineWidth: 3)
                                    )
                                    .onTapGesture {
                                        editedColor = colorHex
                                    }
                                
                                Text(colorName)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section {
                    Button("Delete Category", role: .destructive) {
                        modelContext.delete(category)
                        dismiss()
                    }
                }
            }
            .navigationTitle("Edit Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveChanges()
                        dismiss()
                    }
                    .disabled(editedName.isEmpty)
                }
            }
        }
    }
    
    private func saveChanges() {
        category.name = editedName
        category.color = editedColor
    }
}
