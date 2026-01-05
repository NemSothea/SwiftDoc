//
//  Post.swift
//  DisplayingPosts
//
//  Created by sothea007 on 15/12/25.
//

struct Post : Decodable {
    
    var id      : Int
    var userId  : Int
    var title   : String
    var body    : String
    
    enum CodingKeys : String, CodingKey {
        case id
        case userId = "userId"
        case title
        case body
    }
}
