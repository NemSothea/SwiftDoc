//
//  PostDetailView.swift
//  FirstSwiftUIApp
//
//  Created by sothea007 on 22/12/25.
//

import SwiftUI

struct PostDetailView: View {
    
    let post: PostModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                Text(post.title)
                    .font(.title)
                    .fontWeight(.bold)

                Divider()

                Text(post.body)
                    .font(.body)

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Post #\(post.id)")
        .navigationBarTitleDisplayMode(.inline)
    }
}


#Preview {
    PostDetailView(post: PostModel(id: 1, userId: 1, title: "This is a title", body: "This is a body"))
}
