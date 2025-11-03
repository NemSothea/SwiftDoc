//
//  ContentView.swift
//  personaltaskmanager
//
//  Created by sothea007 on 2/11/25.
//

import SwiftUI
import SwiftData
import CloudKit

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var categories: [Category]
    @State private var showingAddTask = false
    @State private var showingAddCategory = false
    @State private var searchText = ""
    @State private var sortOption: SortOption = .dueDate
    @State private var showCompleted = true
    @State private var iCloudStatusState: iCloudStatus = .checking
    
    enum SortOption: String, CaseIterable {
        case dueDate = "Due Date"
        case priority = "Priority"
        case title = "Title"
        case createdAt = "Created Date"
    }
    
    enum iCloudStatus {
        case available, unavailable, checking, restricted, temporarilyUnavailable
        
        var icon: String {
            switch self {
            case .available: return "icloud"
            case .unavailable: return "icloud.slash"
            case .checking: return "icloud.and.arrow.down"
            case .restricted: return "exclamationmark.icloud"
            case .temporarilyUnavailable: return "icloud.slash"
            }
        }
        
        var color: Color {
            switch self {
            case .available: return .blue
            case .unavailable: return .orange
            case .checking: return .gray
            case .restricted: return .red
            case .temporarilyUnavailable: return .orange
            }
        }
        
        var description: String {
            switch self {
            case .available: return "iCloud Sync Enabled"
            case .unavailable: return "iCloud Not Available"
            case .checking: return "Checking iCloud Status..."
            case .restricted: return "iCloud Restricted"
            case .temporarilyUnavailable: return "iCloud Temporarily Unavailable"
            }
        }
    }
    
    // Optimized: Use a struct to hold filtered data without creating new Category objects
    private var filteredSections: [CategorySection] {
        categories.compactMap { category in
            // Safely unwrap the optional tasks array
            let categoryTasks = category.tasks ?? []
            let filteredTasks = filterAndSortTasks(categoryTasks)
            guard !filteredTasks.isEmpty || searchText.isEmpty else { return nil }
            return CategorySection(category: category, tasks: filteredTasks)
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                // iCloud Status Banner - Show when NOT available or checking
                if iCloudStatusState != .available {
                    HStack {
                        Image(systemName: iCloudStatusState.icon)
                            .foregroundColor(iCloudStatusState.color)
                        Text(iCloudStatusState.description)
                            .font(.caption)
                        Spacer()
                        
                        if iCloudStatusState == .unavailable || iCloudStatusState == .temporarilyUnavailable {
                            Button("Settings") {
                                if let url = URL(string: UIApplication.openSettingsURLString) {
                                    UIApplication.shared.open(url)
                                }
                            }
                            .font(.caption)
                            .buttonStyle(.bordered)
                        }
                    }
                    .padding(8)
                    .background(iCloudStatusState.color.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.horizontal)
                }
                
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("Search tasks...", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    if !searchText.isEmpty {
                        Button("Clear") {
                            searchText = ""
                        }
                        .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal)
                
                // Sort and Filter Controls
                HStack {
                    Picker("Sort by", selection: $sortOption) {
                        ForEach(SortOption.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    Spacer()
                    
                    Toggle("Show Completed", isOn: $showCompleted)
                        .toggleStyle(.switch)
                        .fixedSize()
                }
                .padding(.horizontal)
                
                // Task List
                List {
                    if filteredSections.isEmpty && !categories.isEmpty {
                        VStack {
                            Image(systemName: "magnifyingglass")
                                .font(.largeTitle)
                                .foregroundColor(.secondary)
                            Text("No tasks found")
                                .foregroundColor(.secondary)
                            if !searchText.isEmpty {
                                Text("Try a different search term")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    } else {
                        ForEach(filteredSections) { section in
                            Section(header: CategoryHeaderView(category: section.category)) {
                                if section.tasks.isEmpty {
                                    Text("No tasks")
                                        .foregroundColor(.secondary)
                                        .italic()
                                } else {
                                    ForEach(section.tasks) { task in
                                        TaskRowView(task: task)
                                    }
                                    .onDelete { indices in
                                        deleteTasks(from: section, at: indices)
                                    }
                                }
                            }
                        }
                    }
                }
                .listStyle(.grouped)
            }
            .navigationTitle("Task Manager")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Menu {
                        Button("Add Category") {
                            showingAddCategory = true
                        }
                        
                        Button("Add Sample Data") {
                            createSampleData()
                        }
                        
                        // iCloud status check
                        Button("Check iCloud Status") {
                            checkiCloudStatus()
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        // iCloud status icon in toolbar (always show)
                        Image(systemName: iCloudStatusState.icon)
                            .foregroundColor(iCloudStatusState.color)
                            .font(.caption)
                        
                        Button("Add Task") {
                            showingAddTask = true
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddTask) {
                AddTaskView()
            }
            .sheet(isPresented: $showingAddCategory) {
                AddCategoryView()
            }
            .onAppear {
                checkiCloudStatus()
            }
        }
        .searchable(text: $searchText, prompt: "Search tasks...")
    }
    
    private func checkiCloudStatus() {
        iCloudStatusState = .checking
        
        CKContainer.default().accountStatus { status, error in
            DispatchQueue.main.async {
                switch status {
                case .available:
                    self.iCloudStatusState = .available
                    print("iCloud is available and configured")
                case .noAccount:
                    self.iCloudStatusState = .unavailable
                    print("iCloud is not configured. Please sign in to iCloud in Settings.")
                case .restricted:
                    self.iCloudStatusState = .restricted
                    print("iCloud access is restricted")
                case .couldNotDetermine:
                    self.iCloudStatusState = .unavailable
                    print("Could not determine iCloud status: \(error?.localizedDescription ?? "Unknown error")")
                case .temporarilyUnavailable:
                    self.iCloudStatusState = .temporarilyUnavailable
                    print("iCloud temporarily unavailable")
                @unknown default:
                    self.iCloudStatusState = .unavailable
                    print("Unknown iCloud status")
                }
            }
        }
    }
    
    private func filterAndSortTasks(_ tasks: [Task]) -> [Task] {
        var filtered = tasks
        
        // Apply search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { task in
                task.title.localizedCaseInsensitiveContains(searchText) ||
                task.taskDescription.localizedCaseInsensitiveContains(searchText) ||
                task.category?.name.localizedCaseInsensitiveContains(searchText) == true
            }
        }
        
        // Apply completed filter
        if !showCompleted {
            filtered = filtered.filter { !$0.isCompleted }
        }
        
        // Apply sorting
        switch sortOption {
        case .dueDate:
            filtered.sort { $0.dueDate < $1.dueDate }
        case .priority:
            filtered.sort { $0.priority > $1.priority }
        case .title:
            filtered.sort { $0.title < $1.title }
        case .createdAt:
            filtered.sort { $0.createdAt > $1.createdAt }
        }
        
        return filtered
    }
    
    private func deleteTasks(from section: CategorySection, at indices: IndexSet) {
        for index in indices {
            let taskToDelete = section.tasks[index]
            modelContext.delete(taskToDelete)
        }
    }
    
    private func createSampleData() {
        // Check if sample data already exists to avoid duplicates
        let existingWorkCategory = categories.first { $0.name == "Work" }
        let existingPersonalCategory = categories.first { $0.name == "Personal" }
        
        if existingWorkCategory == nil && existingPersonalCategory == nil {
            let workCategory = Category(name: "Work", color: "007AFF")
            let personalCategory = Category(name: "Personal", color: "34C759")
            let shoppingCategory = Category(name: "Shopping", color: "FF9500")
            
            let sampleTasks = [
                Task(title: "Finish SwiftData project",
                     taskDescription: "Complete the task manager app with SwiftData",
                     dueDate: Date().addingTimeInterval(86400),
                     priority: 2,
                     category: workCategory),
                
                Task(title: "Buy groceries",
                     dueDate: Date().addingTimeInterval(43200),
                     priority: 1,
                     category: personalCategory),
                
                Task(title: "Meeting with team",
                     taskDescription: "Weekly team sync",
                     dueDate: Date().addingTimeInterval(172800),
                     priority: 3,
                     category: workCategory)
            ]
            
            // Mark one task as completed for testing
            sampleTasks[1].isCompleted = true
            
            modelContext.insert(workCategory)
            modelContext.insert(personalCategory)
            modelContext.insert(shoppingCategory)
            
            for task in sampleTasks {
                modelContext.insert(task)
            }
            
            do {
                try modelContext.save()
                print("Sample data created successfully")
            } catch {
                print("Failed to save sample data: \(error)")
            }
        } else {
            print("Sample data already exists")
        }
    }
}

// Helper struct to avoid creating new Category objects
struct CategorySection: Identifiable {
    let id = UUID()
    let category: Category
    let tasks: [Task]
}
