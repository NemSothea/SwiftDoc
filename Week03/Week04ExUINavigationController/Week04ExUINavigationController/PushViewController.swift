//
//  ViewController.swift
//  Week04ExUINavigationController
//
//  Created by sothea007 on 5/11/25.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var postTableView: UITableView!
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    var posts: [Posts] = []
    var selectedIndexPath: IndexPath?
    let apiService = APIService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupTableView()
        fetchPosts()
    }
    
    private func setupTableView() {
        title = "Posts"
        view.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        postTableView.delegate = self
        postTableView.dataSource = self
        postTableView.rowHeight = UITableView.automaticDimension
        postTableView.estimatedRowHeight = 160
    }
    private func fetchPosts() {
        
        loadingIndicator.startAnimating()
        
        apiService.fetchPosts { [weak self] result in
            DispatchQueue.main.async {
                self?.loadingIndicator.stopAnimating()
                switch result {
                case .success(let posts)
                    : self?.posts = posts
                    self?.postTableView.reloadData()
                case .failure(let error):
                    print("Error: \(error)")
                }
            }
        }
    }
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: "Failed to load posts: \(message)",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
            self?.fetchPosts()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? PostTableViewCell else {
            return UITableViewCell()
        }
        cell.postTitleLabel.text = "\(posts[indexPath.row].id) : \(posts[indexPath.row].title)"
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        // Perform segue and pass data
//        tableView.deselectRow(at: indexPath, animated: true)
//               selectedIndexPath = indexPath
//               performSegue(withIdentifier: "DetailViewController", sender: self)
        
        // Instantiate from Storyboard
        tableView.deselectRow(at: indexPath, animated: true)
               let selectedUser = posts[indexPath.row]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let detailVC = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController {
            detailVC.selectedPost = selectedUser
            navigationController?.pushViewController(detailVC, animated: true)
        }
     
    }
//   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//       if segue.identifier == "DetailViewController",
//          let destination = segue.destination as? DetailViewController,
//          let indexPath = selectedIndexPath {
//           destination.selectedPost = posts[indexPath.row]
//       }
//        
//    }


}
class PostTableViewCell: UITableViewCell {
    
    @IBOutlet weak var postTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}


