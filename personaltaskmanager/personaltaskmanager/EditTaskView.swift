//
//  EditTaskView.swift
//  personaltaskmanager
//
//  Created by sothea007 on 2/11/25.
//
import SwiftUI
import SwiftData

struct EditTaskView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var task: Task
    @Query private var categories: [Category]
    
    @State private var editedTitle: String
    @State private var editedDescription: String
    @State private var editedDueDate: Date
    @State private var editedPriority: Int
    @State private var editedCategory: Category?
    
    init(task: Task) {
        self.task = task
        self._editedTitle = State(initialValue: task.title)
        self._editedDescription = State(initialValue: task.taskDescription)
        self._editedDueDate = State(initialValue: task.dueDate)
        self._editedPriority = State(initialValue: task.priority)
        self._editedCategory = State(initialValue: task.category)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Task Details") {
                    TextField("Title", text: $editedTitle)
                    TextField("Description", text: $editedDescription, axis: .vertical)
                    
                    DatePicker("Due Date", selection: $editedDueDate, in: Date()...)
                    
                    Picker("Priority", selection: $editedPriority) {
                        Text("Low").tag(1)
                        Text("Medium").tag(2)
                        Text("High").tag(3)
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Category") {
                    Picker("Category", selection: $editedCategory) {
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
                
                Section {
                    Button("Mark as \(task.isCompleted ? "Incomplete" : "Complete")") {
                        task.isCompleted.toggle()
                        dismiss()
                    }
                    .foregroundColor(task.isCompleted ? .orange : .green)
                    
                    Button("Delete Task", role: .destructive) {
                        deleteTask()
                        dismiss()
                    }
                }
            }
            .navigationTitle("Edit Task")
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
                    .disabled(editedTitle.isEmpty)
                }
            }
        }
    }
    
    private func saveChanges() {
        task.title = editedTitle
        task.taskDescription = editedDescription
        task.dueDate = editedDueDate
        task.priority = editedPriority
        task.category = editedCategory
    }
    
    private func deleteTask() {
        modelContext.delete(task)
    }
}
