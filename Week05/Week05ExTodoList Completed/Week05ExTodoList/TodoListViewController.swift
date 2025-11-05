//
//  ViewController.swift
//  Week05ExTodoList
//
//  Created by sothea007 on 5/11/25.
//

import UIKit

class TodoListViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    private var todoItems: [TodoItem] = [] {
        didSet {
            saveTodos()
            updateSections()
        }
    }
    
    private var activeTodos: [TodoItem] = []
    private var completedTodos: [TodoItem] = []
    
    private enum Section: Int, CaseIterable {
        case active, completed
        
        var title: String {
            switch self {
            case .active: return "Active Tasks"
            case .completed: return "Completed"
            }
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupNavigationBar()
        loadTodos()
        updateSections()
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
        navigationItem.rightBarButtonItem = filterButton
    }
    
    private func updateSections() {
        activeTodos = todoItems.filter { !$0.isCompleted }
        completedTodos = todoItems.filter { $0.isCompleted }
        tableView.reloadData()
    }
    
    // MARK: - Todo Management
    private func toggleTodoCompletion(_ todo: TodoItem) {
        if let index = todoItems.firstIndex(where: { $0.id == todo.id }) {
            todoItems[index].isCompleted.toggle()
            updateSections()
        }
    }
    
    private func deleteTodo(_ todo: TodoItem) {
        todoItems.removeAll { $0.id == todo.id }
        updateSections()
    }
    
    // MARK: - Actions
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
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
                  let todoText = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !todoText.isEmpty else { return }
            
            self.addNewTodo(todoText)
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
        
        let showAllAction = UIAlertAction(title: "Show All", style: .default) { _ in
            // Reset to show all
            self.updateSections()
        }
        
        let showActiveAction = UIAlertAction(title: "Active Only", style: .default) { _ in
            // Filter logic would go here
        }
        
        let showCompletedAction = UIAlertAction(title: "Completed Only", style: .default) { _ in
            // Filter logic would go here
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(showAllAction)
        alert.addAction(showActiveAction)
        alert.addAction(showCompletedAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func addNewTodo(_ title: String) {
        let newTodo = TodoItem(title: title)
        todoItems.insert(newTodo, at: 0)
        updateSections()
        
        // Scroll to top
        if activeTodos.count > 0 {
            let indexPath = IndexPath(row: 0, section: Section.active.rawValue)
            tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }
}

// MARK: - UITableViewDataSource
extension TodoListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionType = Section(rawValue: section) else { return 0 }
        
        switch sectionType {
        case .active:
            return activeTodos.count
        case .completed:
            return completedTodos.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath) as! TodoCell
        
        guard let sectionType = Section(rawValue: indexPath.section) else { return cell }
        
        let todo: TodoItem
        switch sectionType {
        case .active:
            todo = activeTodos[indexPath.row]
        case .completed:
            todo = completedTodos[indexPath.row]
        }
        
        cell.configure(with: todo)
        
        // Completion toggle handler
        cell.statusButtonTapped = { [weak self] in
            self?.toggleTodoCompletion(todo)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sectionType = Section(rawValue: section) else { return nil }
        
        switch sectionType {
        case .active:
            return activeTodos.isEmpty ? nil : "Active Tasks (\(activeTodos.count))"
        case .completed:
            return completedTodos.isEmpty ? nil : "Completed (\(completedTodos.count))"
        }
    }
    
    // Swipe to delete
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let sectionType = Section(rawValue: indexPath.section) else { return }
            
            let todo: TodoItem
            switch sectionType {
            case .active:
                todo = activeTodos[indexPath.row]
            case .completed:
                todo = completedTodos[indexPath.row]
            }
            
            deleteTodo(todo)
        }
    }
    
    // Move rows between sections
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // Handle reordering if needed
    }
}

// MARK: - UITableViewDelegate
extension TodoListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let sectionType = Section(rawValue: indexPath.section) else { return }
        
        let todo: TodoItem
        switch sectionType {
        case .active:
            todo = activeTodos[indexPath.row]
        case .completed:
            todo = completedTodos[indexPath.row]
        }
        
        // Show edit alert
        showEditTodoAlert(for: todo)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    // Custom swipe actions
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        guard let sectionType = Section(rawValue: indexPath.section) else { return nil }
        
        let todo: TodoItem
        switch sectionType {
        case .active:
            todo = activeTodos[indexPath.row]
        case .completed:
            todo = completedTodos[indexPath.row]
        }
        
        // Delete action
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, completion) in
            self?.deleteTodo(todo)
            completion(true)
        }
        deleteAction.image = UIImage(systemName: "trash")
        
        // Edit action
        let editAction = UIContextualAction(style: .normal, title: "Edit") { [weak self] (_, _, completion) in
            self?.showEditTodoAlert(for: todo)
            completion(true)
        }
        editAction.backgroundColor = .systemBlue
        editAction.image = UIImage(systemName: "pencil.tip.crop.circle.fill")
        
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        guard let sectionType = Section(rawValue: indexPath.section) else { return nil }
        
        let todo: TodoItem
        switch sectionType {
        case .active:
            todo = activeTodos[indexPath.row]
        case .completed:
            todo = completedTodos[indexPath.row]
        }
        
        // Complete/Incomplete action
        let title = todo.isCompleted ? "Incomplete" : "Complete"
        let imageName = todo.isCompleted ? "circle" : "checkmark.circle.fill"
        let color: UIColor = todo.isCompleted ? .systemOrange : .systemGreen
        
        let completeAction = UIContextualAction(style: .normal, title: title) { [weak self] (_, _, completion) in
            self?.toggleTodoCompletion(todo)
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
                  let newText = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !newText.isEmpty else { return }
            
            if let index = self.todoItems.firstIndex(where: { $0.id == todo.id }) {
                self.todoItems[index].title = newText
                self.updateSections()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
}

// MARK: - Persistence with UserDefaults
extension TodoListViewController {
    private func saveTodos() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(todoItems)
            UserDefaults.standard.set(data, forKey: "todos")
        } catch {
            print("Error saving todos: \(error)")
        }
    }
    
    private func loadTodos() {
        guard let data = UserDefaults.standard.data(forKey: "todos") else {
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
