//
//  TodoList.swift
//  Week06ExTodoList
//
//  Created by sothea007 on 5/11/25.
//
import Foundation
import Combine

class TodoList: ObservableObject {
    
    @Published var todoItems: [TodoItem] = [] {
        didSet {
            saveTodos()
        }
    }
    private let saveKey = "todos"
    
    // MARK: - Computed Properties
    // Swift Computed Property allows you to define values based on other properties.
    var activeTodos: [TodoItem] {
        todoItems.filter { !$0.isCompleted }
    }
    
    var completedTodos: [TodoItem] {
        todoItems.filter { $0.isCompleted }
    }
    
    
    var completedCount: Int {
        completedTodos.count
    }
    
    var activeCount: Int {
        activeTodos.count
    }
    
    // MARK: - Initialization
    init() {
        loadTodos()
    }
    
    // MARK: - CRUD Operations
    func addTodo(title: String) {
        let newTodo = TodoItem(title: title)
        todoItems.insert(newTodo, at: 0)
    }
    
    func toggleTodoCompletion(_ todo: TodoItem) {
        if let index = todoItems.firstIndex(where: { $0.id == todo.id }) {
            todoItems[index].isCompleted.toggle()
        }
    }
    
    func updateTodo(_ todo: TodoItem, newTitle: String) {
        if let index = todoItems.firstIndex(where: { $0.id == todo.id }) {
            todoItems[index].title = newTitle
        }
    }
    
    func deleteTodo(_ todo: TodoItem) {
        todoItems.removeAll { $0.id == todo.id }
    }
    
    func deleteTodo(at indexSet: IndexSet, in section: TodoSection) {
        let items = section == .active ? activeTodos : completedTodos
        indexSet.forEach { index in
            let todo = items[index]
            deleteTodo(todo)
        }
    }
    
    // MARK: - Business Logic
    func markAllAsCompleted() {
        for index in todoItems.indices {
            todoItems[index].isCompleted = true
        }
    }
    
    func clearCompleted() {
        todoItems.removeAll { $0.isCompleted }
    }
    
    func clearAll() {
        todoItems.removeAll()
    }
    
    func getTodos(for section: TodoSection) -> [TodoItem] {
        switch section {
        case .active:
            return activeTodos
        case .completed:
            return completedTodos
        }
    }
    
    func hasTodos(in section: TodoSection) -> Bool {
        !getTodos(for: section).isEmpty
    }
    
    
    // MARK: - Validation
    func isTitleValid(_ title: String) -> Bool {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmedTitle.isEmpty && trimmedTitle.count >= 1
    }
    
    func isDuplicateTitle(_ title: String) -> Bool {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        return todoItems.contains { $0.title.lowercased() == trimmedTitle.lowercased() }
    }
    
    // MARK: - Persistence
    private func saveTodos() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(todoItems)
            UserDefaults.standard.set(data, forKey: saveKey)
        } catch {
            print("Error saving todos: \(error)")
        }
    }
    
    private func loadTodos() {
        guard let data = UserDefaults.standard.data(forKey: saveKey) else {
            loadSampleData()
            return
        }
        
        do {
            let decoder = JSONDecoder()
            todoItems = try decoder.decode([TodoItem].self, from: data)
        } catch {
            print("Error loading todos: \(error)")
            loadSampleData()
        }
    }
    
    private func loadSampleData() {
        todoItems = [
            TodoItem(title: "Learn UITableView and build todo app", isCompleted: true),
            TodoItem(title: "Implement custom cells with better UI", isCompleted: false),
            TodoItem(title: "Add swipe actions and sections", isCompleted: false),
            TodoItem(title: "Save data with UserDefaults", isCompleted: true),
            TodoItem(title: "Test the completed app functionality", isCompleted: false)
        ]
    }
}

// MARK: - Section Enum
enum TodoSection: Int, CaseIterable {
    case active, completed
    
    var title: String {
        switch self {
        case .active: return "Active Tasks"
        case .completed: return "Completed"
        }
    }
}
