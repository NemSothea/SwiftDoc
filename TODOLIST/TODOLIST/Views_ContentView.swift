

import SwiftUI

struct Views_ContentView: View {
    @EnvironmentObject var store: TaskStore
    @State private var showingAdd = false
    @State private var editTask: Task?
    
    var body: some View {
        NavigationView {
            List {
                if store.tasks.filter({ !$0.isCompleted }).isEmpty {
                    Text("No tasks — add one").foregroundColor(.secondary)
                } else {
                    Section(header: Text("To Do")) {
                        ForEach(store.tasks.filter { !$0.isCompleted }) { task in
                            TaskRow(task: task)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    editTask = task
                                }
                                // iOS 14 doesn't have swipeActions, using contextMenu instead
                                .contextMenu {
                                    Button(action: {
                                        store.toggleComplete(task)
                                    }) {
                                        Label("Mark as Complete", systemImage: "checkmark")
                                    }
                                }
                        }
                        .onDelete(perform: store.remove)
                    }
                }
                
                if !store.tasks.filter({ $0.isCompleted }).isEmpty {
                    Section(header: Text("Completed")) {
                        ForEach(store.tasks.filter { $0.isCompleted }) { task in
                            TaskRow(task: task)
                        }
                        .onDelete(perform: store.remove)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationBarTitle("TODOs")
            .navigationBarItems(
                leading: EditButton(),
                trailing: Button(action: { showingAdd = true }) {
                    Image(systemName: "plus")
                }
            )
            .sheet(isPresented: $showingAdd) {
                AddEditTaskView()
                    .environmentObject(store)
            }
            .sheet(item: $editTask) { task in
                AddEditTaskView(taskToEdit: task)
                    .environmentObject(store)
            }
        }
    }
}
