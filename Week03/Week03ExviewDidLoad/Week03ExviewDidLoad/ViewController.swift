//
//  ViewController.swift
//  Week03ExviewDidLoad
//
//  Created by sothea007 on 3/11/25.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    // MARK: - UI Components
    private let userTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.backgroundColor = .systemGroupedBackground
        return tableView
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - Properties
    var users: [User] = []
    let apiService = APIService()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // One-time setup
        setupTableView()
        
        setupUI()
        
        // Kick off initial API call
        fetchUsers()
    }
    
    
    // MARK: - Setup
    private func setupUI() {
        title = "JSONPlaceholder Users"
        view.backgroundColor = .white
        
        view.addSubview(userTableView)
        view.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            userTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            userTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            userTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            userTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupTableView() {
        userTableView.dataSource = self
        userTableView.delegate = self
        userTableView.register(UserTableViewCell.self, forCellReuseIdentifier: "UserCell")
        userTableView.rowHeight = UITableView.automaticDimension
        userTableView.estimatedRowHeight = 160
    }
    
    // MARK: - API Call
    private func fetchUsers() {
        loadingIndicator.startAnimating()
        
        APIService.shared.fetchUsers { [weak self] result in
            DispatchQueue.main.async {
                self?.loadingIndicator.stopAnimating()
                
                switch result {
                case .success(let users):
                    self?.users = users
                    self?.userTableView.reloadData()
                    
                case .failure(let error):
                    self?.showErrorAlert(message: error.localizedDescription)
                }
            }
        }
    }
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: "Failed to load users: \(message)",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
            self?.fetchUsers()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as? UserTableViewCell else {
            return UITableViewCell()
        }
        
        let user = users[indexPath.row]
        cell.configure(with: user)
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let user = users[indexPath.row]
        print("Selected user: \(user.name)")
        
        // You can navigate to user detail screen here
    }
    
}

