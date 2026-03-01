import Foundation
import Combine

final class TaskStore: ObservableObject {
    @Published var tasks: [Task] = [] {
        didSet { save() }
    }
    
    private let key = "todo.tasks.v1"
    
    init() {
        load()
    }
    
    func add(_ task: Task) {
        tasks.append(task)
    }
    
    func update(_ task: Task) {
        guard let idx = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[idx] = task
    }
    
    func remove(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
    }
    
    func toggleComplete(_ task: Task) {
        guard let idx = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[idx].isCompleted.toggle()
    }
    
    // MARK: - Persistence
    private func save() {
        do {
            let data = try JSONEncoder().encode(tasks)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            print("Save error:", error)
        }
    }
    
    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key) else { return }
        do {
            tasks = try JSONDecoder().decode([Task].self, from: data)
        } catch {
            print("Load error:", error)
        }
    }
}
