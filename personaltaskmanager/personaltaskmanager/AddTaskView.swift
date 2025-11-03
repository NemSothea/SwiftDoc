//
//  AddTaskView.swift
//  personaltaskmanager
//
//  Created by sothea007 on 2/11/25.
//
import SwiftUI
import SwiftData

struct AddTaskView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var categories: [Category]
    
    @State private var title = ""
    @State private var taskDescription = ""
    @State private var dueDate = Date().addingTimeInterval(86400)
    @State private var priority = 1
    @State private var selectedCategory: Category?
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Task Details") {
                    TextField("Title", text: $title)
                    TextField("Description", text: $taskDescription, axis: .vertical)
                    
                    DatePicker("Due Date", selection: $dueDate, in: Date()...)
                    
                    Picker("Priority", selection: $priority) {
                        Text("Low").tag(1)
                        Text("Medium").tag(2)
                        Text("High").tag(3)
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Category") {
                    Picker("Category", selection: $selectedCategory) {
                        Text("None").tag(nil as Category?)
                        ForEach(categories) { category in
                            HStack {
                                Circle()
                                    .fill(Color(hex: category.color))
                                    .frame(width: 8, height: 8)
                                Text(category.name)
                            }
                            .tag(category as Category?)
                        }
                    }
                }
            }
            .navigationTitle("Add Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveTask()
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
            .onAppear {
                if selectedCategory == nil && !categories.isEmpty {
                    selectedCategory = categories.first
                }
            }
        }
    }
    
    private func saveTask() {
        let newTask = Task(
            title: title,
            taskDescription: taskDescription,
            dueDate: dueDate,
            priority: priority,
            category: selectedCategory
        )
        modelContext.insert(newTask)
    }
}

struct AddCategoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var selectedColor = "007AFF" // Default to blue hex
    
    // Use hex codes directly instead of color names
    let colors = [
        ("Blue", "007AFF"),
        ("Green", "34C759"),
        ("Red", "FF3B30"),
        ("Orange", "FF9500"),
        ("Purple", "AF52DE"),
        ("Pink", "FC0FC0"),
        ("Yellow", "FFCC00")
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Category Details") {
                    TextField("Name", text: $name)
                    
                    Text("Select Color")
                        .font(.headline)
                        .padding(.top, 8)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 15) {
                        ForEach(colors, id: \.1) { colorName, colorHex in
                            VStack {
                                Circle()
                                    .fill(Color(hex: colorHex))
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Circle()
                                            .stroke(selectedColor == colorHex ? Color.primary : Color.clear, lineWidth: 3)
                                    )
                                    .onTapGesture {
                                        selectedColor = colorHex
                                    }
                                
                                Text(colorName)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Add Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveCategory()
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func saveCategory() {
        let newCategory = Category(name: name, color: selectedColor)
        modelContext.insert(newCategory)
    }
}
