//
//  Item.swift
//  personaltaskmanager
//
//  Created by sothea007 on 2/11/25.
//

import SwiftData
import Foundation

@Model
final class Category {
    var name: String = ""
    var color: String = "#007AFF" // Default value
    @Relationship(deleteRule: .cascade) var tasks: [Task]? = [] // Make optional
    
    init(name: String, color: String) {
        self.name = name
        self.color = color
        self.tasks = []
    }
}

@Model
final class Task {
    var title: String = "" // Default value
    var taskDescription: String = "" // Default value
    var isCompleted: Bool = false // Default value
    var dueDate: Date = Date() // Default value
    var priority: Int = 1 // Default value
    var createdAt: Date = Date() // Default value
    var category: Category? // Make optional
    
    init(title: String, taskDescription: String = "", dueDate: Date = Date(), priority: Int = 1, category: Category? = nil) {
        self.title = title
        self.taskDescription = taskDescription
        self.dueDate = dueDate
        self.priority = priority
        self.category = category
        // createdAt and isCompleted use their default values
    }
}
