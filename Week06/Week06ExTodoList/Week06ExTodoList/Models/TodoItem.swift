//
//  TodoItem.swift
//  Week06ExTodoList
//
//  Created by sothea007 on 5/11/25.
//
import Foundation


struct TodoItem: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var isCompleted: Bool
    var createdAt: Date
    var lastModified: Date
    var priority: Priority
    
    enum Priority: Int, Codable, CaseIterable {
        case low = 0
        case medium = 1
        case high = 2
        
        var title: String {
            switch self {
            case .low: return "Low"
            case .medium: return "Medium"
            case .high: return "High"
            }
        }
        
        var colorName: String {
            switch self {
            case .low: return "systemGreen"
            case .medium: return "systemOrange"
            case .high: return "systemRed"
            }
        }
    }
    
    init(id: UUID = UUID(),
         title: String,
         isCompleted: Bool = false,
         createdAt: Date = Date(),
         lastModified: Date = Date(),
         priority: Priority = .medium) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.createdAt = createdAt
        self.lastModified = lastModified
        self.priority = priority
    }
    
    mutating func toggleCompletion() {
        isCompleted.toggle()
        lastModified = Date()
    }
    
    mutating func updateTitle(_ newTitle: String) {
        title = newTitle
        lastModified = Date()
    }
    
    mutating func updatePriority(_ newPriority: Priority) {
        priority = newPriority
        lastModified = Date()
    }
}
