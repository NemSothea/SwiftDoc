//
//  ViewController.swift
//  Week06ExTodoList
//
//  Created by sothea007 on 5/11/25.
//

import UIKit
import Combine


import UIKit
import Combine

class TodoListViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    private var todoList: TodoListManaging
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization with Dependency Injection
    init(todoList: TodoListManaging = TodoList()) {
        self.todoList = todoList
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.todoList = TodoList()
        super.init(coder: coder)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupNavigationBar()
        setupDelegates()
        setupObservers()
    }
    
    // MARK: - Setup Methods
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(TodoCell.self, forCellReuseIdentifier: "TodoCell")
        tableView.separatorStyle = .none
        tableView.backgroundColor = .systemGroupedBackground
    }
    
    private func setupNavigationBar() {
        title = "My Todo List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Add edit button
        navigationItem.leftBarButtonItem = editButtonItem
        
        // Add filter button
        let filterButton = UIBarButtonItem(
            image: UIImage(systemName: "line.3.horizontal.decrease.circle"),
            style: .plain,
            target: self,
            action: #selector(filterButtonTapped)
        )
        
        // Add add button
        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonTapped)
        )
        
        navigationItem.rightBarButtonItems = [addButton, filterButton]
    }
    
    private func setupDelegates() {
        // Set self as delegate for TodoList
        if let todoList = todoList as? TodoList {
            todoList.delegate = self
        }
    }
    
    private func setupObservers() {
        // For ObservableObject compatibility
        if let observableTodoList = todoList as? TodoList {
            observableTodoList.$todoItems
                .receive(on: RunLoop.main)
                .sink { [weak self] _ in
                    self?.tableView.reloadData()
                }
                .store(in: &cancellables)
        }
    }
    
    // MARK: - Actions
    @objc private func addButtonTapped() {
        showAddTodoAlert()
    }
    
    @objc private func filterButtonTapped() {
        showFilterOptions()
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
    }
    
    // MARK: - Alert Controllers
    private func showAddTodoAlert() {
        let alert = UIAlertController(
            title: "Add New Todo",
            message: "What do you want to accomplish?",
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = "Enter todo item"
            textField.autocapitalizationType = .sentences
        }
        
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            guard let self = self,
                  let textField = alert.textFields?.first,
                  let todoText = textField.text else { return }
            
            // Model now handles validation and error reporting via delegate
            self.todoList.addTodo(title: todoText)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func showFilterOptions() {
        let alert = UIAlertController(
            title: "Filter Todos",
            message: nil,
            preferredStyle: .actionSheet
        )
        
        let markAllCompleteAction = UIAlertAction(title: "Mark All Complete", style: .default) { [weak self] _ in
            self?.todoList.markAllAsCompleted()
        }
        
        let clearCompletedAction = UIAlertAction(title: "Clear Completed", style: .destructive) { [weak self] _ in
            self?.todoList.clearCompleted()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(markAllCompleteAction)
        alert.addAction(clearCompletedAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func scrollToTopIfNeeded() {
        if todoList.activeCount > 0 {
            let indexPath = IndexPath(row: 0, section: TodoSection.active.rawValue)
            tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension TodoListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return TodoSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionType = TodoSection(rawValue: section) else { return 0 }
        return todoList.getTodos(for: sectionType).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath) as! TodoCell
        
        guard let sectionType = TodoSection(rawValue: indexPath.section) else { return cell }
        
        let todo = todoList.getTodos(for: sectionType)[indexPath.row]
        cell.configure(with: todo)
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sectionType = TodoSection(rawValue: section) else { return nil }
        
        switch sectionType {
        case .active:
            return todoList.activeCount > 0 ? "Active Tasks (\(todoList.activeCount))" : nil
        case .completed:
            return todoList.completedCount > 0 ? "Completed (\(todoList.completedCount))" : nil
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let sectionType = TodoSection(rawValue: indexPath.section) else { return }
            todoList.deleteTodo(at: IndexSet(integer: indexPath.row), in: sectionType)
        }
    }
}

// MARK: - UITableViewDelegate
extension TodoListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let sectionType = TodoSection(rawValue: indexPath.section) else { return }
        
        let todo = todoList.getTodos(for: sectionType)[indexPath.row]
        showEditTodoAlert(for: todo)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        guard let sectionType = TodoSection(rawValue: indexPath.section) else { return nil }
        let todo = todoList.getTodos(for: sectionType)[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, completion) in
            self?.todoList.deleteTodo(todo)
            completion(true)
        }
        deleteAction.image = UIImage(systemName: "trash")
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { [weak self] (_, _, completion) in
            self?.showEditTodoAlert(for: todo)
            completion(true)
        }
        editAction.backgroundColor = .systemBlue
        editAction.image = UIImage(systemName: "pencil")
        
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        guard let sectionType = TodoSection(rawValue: indexPath.section) else { return nil }
        let todo = todoList.getTodos(for: sectionType)[indexPath.row]
        
        let title = todo.isCompleted ? "Mark Active" : "Complete"
        let imageName = todo.isCompleted ? "circle" : "checkmark.circle.fill"
        let color: UIColor = todo.isCompleted ? .systemOrange : .systemGreen
        
        let completeAction = UIContextualAction(style: .normal, title: title) { [weak self] (_, _, completion) in
            self?.todoList.toggleTodoCompletion(todo)
            completion(true)
        }
        completeAction.backgroundColor = color
        completeAction.image = UIImage(systemName: imageName)
        
        return UISwipeActionsConfiguration(actions: [completeAction])
    }
    
    private func showEditTodoAlert(for todo: TodoItem) {
        let alert = UIAlertController(
            title: "Edit Todo",
            message: "Modify your todo item",
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.text = todo.title
            textField.autocapitalizationType = .sentences
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let self = self,
                  let textField = alert.textFields?.first,
                  let newText = textField.text else { return }
            
            self.todoList.updateTodo(todo, newTitle: newText)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
}

// MARK: - TodoListDelegate
extension TodoListViewController: TodoListDelegate {
    func todoListDidUpdate(_ todoList: TodoListManaging) {
        tableView.reloadData()
    }
    
    func todoList(_ todoList: TodoListManaging, didEncounterError error: TodoError) {
        showErrorAlert(message: error.message)
    }
}

//// MARK: - TodoCellDelegate
extension TodoListViewController: TodoCellDelegate {
    func todoCellDidToggleStatus(_ cell: TodoCell, for todo: TodoItem) {
        todoList.toggleTodoCompletion(todo)
    }
}
