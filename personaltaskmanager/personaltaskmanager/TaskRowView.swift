//
//  Untitled.swift
//  personaltaskmanager
//
//  Created by sothea007 on 2/11/25.
//

import SwiftUI
import SwiftData

struct TaskRowView: View {
    @Bindable var task: Task
    @State private var showingEditSheet = false
    
    var body: some View {
        HStack {
            Button {
                task.isCompleted.toggle()
            } label: {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(task.isCompleted ? .green : .gray)
                    .font(.title2)
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .strikethrough(task.isCompleted)
                    .foregroundColor(task.isCompleted ? .gray : .primary)
                    .font(.headline)
                
                if !task.taskDescription.isEmpty {
                    Text(task.taskDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                HStack {
                    Text(task.dueDate, style: .date)
                        .font(.caption2)
                        .foregroundColor(dueDateColor)
                    
                    if task.priority > 1 {
                        Text(String(repeating: "!", count: task.priority))
                            .font(.caption2)
                            .foregroundColor(priorityColor)
                    }
                    
                    Spacer()
                    
                    Text("\(task.dueDate, style: .relative)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if let category = task.category {
                Circle()
                    .fill(Color(hex: category.color))
                    .frame(width: 12, height: 12)
            }
            
            Button {
                showingEditSheet = true
            } label: {
                Image(systemName: "pencil.tip.crop.circle.badge.plus.fill")
                    .foregroundColor(.blue)
                    .font(.caption)
            }
        }
        .padding(.vertical, 4)
        .sheet(isPresented: $showingEditSheet) {
            EditTaskView(task: task)
        }
    }
    
    private var dueDateColor: Color {
        if task.isCompleted {
            return .gray
        }
        
        let timeRemaining = task.dueDate.timeIntervalSinceNow
        if timeRemaining < 0 {
            return .red
        } else if timeRemaining < 86400 { // Less than 24 hours
            return .orange
        } else {
            return .secondary
        }
    }
    
    private var priorityColor: Color {
        switch task.priority {
        case 1: return .green
        case 2: return .orange
        case 3: return .red
        default: return .secondary
        }
    }
}
