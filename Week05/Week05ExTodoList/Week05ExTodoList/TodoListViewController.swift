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
    var todoItems: [TodoItem] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupNavigationBar()
        loadSampleData()
    }
    
    // MARK: - Setup Methods
    private func setupTableView() {
        // Set data source and delegate
        tableView.dataSource = self
        tableView.delegate = self
        
        // Register cell
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TodoCell")
        
        // Remove empty cells
        tableView.tableFooterView = UIView()
    }
    
    private func setupNavigationBar() {
        title = "My Todo List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Add edit button
        navigationItem.leftBarButtonItem = editButtonItem
    }
    
    private func loadSampleData() {
        todoItems = [
            TodoItem(title: "Learn UITableView", isCompleted: false),
            TodoItem(title: "Build todo app", isCompleted: true),
            TodoItem(title: "Practice Swift", isCompleted: false),
            TodoItem(title: "Study iOS development", isCompleted: false)
        ]
        tableView.reloadData()
    }
    
    // MARK: - Actions
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        showAddTodoAlert()
    }
    
    // Override edit button functionality
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
    }
    
    // MARK: - Helper Methods
    private func showAddTodoAlert() {
        let alert = UIAlertController(
            title: "Add New Todo",
            message: "Enter your todo item",
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = "What needs to be done?"
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
    
    private func addNewTodo(_ title: String) {
        let newTodo = TodoItem(title: title, isCompleted: false)
        
        // Add to the beginning of the array
        todoItems.insert(newTodo, at: 0)
        
        // Insert row at the top of the table
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    private func toggleTodoCompletion(at indexPath: IndexPath) {
        todoItems[indexPath.row].isCompleted.toggle()
        tableView.reloadRows(at: [indexPath], with: .fade)
    }
    
    private func showEditTodoAlert(for indexPath: IndexPath) {
        let alert = UIAlertController(
            title: "Edit Todo",
            message: "Modify your todo item",
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.text = self.todoItems[indexPath.row].title
            textField.autocapitalizationType = .sentences
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let self = self,
                  let textField = alert.textFields?.first,
                  let newText = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !newText.isEmpty else { return }
            
            self.todoItems[indexPath.row].title = newText
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
}

// MARK: - Data Model
struct TodoItem {
    var title: String
    var isCompleted: Bool
}

// MARK: - UITableViewDataSource
extension TodoListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath)
        let todoItem = todoItems[indexPath.row]
        
        // Configure the cell
        cell.textLabel?.text = todoItem.title
        cell.textLabel?.textColor = todoItem.isCompleted ? .systemGray : .label
        
        // Add checkmark for completed items
        cell.accessoryType = todoItem.isCompleted ? .checkmark : .none
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension TodoListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Toggle completion status when row is tapped
        toggleTodoCompletion(at: indexPath)
    }
    
    // Swipe to delete
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Remove from data source
            todoItems.remove(at: indexPath.row)
            
            // Remove from table view
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    // Custom swipe actions
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        // Delete action
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, completionHandler) in
            self?.todoItems.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            completionHandler(true)
        }
        
        // Edit action
        let editAction = UIContextualAction(style: .normal, title: "Edit") { [weak self] (_, _, completionHandler) in
            self?.showEditTodoAlert(for: indexPath)
            completionHandler(true)
        }
        editAction.backgroundColor = .systemBlue
        
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
    
    // Left swipe actions
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let completeAction = UIContextualAction(style: .normal, title: "Complete") { [weak self] (_, _, completionHandler) in
            self?.toggleTodoCompletion(at: indexPath)
            completionHandler(true)
        }
        completeAction.backgroundColor = .systemGreen
        
        return UISwipeActionsConfiguration(actions: [completeAction])
    }
    
    // Row height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
}

