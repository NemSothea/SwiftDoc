//
//  PostsViewModel.swift
//  FirstSwiftUIApp
//
//  Created by sothea007 on 22/12/25.
//

//2️⃣ Create a ViewModel to fetch posts

import Foundation
import Combine

class PostsViewModel: ObservableObject {
    
    @Published var posts: [PostModel] = []
    
    init() {
        fetchPosts()
    }
    
    func fetchPosts() {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts") else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching posts:", error.localizedDescription)
                return
            }
            
            guard let data = data else { return }
            
            do {
                let decodedPosts = try JSONDecoder().decode([PostModel].self, from: data)
                DispatchQueue.main.async {
                    self.posts = decodedPosts
                }
            } catch {
                print("Decoding error:", error)
            }
        }
        .resume()
    }
}
