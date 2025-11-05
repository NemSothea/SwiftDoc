//
//  TodoListManaging.swift
//  Week06ExTodoList
//
//  Created by sothea007 on 5/11/25.
//


// TodoListManaging.swift
import Foundation

protocol TodoListManaging: AnyObject {
    
    var todoItems: [TodoItem] { get }
    var activeTodos: [TodoItem] { get }
    var completedTodos: [TodoItem] { get }
    var activeCount: Int { get }
    var completedCount: Int { get }
    
    func addTodo(title: String)
    func toggleTodoCompletion(_ todo: TodoItem)
    func updateTodo(_ todo: TodoItem, newTitle: String)
    func deleteTodo(_ todo: TodoItem)
    func deleteTodo(at indexSet: IndexSet, in section: TodoSection)
    func markAllAsCompleted()
    func clearCompleted()
    func clearAll()
    func getTodos(for section: TodoSection) -> [TodoItem]
    func isTitleValid(_ title: String) -> Bool
    func isDuplicateTitle(_ title: String) -> Bool
}



// Error Types
enum TodoError: Error {
    case invalidTitle
    case duplicateTitle
    case todoNotFound
    
    var message: String {
        switch self {
        case .invalidTitle:
            return "Todo title cannot be empty"
        case .duplicateTitle:
            return "A todo with this title already exists"
        case .todoNotFound:
            return "Todo item not found"
        }
    }
}
