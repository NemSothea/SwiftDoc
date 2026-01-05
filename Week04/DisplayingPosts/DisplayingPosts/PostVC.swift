//
//  PostVC.swift
//  DisplayingPosts
//
//  Created by sothea007 on 15/12/25.
//

import UIKit

class PostVC: UIViewController {
    
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var post : [Post] = [Post]()
    
    var selectedIndexPath: IndexPath?
    
    let activityIndicator = UIActivityIndicatorView(style: .large)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Get Post
        tableView.isHidden = true
        activityIndicator.center = view.center
        
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        
        getPost()
        
    }
    
    func getPost() {
        
        //Step 1 : Create url for url request
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts") else {
            return
        }
        // Step 2 : Make request using URLSession
        URLSession.shared.dataTask(with: url) { data,response,error in
            // Decode data into list of post
            if let data = data {
                if let decodedPost = try? JSONDecoder().decode([Post].self, from: data) {
                    // Step 3 : update data to display into tableview
                    self.post = decodedPost
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.activityIndicator.stopAnimating()
                        self.activityIndicator.isHidden = true
                        self.tableView.isHidden = false
                    }
                }
            }
        }.resume()
    }
    
}

extension PostVC : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return post.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let postcell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as? PostCell else {
            return UITableViewCell()
        }
        
        postcell.setupView(post: post[indexPath.row])
        
        return postcell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
                tableView.deselectRow(at: indexPath, animated: true)
        selectedIndexPath = indexPath
        performSegue(withIdentifier: "PostDetailVC", sender: self)


      
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "PostDetailVC",
           let destination = segue.destination as? PostViewDetail,
           let indexPath = selectedIndexPath {
            destination.selectedPost = post[indexPath.row]
        }
    }
}
