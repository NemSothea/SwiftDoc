//
//  TodoItem.swift
//  Week05ExTodoList
//
//  Created by sothea007 on 5/11/25.
//


import Foundation

struct TodoItem: Codable {
    var id: UUID
    var title: String
    var isCompleted: Bool
    var createdAt: Date
    
    init(title: String, isCompleted: Bool = false) {
        self.id = UUID()
        self.title = title
        self.isCompleted = isCompleted
        self.createdAt = Date()
    }
}
