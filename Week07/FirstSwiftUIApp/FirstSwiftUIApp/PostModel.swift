//
//  Post.swift
//  FirstSwiftUIApp
//
//  Created by sothea007 on 22/12/25.
//

//✅ Step-by-Step SwiftUI
// 1️⃣ Define the Post model

import Foundation

struct PostModel: Codable,Hashable, Identifiable {
    
    let id: Int
    let userId: Int
    let title: String
    let body: String
}
