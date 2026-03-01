import SwiftUI

struct AddEditTaskView: View {
    @EnvironmentObject var store: TaskStore
    @Environment(\.presentationMode) var presentationMode
    
    @State private var title: String = ""
    @State private var notes: String = ""
    @State private var dueDate: Date? = nil
    @State private var hasDueDate: Bool = false
    @State private var priority: Priority = .medium
    var taskToEdit: Task?
    
    init(taskToEdit: Task? = nil) {
        self.taskToEdit = taskToEdit
        // State values are set in onAppear because @State can't be set in init reliably
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task")) {
                    TextField("Title", text: $title)
                    TextField("Notes", text: $notes)
                }
                
                Section(header: Text("Details")) {
                    Toggle("Set due date", isOn: $hasDueDate.animation())
                    if hasDueDate {
                        DatePicker(
                            "Due",
                            selection: Binding(
                                get: { dueDate ?? Date() },
                                set: { dueDate = $0 }
                            ),
                            displayedComponents: .date
                        )
                    }
                    Picker("Priority", selection: $priority) {
                        ForEach(Priority.allCases) { p in
                            Text(p.rawValue.capitalized).tag(p)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
            .navigationTitle(taskToEdit == nil ? "Add Task" : "Edit Task")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { presentationMode.wrappedValue.dismiss() }
                }
            }
            .onAppear(perform: populateIfEditing)
        }
    }
    
    private func populateIfEditing() {
        guard let t = taskToEdit else { return }
        title = t.title
        notes = t.notes ?? ""
        if let d = t.dueDate {
            dueDate = d
            hasDueDate = true
        } else {
            hasDueDate = false
        }
        priority = t.priority
    }
    
    private func save() {
        let newTask = Task(
            id: taskToEdit?.id ?? UUID(),
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            notes: notes.isEmpty ? nil : notes,
            dueDate: hasDueDate ? dueDate : nil,
            isCompleted: taskToEdit?.isCompleted ?? false,
            priority: priority
        )
        
        if taskToEdit == nil {
            store.add(newTask)
        } else {
            store.update(newTask)
        }
        presentationMode.wrappedValue.dismiss()
    }
}

// Helper Binding initializer for optional Date
extension Binding where Value == Date? {
    init(_ source: Binding<Date?>, _ defaultDate: Date) {
        self.init(
            get: { source.wrappedValue ?? defaultDate },
            set: { source.wrappedValue = $0 }
        )
    }
}
