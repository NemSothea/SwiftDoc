//
//  ContentView 2.swift
//  FirstSwiftUIApp
//
//  Created by sothea007 on 22/12/25.
//
// 3️⃣ Create the SwiftUI view to show the posts

import SwiftUI

struct PostView: View {
    
    @ObservedObject var viewModel = PostsViewModel()
    
 
    
    init() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.red
        
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        
        NavigationStack {
            List(viewModel.posts) { post in
                NavigationLink(value: post) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(post.id)")
                        Text(post.title)
                            .font(.headline)
                        Text(post.body)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Posts")
            .navigationDestination(for: PostModel.self) { post in
                PostDetailView(post: post)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        PostView()
    }
}
