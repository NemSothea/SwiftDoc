import SwiftUI

struct TaskRow: View {
    @EnvironmentObject var store: TaskStore
    var task: Task
    
    var body: some View {
        HStack {
            Button(action: { store.toggleComplete(task) }) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(task.isCompleted ? .green : .secondary)
            }
            .buttonStyle(BorderlessButtonStyle())
            
            VStack(alignment: .leading) {
                Text(task.title)
                    .strikethrough(task.isCompleted, color: .gray)
                    .foregroundColor(task.isCompleted ? .secondary : .primary)
                    .font(.body)
                HStack(spacing: 8) {
                    if let due = task.dueDate {
                        Text(due, style: .date)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Text(task.priority.rawValue.capitalized)
                        .font(.caption2)
                        .padding(4)
                        .background(priorityColor)
                        .foregroundColor(.white)
                        .cornerRadius(4)
                }
            }
            Spacer()
        }
        .padding(.vertical, 6)
    }
    
    private var priorityColor: Color {
        switch task.priority {
        case .high: return .red
        case .medium: return .orange
        case .low: return .blue
        }
    }
}
