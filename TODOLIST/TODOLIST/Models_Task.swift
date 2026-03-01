import Foundation

enum Priority: String, CaseIterable, Codable, Identifiable {
    case high, medium, low
    var id: String { rawValue }
}

struct Task: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var title: String
    var notes: String?
    var dueDate: Date?
    var isCompleted: Bool = false
    var priority: Priority = .medium
    // Optionally include a project/list name:
    var project: String?
}
